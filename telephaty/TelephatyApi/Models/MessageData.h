//
//  MessageData.h
//  Pods
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  MessageData
 */

@interface MessageData : NSManagedObject


/**
 *  Type of message 1 Broadcast, 2 Direct.
 */
@property (nonatomic, retain) NSString * type;
/**
 *  Date first time the messages was sent.
 */
@property (nonatomic, retain) NSString * date;
/**
 *  Numbers of times the message can be resend. Min 1 Max 9. When a device receive a message decrements the jumps
    and resend it.
 */
@property (nonatomic, retain) NSString * jumps;
/**
 *  ID of destinatary. Only present in direct messages.
 */
@property (nonatomic, retain) NSString * receiver;
/**
 *  ID of device sending the message.
 */
@property (nonatomic, retain) NSString * transmitter;
/**
 *  Text sent.
 */
@property (nonatomic, retain) NSString * message;
/**
 *  Date when the message was stored in DB.
 */
@property (nonatomic, retain) NSDate * created;

@end
