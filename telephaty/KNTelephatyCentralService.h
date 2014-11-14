//
//  KNTelephatyCentralService.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
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

/**
 * Tries to scan and connect to any peripheral.
 */
- (void)connect;

/**
 * Disconnects all connected services and peripherals.
 */
- (void)disconnect;

/**
 * Subscribe to characteristics defined in characteristicUUIDs.
 */
- (void)subscribe;

/**
 * Unsubscribe from characteristics defined in characteriticUUIDs
 */
- (void)unsubscribe;

@end

#pragma mark - KNTelephatyCentralServiceDelegate

/**
 *  Protocol to inform to delegate that a new message has been received.
 */
@protocol KNTelephatyCentralServiceDelegate <NSObject>

- (void)telephatyCentralServiceDidReceiveMessage:(MessageData *)message;

@end