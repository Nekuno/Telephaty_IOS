//
//  MessageDataUtils.m
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MessageDataUtils.h"

#import "KNCoreDataService.h"

@implementation MessageDataUtils

static const NSInteger kIndexStartEmisorForType1     = 16.0;
static const NSInteger kIndexStartEmisorForType2     = 32.0;
static const NSInteger kIndexStarMsgForType1         = 36.0;
static const NSInteger kIndexStarMsgForType2         = 52.0;

#pragma mark - Parameters & Constants

static NSString *const ItemMDEntityName = @"MessageData";


+ (MessageData *)addMessageInMOC:(NSManagedObjectContext *)moc withData:(NSString *)msgData{
  
  
  NSDictionary *msgDict = [self parseMessageData:msgData];
  
  MessageData *msg = [self fetchMessageInDBWithDate:msgDict[@"date"] andTransmitter:msgDict[@"transmitter"] part:msgDict[@"part"]];
  
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
  msg.part = msgDict[@"type"];
  msg.totalparts = msgDict[@"totalParts"];

  return msg;
}


+ (void)deleteMessageFromTransmitter:(NSString *)transmiter onDate:(NSString *)date{
  
  NSManagedObjectContext *moc = [[KNCoreDataService sharedInstance] mainThreadManagedObjectContext];
  MessageData *msg = [self fetchMessageInDBWithDate:date andTransmitter:transmiter];
  [moc deleteObject:msg];
  
}

+ (void)clearAllMessagesFromDataBase{
  
  NSManagedObjectContext *moc = [[KNCoreDataService sharedInstance] managedObjectContext];
  NSArray *messages = [self fetchMessagesInMoc:moc];

  for (MessageData *msg in messages) {
    [moc deleteObject:msg];
  }
}


+ (void)clearMessagesFromDataBaseOlderSiceFromNow:(NSTimeInterval)since{
  
  NSManagedObjectContext *moc = [[KNCoreDataService sharedInstance] managedObjectContext];
  NSArray *messages = [self fetchMessagesInMoc:moc];
  BOOL sendNotification = NO;
  
  for (MessageData *msg in messages) {
    
    NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:msg.created];
    if (distanceBetweenDates > since ) {
      [moc deleteObject:msg];
      sendNotification = YES;
    }
  }
  
  if (sendNotification) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemovedOldMessages object:nil];
  }
  
}



+ (MessageData *)fetchMessageInDBWithDate:(NSString *)date andTransmitter:(NSString *)transmitter part:(NSString *)part;
{
  
  MessageData *msgData;
   NSManagedObjectContext *moc = [[KNCoreDataService sharedInstance] mainThreadManagedObjectContext];
  NSFetchRequest *fetchRequest = [self prepareMessageDataInMOC:moc];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date == %@ AND transmitter = %@ AND part = %@", date, transmitter, part];
  NSError *error;
  NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
  if ([results count] != 0) {
    NSAssert(([results count] == 1), @"More than one msg with the same date and transmitter id  exist.");
    msgData = [results objectAtIndex:0];
  }
  return msgData;

}

+ (MessageData *)fetchMessageInDBWithDate:(NSString *)date andTransmitter:(NSString *)transmitter{
  
  MessageData *msgData;
  NSManagedObjectContext *moc = [[KNCoreDataService sharedInstance] mainThreadManagedObjectContext];
  NSFetchRequest *fetchRequest = [self prepareMessageDataInMOC:moc];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date == %@ AND transmitter = %@", date, transmitter];
  NSError *error;
  NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
  if ([results count] != 0) {
    NSAssert(([results count] == 1), @"More than one msg with the same date and transmitter id  exist.");
    msgData = [results objectAtIndex:0];
  }
  return msgData;
  
  
}

+ (NSArray *)fetchMessagesInDB{
  
  NSManagedObjectContext *moc = [[KNCoreDataService sharedInstance] mainThreadManagedObjectContext];
  return [self fetchMessagesInMoc:moc];
}

+ (NSArray *)fetchMessagesInMoc:(NSManagedObjectContext *)moc{

  NSFetchRequest *fetchRequest = [self prepareMessageDataInMOC:moc];
  fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES],
                                   [NSSortDescriptor sortDescriptorWithKey:@"transmitter" ascending:YES],
                                   [NSSortDescriptor sortDescriptorWithKey:@"part" ascending:YES]];
  
  NSError *error;
  NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
  return results;
  
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
  NSString *part;
  NSString *totalParts;
  
  if ([typeMsg integerValue] == 1) {
    message = [msgData substringFromIndex:kIndexStarMsgForType1];
    emisorId = [msgData substringWithRange:NSMakeRange(kIndexStartEmisorForType1, 16)];
    part = [msgData substringWithRange:NSMakeRange(kIndexStarMsgForType1 - 4, 2)];
    totalParts = [msgData substringWithRange:NSMakeRange(kIndexStarMsgForType1 - 2, 2)];
  } else {
    message = [msgData substringFromIndex:kIndexStarMsgForType2];
    emisorId = [msgData substringWithRange:NSMakeRange(kIndexStartEmisorForType2, 16)];
    receiver = [msgData substringWithRange:NSMakeRange(kIndexStartEmisorForType1, 16)];
    part = [msgData substringWithRange:NSMakeRange(kIndexStarMsgForType2 - 4, 2)];
    totalParts = [msgData substringWithRange:NSMakeRange(kIndexStarMsgForType2 - 2, 2)];
  }
  
  NSMutableDictionary *msgDict = [@{@"type":typeMsg,
                                   @"date":date,
                                   @"jumps":jumps,
                                   @"transmitter":emisorId,
                                   @"message":message,
                                   @"part" :part,
                                   @"totalParts":totalParts} mutableCopy];
  
  if (receiver) {
    msgDict[@"receiver"] = receiver;
  }
  
  return msgDict;
  
}



@end
