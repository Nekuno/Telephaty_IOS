//
//  KNMessagesViewController.m
//  Telephaty
//
//  Created by Eduardo Palenzuela Darias on 23/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "KNMessagesViewController.h"

#import "KNCoreDataService.h"
#import "MessageDataUtils.h"

@interface KNMessagesViewController () <KNTelephatyServiceDelegate>

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) NSDateFormatter *dateformatter;

@end

@implementation KNMessagesViewController

#pragma mark - Lifecycle


- (NSDateFormatter *)dateformatter{
  
  if (!_dateformatter) {
    _dateformatter = [[NSDateFormatter alloc] init];
    _dateformatter.dateFormat = @"ddMMyyyyHHmmss";
    
  }
  return _dateformatter;
  
}

- (void)loadLocalMessages{
  
  NSArray *localMsgs = [MessageDataUtils fetchMessagesInMOC:[[KNCoreDataService sharedInstance] managedObjectContext]];
  
  NSInteger currentNumMessages = [self.messages count];
  
  [localMsgs enumerateObjectsUsingBlock:^(MessageData *msg, NSUInteger idx, BOOL *stop) {
    JSQTextMessage *message = [[JSQTextMessage alloc] initWithSenderId:msg.transmitter
                                                     senderDisplayName:@""
                                                                  date:[self.dateformatter dateFromString:msg.date]
                                                                  text:msg.message];
    [self.messages addObject:message];
    if (idx == [localMsgs count] - currentNumMessages) {
      *stop=YES;
    }
  }];
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.inputToolbar.contentView.leftBarButtonItem.hidden = YES;
  self.messages = [NSMutableArray array];
  [self loadLocalMessages];
  
  // Settings of JSQMessagesViewController
  self.senderId = [[AppDelegate sharedDelegate].telephatyService identifier];
  self.senderDisplayName = @"Telephaty_user";
  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
  self.automaticallyScrollsToMostRecentMessage = YES;
  
  /**
   *  Create message bubble images objects.
   *
   *  Be sure to create your bubble images one time and reuse them for good performance.
   *
   */
  JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
  
  self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
  self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
  
  [[AppDelegate sharedDelegate].telephatyService setDelegateService:self];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Enable/disable springy bubbles
//  self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
  /**
   *  Sending a message. Your implementation of this method should do *at least* the following:
   *
   *  1. Play sound (optional)
   *  2. Add new id<JSQMessageData> object to your data source
   *  3. Call `finishSendingMessage`
   */
  [JSQSystemSoundPlayer jsq_playMessageSentSound];
  
  JSQTextMessage *message = [[JSQTextMessage alloc] initWithSenderId:senderId
                                                   senderDisplayName:senderDisplayName
                                                                date:date
                                                                text:text];
  
  if (button) {
    [[AppDelegate sharedDelegate].telephatyService sendMessage:text];
  }  
  
  [self.messages addObject:message];
  [self finishSendingMessage];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  You may return nil here if you do not want bubbles.
   *  In this case, you should set the background color of your collection view cell's textView.
   *
   *  Otherwise, return your previously created bubble image data objects.
   */
  
  JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
  
  if ([message.senderId isEqualToString:self.senderId]) {
    return self.outgoingBubbleImageData;
  }
  
  return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  Return `nil` here if you do not want avatars.
   *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
   *
   *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
   *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
   *
   *  It is possible to have only outgoing avatars or only incoming avatars, too.
   */
  
  /**
   *  Return your previously created avatar image data objects.
   *
   *  Note: these the avatars will be sized according to these values:
   *
   *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
   *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
   *
   *  Override the defaults in `viewDidLoad`
   */
//  JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
//  
//  if ([message.senderId isEqualToString:self.senderId]) {
//    if (![NSUserDefaults outgoingAvatarSetting]) {
//      return nil;
//    }
//  }
//  else {
//    if (![NSUserDefaults incomingAvatarSetting]) {
//      return nil;
//    }
//  }
//  
//  
//  return [self.demoData.avatars objectForKey:message.senderId];
  return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
   *  The other label text delegate methods should follow a similar pattern.
   *
   *  Show a timestamp for every 3rd message
   */
  if (indexPath.item % 3 == 0) {
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
  }
  
  return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
  
  /**
   *  iOS7-style sender name labels
   */
  if ([message.senderId isEqualToString:self.senderId]) {
    return nil;
  }
  
  if (indexPath.item - 1 > 0) {
    JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
    if ([[previousMessage senderId] isEqualToString:message.senderId]) {
      return nil;
    }
  }
  
  /**
   *  Don't specify attributes to use the defaults.
   */
  return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  Override point for customizing cells
   */
  JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
  
  /**
   *  Configure almost *anything* on the cell
   *
   *  Text colors, label text, label colors, etc.
   *
   *
   *  DO NOT set `cell.textView.font` !
   *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
   *
   *
   *  DO NOT manipulate cell layout information!
   *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
   */
  
  JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
  
  if ([msg isKindOfClass:[JSQTextMessage class]]) {
    
    if ([msg.senderId isEqualToString:self.senderId]) {
      cell.textView.textColor = [UIColor blackColor];
    }
    else {
      cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
  }
  
  return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
   */
  
  /**
   *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
   *  The other label height delegate methods should follow similarly
   *
   *  Show a timestamp for every 3rd message
   */
  if (indexPath.item % 3 == 0) {
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
  }
  
  return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  iOS7-style sender name labels
   */
  JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
  if ([[currentMessage senderId] isEqualToString:self.senderId]) {
    return 0.0f;
  }
  
  if (indexPath.item - 1 > 0) {
    JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
    if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
      return 0.0f;
    }
  }
  
  return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
  return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView
didTapLoadEarlierMessagesButton:(UIButton *)sender {
    [self loadLocalMessages];
    headerView.loadButton.enabled = NO;
    [self.collectionView reloadData];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapCellAtIndexPath:(NSIndexPath *)indexPath
         touchLocation:(CGPoint)touchLocation {
  NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - KNTelephatyServiceDelegate

- (void)telephatyServiceDidReceiveMessage:(NSString *)message {
  
  [self didPressSendButton:nil withMessageText:message senderId:@"---" senderDisplayName:@"" date:[NSDate date]];
}

@end
