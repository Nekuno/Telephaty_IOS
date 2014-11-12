//
//  MessageDataUtils.m
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "MessageDataUtils.h"

@implementation MessageDataUtils


static const NSInteger kIndexStartEmisorForType1     = 16.0;
static const NSInteger kIndexStartEmisorForType2     = 32.0;
static const NSInteger kIndexStarMsgForType1         = 32.0;
static const NSInteger kIndexStarMsgForType2         = 48.0;

#pragma mark - Parameters & Constants

static NSString *const ItemMDEntityName = @"MessageData";


+ (MessageData *)addMessageInMOC:(NSManagedObjectContext *)moc withData:(NSString *)msgData{
  
  
  NSDictionary *msgDict = [self parseMessageData:msgData];
  
  MessageData *msg = [self fetchMessageInMOC:moc withDate:msgDict[@"date"] andTransmitter:msgDict[@"transmitter"]];
  
  if (msg) {
    return nil;
  }
  
  msg = [NSEntityDescription insertNewObjectForEntityForName:ItemMDEntityName
                                       inManagedObjectContext:moc];
  
  msg.type = msgDict[@"type"];
  msg.date = msgDict[@"date"];
  msg.jumps = msgDict[@"jumps"];
  msg.receiver = msgDict[@"receiver"];
  msg.transmitter = msgDict[@"transmitter"];
  msg.message = msgDict[@"message"];
  msg.created = [NSDate date];

  return msg;
}



+ (MessageData *)fetchMessageInMOC:(NSManagedObjectContext *)moc withDate:(NSString *)date andTransmitter:(NSString *)transmitter{
  
  MessageData *msgData;
  NSFetchRequest *fetchRequest = [self prepareMessageDataInMOC:moc];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date == %@ AND transmitter = %@", date, transmitter];

  NSError *error;
  NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
  if ([results count] != 0) {
    NSAssert(([results count] == 1), @"More than one group with the same identifier exist.");
    msgData = [results objectAtIndex:0];
  }
  return msgData;

}

+ (NSFetchRequest *)prepareMessageDataInMOC:(NSManagedObjectContext *)moc {
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  fetchRequest.entity = [NSEntityDescription entityForName:ItemMDEntityName
                                    inManagedObjectContext:moc];
  return fetchRequest;
}

+ (NSDictionary *)parseMessageData:(NSString *)msgData{
  
  NSString *typeMsg = [msgData substringToIndex:1];
  NSString *message;
  NSString *emisorId;
  NSString *receiver;
  NSString *date = [msgData substringWithRange:NSMakeRange(1, 14)];
  NSString *jumps = [msgData substringWithRange:NSMakeRange(15, 1)];
  
  if ([typeMsg integerValue] == 1) {
    message = [msgData substringFromIndex:kIndexStarMsgForType1];
    emisorId = [msgData substringWithRange:NSMakeRange(kIndexStartEmisorForType1, 16)];
  } else {
    message = [msgData substringFromIndex:kIndexStarMsgForType2];
    emisorId = [msgData substringWithRange:NSMakeRange(kIndexStartEmisorForType2, 16)];
    receiver = [msgData substringWithRange:NSMakeRange(kIndexStartEmisorForType1, 16)];
  }
  
  NSMutableDictionary *msgDict = [@{@"type":typeMsg,
                                   @"date":date,
                                   @"jumps":jumps,
                                   @"transmitter":emisorId,
                                   @"message":message} mutableCopy];
  
  if (receiver) {
    msgDict[@"receiver"] = receiver;
  }
  
  return msgDict;
  
}

@end
