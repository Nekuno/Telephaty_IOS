//
//  MessageDataUtils.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MessageData.h"

static NSString  *kNotificationRemovedOldMessages = @"kNotificationRemovedOldMessages";

/**
 *  Subclass of MessageData to provide it of methods to manage actions on it
 */

@interface MessageDataUtils : MessageData

/**
 *  Add message to DB
 *
 *  @param moc ManageObjectContext where add the message.
 *  @param msgData Message to store.
 *
 *  @return if all go fine, return a MessageData object.
 *
 *  @discussion if the meesage is already in the DB, this is not added and themethod return nil.
 */
+ (MessageData *)addMessageInMOC:(NSManagedObjectContext *)moc withData:(NSString *)msgData;

/**
 *  Parse String received to be able to insert it on DB
 *
 *  @param msgData Message to store.
 *
 *  @return A dictionary with all keys matching the MessageData properties.
 *
 */
+ (NSDictionary *)parseMessageData:(NSString *)msgData;

/**
 *  Return all messages in Data Base
 *
 *  @return Array with all objects MessageData in DB
 *
 *  @discussion if the DB is empty, return nil.
 */
+ (NSArray *)fetchMessagesInDB;

/**
 *  Delete a message from Data Base
 *
 *  @param transmiter ID of device which sent the initial message.
 *  @param date Date of meesage
 */
+ (void)deleteMessageFromTransmitter:(NSString *)transmiter onDate:(NSString *)date;

/**
 *  Recover and specific message
 *
 *  @param date Date of message to retirve.
 *  @param transmiter ID of device which sent the initial message.
 *
 *  @return return a MeeageData instance, if it's not found it, return nil.
 */
+ (MessageData *)fetchMessageInDBWithDate:(NSString *)date andTransmitter:(NSString *)transmitter;

/**
 *  Delete all messages in DB
 */
+ (void)clearAllMessagesFromDataBase;

/**
 *  Delete all messages older than a time since now.
 *
 *  @param since Time in minutes.
 *
 *  @discussion If messages to delete are found through a notification kNotificationRemovedOldMessages.
 */
+ (void)clearMessagesFromDataBaseOlderSiceFromNow:(NSTimeInterval)since;
@end
