//
//  KNTelephatyService.h
//  Telephaty
//
//  Created by Eduardo K. Palenzuela Darias on 10/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageData;

@protocol KNTelephatyServiceDelegate;

/**
 *  KNTelephatyService
 */
@interface KNTelephatyService : NSObject

#pragma mark - Properties

@property (copy, nonatomic, readonly) NSString *identifier;
@property (weak, nonatomic) id <KNTelephatyServiceDelegate> delegateService;

#pragma mark - Public methods

- (void)startWatch;

- (void)startEmit;

- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps;

- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps to:(NSString *)to;

@end

#pragma mark - KNTelephatyServiceDelegate
@protocol KNTelephatyServiceDelegate <NSObject>

- (void)telephatyServiceDidReceiveMessage:(MessageData *)message;

@end