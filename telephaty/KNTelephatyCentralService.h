//
//  KNTelephatyCentralService.h
//  Telephaty
//
//  Created by Eduardo K. Palenzuela Darias on 16/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageData;

@protocol KNTelephatyCentralServiceDelegate;

@interface KNTelephatyCentralService : NSObject

#pragma mark - Lifecycle

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;

#pragma mark - Properties
@property (weak, nonatomic) id <KNTelephatyCentralServiceDelegate> delegateService;

#pragma mark - Public
// Tries to scan and connect to any peripheral.
- (void)connect;

// Disconnects all connected services and peripherals.
- (void)disconnect;

// Subscribe to characteristics defined in characteristicUUIDs.
- (void)subscribe;

// Unsubscribe from characteristics defined in characteriticUUIDs
- (void)unsubscribe;

@end

#pragma mark - KNTelephatyCentralServiceDelegate
@protocol KNTelephatyCentralServiceDelegate <NSObject>

- (void)telephatyCentralServiceDidReceiveMessage:(MessageData *)message;

@end