//
//  MessageData.h
//  Pods
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageData : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * jumps;
@property (nonatomic, retain) NSString * receiver;
@property (nonatomic, retain) NSString * transmitter;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * created;

@end
