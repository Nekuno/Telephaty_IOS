//
//  MessageDataUtils.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "MessageData.h"

static NSString  *kNotificationRemovedOldMessages = @"kNotificationRemovedOldMessages";

@interface MessageDataUtils : MessageData


+ (MessageData *)addMessageInMOC:(NSManagedObjectContext *)moc withData:(NSString *)msgData;

+ (NSDictionary *)parseMessageData:(NSString *)msgData;

+ (NSArray *)fetchMessagesInMOC:(NSManagedObjectContext *)moc;

+ (void)deleteMessageFromTransmitter:(NSString *)transmiter onDate:(NSString *)date;

+ (MessageData *)fetchMessageInMOC:(NSManagedObjectContext *)moc withDate:(NSString *)date andTransmitter:(NSString *)transmitter;

+ (void)clearAllMessagesFromDataBase;

+ (void)clearMessagesFromDataBaseOlderSiceFromNow:(NSTimeInterval)since;
@end
