//
//  KNTelephatyService.m
//  Telephaty
//
//  Created by Eduardo K. Palenzuela Darias on 10/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "KNTelephatyService.h"

#import "KNTelephatyCentralService.h"
#import "KNTelephatyPeripheralService.h"
#import "KNCoreDataService.h"
#import "MessageDataUtils.h"

#define TELEPHATY_SERVICE_UUID        @"00001101-0000-1000-8000-00805F9B34FB"
#define TELEPHATY_CHARACTERISTIC_UUID @"00001101-0000-1000-8000-00805F9B34FA"

typedef NS_ENUM(NSUInteger, TypeMessage) {
  
  typeMessageNoUsed,
  typeMessageBroadcast,
  typeMessageDirect
  
};

@interface KNTelephatyService() <KNTelephatyCentralServiceDelegate>

/**
 *  KNTelephatyCentralService
 */
@property (copy, nonatomic, readonly) KNTelephatyCentralService *centralService;

/**
 *  KNTelephatyPeripheralService
 */
@property (copy, nonatomic, readonly) KNTelephatyPeripheralService *peripheralService;

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation KNTelephatyService

#pragma mark - Properties

@synthesize identifier = _identifier;
- (NSString *)identifier {
  if (!_identifier) {
    _identifier = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    _identifier = [_identifier stringByReplacingOccurrencesOfString:@"-" withString:@""];
    _identifier = [_identifier substringFromIndex:16];
  }
  
  return _identifier;
}

@synthesize centralService = _centralService;
- (KNTelephatyCentralService *)centralService {
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _centralService = [[KNTelephatyCentralService alloc] initWithServiceUUID:TELEPHATY_SERVICE_UUID
                                                          characteristicUUID:TELEPHATY_CHARACTERISTIC_UUID];
    _centralService.delegateService = self;
  });
  
  return _centralService;
}

@synthesize peripheralService = _peripheralService;
- (KNTelephatyPeripheralService *)peripheralService {
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _peripheralService = [[KNTelephatyPeripheralService alloc] initWithServiceUUID:TELEPHATY_SERVICE_UUID
                                                                characteristicUUID:TELEPHATY_CHARACTERISTIC_UUID];
  });
  
  return _peripheralService;
  
}

- (NSDateFormatter *)formatter{
  
  if (!_formatter) {
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"ddMMyyyyHHmmss";
    
  }
  return _formatter;
  
}

#pragma mark - Public methods

- (void)startWatch {
  if (self.centralService) {
    __weak typeof (self) this = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [this.centralService connect];
//      [this.centralService subscribe];
    });
  }
}

- (void)startEmit {
  if (self.peripheralService) {
    __weak typeof (self) this = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [this.peripheralService startAdvertising];
    });
  }
}
- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps{
  
  NSAssert(jumps > 0, @"Number of jumps must be greater than 0");
  NSAssert(jumps < 10, @"Number of jumps must be smaller than 10");
  
  
  NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
  NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@", @(typeMessageBroadcast),dateStr, (long)jumps, self.identifier, message];
  
  [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageToSend];
  
  [self.peripheralService sendToSubscribers:[messageToSend dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps to:(NSString *)to{
  
  NSAssert(jumps > 0, @"Number of jumps must be greater than 0");
  NSAssert(jumps < 10, @"Number of jumps must be smaller than 10");
  
  NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
  NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@%@", @(typeMessageDirect),dateStr, (long)jumps,to, self.identifier, message];
  
  [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageToSend];
  
  [self.peripheralService sendToSubscribers:[messageToSend dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)resendMessage:(MessageData *)message{
  
  NSInteger jumps = [message.jumps integerValue] -1;
  NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@", @(typeMessageBroadcast),message.date, (long)jumps, message.transmitter, message.message];
  [self.peripheralService sendToSubscribers:[messageToSend dataUsingEncoding:NSUTF8StringEncoding]];
  
}

#pragma mark - KNTelephatyCentralServiceDelegate

- (void)telephatyCentralServiceDidReceiveMessage:(MessageData *)message {
  
  if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = message.message;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
  }

  if (message.jumps > 0 && [message.type integerValue] != typeMessageDirect) {
    [self resendMessage:message];
  }
  [self.delegateService telephatyServiceDidReceiveMessage:message];
}

@end
