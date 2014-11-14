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

/**
 * ID of device.
 *
 *  @discussion This ID is added to all messages sent.
 */
@property (copy, nonatomic, readonly) NSString *identifier;

@property (weak, nonatomic) id <KNTelephatyServiceDelegate> delegateService;

#pragma mark - Public methods

/**
 * Starts listening for messages.
 */
- (void)startWatch;

/**
 * Start advertising of device.
 */
- (void)startEmit;

/**
 * Send a Broadcast message
 *
 * @param message Message to send.
 * @param jumps Number of jumps allowed for this message.
 *
 * @discussion Send a message to be recieved for all devices listening the service.
 */
- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps;

/**
 * Send a Direct message
 *
 * @param message Message to send.
 * @param jumps Number of jumps allowed for this message.
 * @param to  ID of device receiver.
 *
 * @discussion Send a message to device indentified by its ID..
 */
- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps to:(NSString *)to;

/**
 * Resend a meesage
 *
 * @param message  Instance of MessageData to resend.
 *
 * @discussion Decrement jumps by 1 and send the message.
 */
- (void)resendMessage:(MessageData *)message;

@end

#pragma mark - KNTelephatyServiceDelegate

/**
 *  Protocol to inform to delegate that a new message has been received.
 *
 *  @discussion This protocol must be conformed to be informed about new messages received
 *  in order to show in the UI.
 */
@protocol KNTelephatyServiceDelegate <NSObject>

- (void)telephatyServiceDidReceiveMessage:(MessageData *)message;

@end