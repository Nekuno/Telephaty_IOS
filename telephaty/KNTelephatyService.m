//
//  KNTelephatyService.m
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "KNTelephatyService.h"

#import "KNTelephatyCentralService.h"
#import "KNTelephatyPeripheralService.h"
#import "KNCoreDataService.h"
#import "MessageDataUtils.h"

#import "KNConfigurationService.h"

#import "AESCrypt.h"
#import "RSA.h"

static NSInteger klimitBytesBroadcastMessage = 95;
static NSInteger klimitBytesDirectMessage = 60;

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

/**
 * Public key to encrypt direct messages
 */
@property (nonatomic, assign) SecKeyRef publicKey;

/**
 * Public key to decrypt direct messages
 */
@property (nonatomic, assign) SecKeyRef privateKey;

@property (nonatomic, strong) NSTimer *cleanTimer;

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

- (SecKeyRef)publicKey{
  
  if (!_publicKey) {
    _publicKey = [RSA addKey:RSA_PUBLIC_KEY withTag:@"com.qnow.telepahty.publickey" public:YES];
  }
  return _publicKey;
}

- (SecKeyRef)privateKey{
  
  if (!_privateKey) {
    _privateKey = [RSA addKey:RSA_PRIVATE_KEY withTag:@"com.qnow.telepahty.privatekey" public:NO];
  }
  return _privateKey;
}

#pragma mark - Public methods

