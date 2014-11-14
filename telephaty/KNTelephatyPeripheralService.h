//
//  KNTelephatyPeripheralService.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNTelephatyPeripheralService : NSObject

#pragma mark - Lifecycle

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;

#pragma mark - Public methods

- (void)sendToSubscribers:(NSData *)data;

/**
 * Called by the application if it enters the background.
 */
- (void)applicationDidEnterBackground;

/**
 * Called by the application if it enters the foregroud.
 */
- (void)applicationWillEnterForeground;

/**
 * Allows turning on the advertisments.
 */
- (void)startAdvertising;

/**
 * Allows turning off the advertisments.
 */
- (void)stopAdvertising;

/**
 * Allows know it the device is advertising
 *
 * @returm YES or NO.
 */
- (BOOL)isAdvertising;

@end
