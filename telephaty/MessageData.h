//
//  MessageData.h
//  telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 26/11/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageData : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * jumps;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * receiver;
@property (nonatomic, retain) NSString * transmitter;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * part;
@property (nonatomic, retain) NSString * totalparts;

@end