- (void)startWatch {
  if (self.centralService) {
    __weak typeof (self) this = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [this.centralService connect];
    });
  }
  
  self.cleanTimer =  [NSTimer scheduledTimerWithTimeInterval:REMOVE_MESSAGES_OLDER_THAN_MINUTES * 60
                                                      target:self
                                                    selector:@selector(removeOldMessages:)
                                                    userInfo:nil
                                                    repeats:YES];
}
- (void)startEmit {
  if (self.peripheralService) {
    __weak typeof (self) this = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [this.peripheralService startAdvertising];
    });
  }
}
- (NSMutableDictionary *)splitMesage:(NSString *)message ofType:(NSInteger)type andLength:(NSInteger)lengthData {
  
  NSInteger limitBytes = type == typeMessageBroadcast ? klimitBytesBroadcastMessage : klimitBytesDirectMessage;
  
  NSInteger parts = (lengthData / limitBytes) + 1;
  NSInteger lengthParts = ([message length] / parts);
  NSArray *array = [message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
  NSMutableDictionary *splitedMessage = [NSMutableDictionary dictionary];
  NSString *partMsg;
  for (NSString *word in array) {
    if (partMsg) {
      if (([partMsg length] + [word length] + 1) > lengthParts) {
        NSString *key = [NSString stringWithFormat:@"%d", [[splitedMessage allKeys] count]+1];
        splitedMessage[key] = partMsg;
        partMsg = word;
      } else {
        partMsg = [partMsg stringByAppendingFormat:@" %@",word];
      }
    } else {
      partMsg = word;
    }
  }
  
  NSString *key = [NSString stringWithFormat:@"%d", [[splitedMessage allKeys] count]+1];
  splitedMessage[key] = partMsg;
  
  return splitedMessage;
}

- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps{
  
  NSAssert(jumps > 0, @"Number of jumps must be greater than 0");
  NSAssert(jumps < 10, @"Number of jumps must be smaller than 10");
  NSAssert([PASS_AES_ENCRYPTION length] != 0, @"You must set the key for encrypt broadcast messages");
  
  NSString *encryptedMessage = [AESCrypt encrypt:message password:PASS_AES_ENCRYPTION];
  
  NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
  NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@0101000%@", @(typeMessageBroadcast),dateStr, (long)jumps, self.identifier,encryptedMessage];
  NSData *dataEncrypted = [encryptedMessage dataUsingEncoding:NSUTF8StringEncoding];
  
  if ([dataEncrypted length] > klimitBytesBroadcastMessage) {

    NSDictionary *splitedMsg = [self splitMesage:message ofType:typeMessageBroadcast andLength:[dataEncrypted length]];
    NSString *totalPartsStr =  [[splitedMsg allKeys] count] > 9 ? [NSString stringWithFormat:@"%d",[[splitedMsg allKeys] count]] : [NSString stringWithFormat:@"0%d",[[splitedMsg allKeys] count]];
    for (NSString *key in [[splitedMsg allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
  
      NSString *partStr = [key length] > 1 ? key : [NSString stringWithFormat:@"0%@",key];
      //encryptedMessage = [RSA encrypt:splitedMsg[key] withKey:self.publicKey];
      encryptedMessage = [AESCrypt encrypt:splitedMsg[key] password:PASS_AES_ENCRYPTION];
      NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@%@000%@", @(typeMessageBroadcast),dateStr, (long)jumps, self.identifier, partStr,totalPartsStr,encryptedMessage];
      [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageToSend];
      NSData *dataMsg = [messageToSend dataUsingEncoding:NSUTF8StringEncoding];
      [self.peripheralService sendToSubscribers:dataMsg];
      
    }
  } else {
    [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageToSend];
    NSData *dataMsg = [messageToSend dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheralService sendToSubscribers:dataMsg];
  }
}

- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps to:(NSString *)to{
  
  NSAssert(jumps > 0, @"Number of jumps must be greater than 0");
  NSAssert(jumps < 10, @"Number of jumps must be smaller than 10");
  
//  NSString *encryptedMessage = [RSA encrypt:message withKey:self.publicKey];
  NSString *encryptedMessage = [AESCrypt encrypt:message password:PASS_AES_ENCRYPTION];
  NSData *dataEncrypted = [encryptedMessage dataUsingEncoding:NSUTF8StringEncoding];
  
  NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
  NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@0101000%@", @(typeMessageDirect),dateStr, (long)jumps,to, self.identifier, encryptedMessage];
  
  if ([dataEncrypted length] > klimitBytesDirectMessage) {
    
    NSDictionary *splitedMsg = [self splitMesage:message ofType:typeMessageDirect andLength:[dataEncrypted length]];
    NSString *totalPartsStr =  [[splitedMsg allKeys] count] > 9 ? [NSString stringWithFormat:@"%d",[[splitedMsg allKeys] count]] : [NSString stringWithFormat:@"0%d",[[splitedMsg allKeys] count]];
    
    for (NSString *key in [[splitedMsg allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
      
      NSString *partStr = [key length] > 1 ? key : [NSString stringWithFormat:@"0%@",key];
      //encryptedMessage = [RSA encrypt:splitedMsg[key] withKey:self.publicKey];
      encryptedMessage = [AESCrypt encrypt:splitedMsg[key] password:PASS_AES_ENCRYPTION];
      NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@%@%@000%@", @(typeMessageDirect),dateStr, (long)jumps,to, self.identifier, partStr,totalPartsStr,encryptedMessage];
      [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageToSend];
      NSData *dataMsg = [messageToSend dataUsingEncoding:NSUTF8StringEncoding];
      [self.peripheralService sendToSubscribers:dataMsg];
    }
  } else {
    
    [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageToSend];
    NSData *dataMsg = [messageToSend dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheralService sendToSubscribers:dataMsg];
  }
}

- (void)resendMessage:(MessageData *)message{
  
  NSInteger jumps = [message.jumps integerValue] -1;

  NSString *messageToSend = [NSString stringWithFormat:@"%@%@%ld%@%@%@000%@", @(typeMessageBroadcast),message.date, (long)jumps, message.transmitter,message.part, message.totalparts, message.message];
  [self.peripheralService sendToSubscribers:[messageToSend dataUsingEncoding:NSUTF8StringEncoding]];
  
}


#pragma mark - Private Methods

- (void)removeOldMessages:(id)sender{
  
  [MessageDataUtils clearMessagesFromDataBaseOlderSiceFromNow:REMOVE_MESSAGES_OLDER_THAN_MINUTES * 60];
   
}

#pragma mark - KNTelephatyCentralServiceDelegate

- (void)telephatyCentralServiceDidReceiveMessage:(MessageData *)message {
  
  if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = [self decryptedMessage:message];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
  }

  if ([message.jumps integerValue] > 1 && [message.type integerValue] != typeMessageDirect) {
    [self resendMessage:message];
  }
  [self.delegateService telephatyServiceDidReceiveMessage:message];
}

#pragma mark - Encryption

- (NSString *)decryptedMessage:(MessageData *)messageToDecrypt{
  
  if ([messageToDecrypt.type integerValue] ==  typeMessageBroadcast) {
    return [AESCrypt decrypt:messageToDecrypt.message password:PASS_AES_ENCRYPTION];
  } else {
  //  return [RSA decrypt:messageToDecrypt.message withKey:self.privateKey];
    return [AESCrypt decrypt:messageToDecrypt.message password:PASS_AES_ENCRYPTION];
  }
}

@end
