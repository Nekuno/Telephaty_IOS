//
//  KNMessagesViewController.m
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "KNMessagesViewController.h"

#import "KNCoreDataService.h"
#import "MessageDataUtils.h"


static const NSInteger kInitialNumbersOfJumps     = 8;
static const NSInteger kAlertPrivateMessage       = 90;
static const NSInteger kAlertRemoveAllMessages    = 80;

@interface KNMessagesViewController () <KNTelephatyServiceDelegate>

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) NSDateFormatter *dateformatter;

@end

@implementation KNMessagesViewController {
  
  JSQMessage *_messageSelected;
}

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

  for (MessageData *msg  in localMsgs) {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:msg.transmitter
                                                     senderDisplayName:@""
                                                                  date:[self.dateformatter dateFromString:msg.date]
                                                                  text:msg.message];
    [self.messages addObject:message];
  }
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.inputToolbar.contentView.leftBarButtonItem.hidden = YES;
  self.messages = [NSMutableArray array];
  [self loadLocalMessages];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearMessages:)];
  
  // Settings of JSQMessagesViewController
  self.senderId = [[AppDelegate sharedDelegate].telephatyService identifier];
  self.senderDisplayName = @"Telephaty_user";
  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
  self.automaticallyScrollsToMostRecentMessage = YES;
  
  /**
   *  Create message bubble images objects.
   */
  JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
  
  self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
  self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
  
  [[AppDelegate sharedDelegate].telephatyService setDelegateService:self];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:kNotificationRemovedOldMessages object:nil];
  
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRemovedOldMessages object:nil];
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

  [JSQSystemSoundPlayer jsq_playMessageSentSound];
  
  JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                                   senderDisplayName:senderDisplayName
                                                                date:date
                                                                text:text];
  
  if (button) {
    [[AppDelegate sharedDelegate].telephatyService sendMessage:text withJumps:kInitialNumbersOfJumps];
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
  
  JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
  
  if ([message.senderId isEqualToString:self.senderId]) {
    return self.outgoingBubbleImageData;
  }
  
  return self.incomingBubbleImageData;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.item % 3 == 0) {
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
  }
  
  return nil;
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

  JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
  
  JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
  
  if ([msg isKindOfClass:[JSQMessage class]]) {
    
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
didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
  
  _messageSelected = self.messages[indexPath.item];
  
  [[[UIAlertView alloc] initWithTitle:@"Telephaty" message:@"What Do you want to do?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"SEND PRIVATE MESSAGE", @"DELETE",@"RESEND", nil] show];
}


#pragma mark - Actions

- (void)clearMessages:(id)sender{
  
  UIAlertView *alert =   [[UIAlertView alloc] initWithTitle:@"Telephaty" message:@"Are you sure, you want remove all messages from Data Base? This action is not reversible" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
  alert.tag = kAlertRemoveAllMessages;
  [alert show];
}

- (void)updateUI:(id)sender{
  
  [self.messages removeAllObjects];
  [self loadLocalMessages];
  [self.collectionView reloadData];
  
}


#pragma mark - KNTelephatyServiceDelegate

- (void)telephatyServiceDidReceiveMessage:(MessageData *)message {
  
  [self didPressSendButton:nil withMessageText:message.message senderId:message.transmitter senderDisplayName:@"" date:[self.dateformatter dateFromString:message.date]];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
  
  if (alertView.numberOfButtons == 4) {
    
    switch (buttonIndex) {
      case 1: {
        UIAlertView *alert =   [[UIAlertView alloc] initWithTitle:@"Telephaty" message:@"Write your private message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"SEND MESSAGE", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = kAlertPrivateMessage;
        [alert show];
        break;
      }
      case 2: {
        [self.messages removeObject:_messageSelected];
        [MessageDataUtils deleteMessageFromTransmitter:_messageSelected.senderId onDate:[self.dateformatter stringFromDate:_messageSelected.date]];
        _messageSelected = nil;
        [self.collectionView reloadData];
        break;
      }
      case 3: {      
        NSLog(@"Resend message:%@", _messageSelected.text);
        MessageData *msg = [MessageDataUtils fetchMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withDate:[self.dateformatter stringFromDate:_messageSelected.date] andTransmitter:_messageSelected.senderId];
        
        if (msg && [msg.jumps integerValue] > 1) {
          [[AppDelegate sharedDelegate].telephatyService resendMessage:msg];
        }
        _messageSelected = nil;
        break;
      }
      default:
        break;
    }
  } else {
    
    if (buttonIndex == 1) {
      if (alertView.tag == kAlertRemoveAllMessages) {
        
        [self.messages removeAllObjects];
        [self.collectionView reloadData];
        [MessageDataUtils clearAllMessagesFromDataBase];
        
      } else {
        [[AppDelegate sharedDelegate].telephatyService sendMessage:[alertView textFieldAtIndex:0].text withJumps:kInitialNumbersOfJumps to:_messageSelected.senderId];
      }
      _messageSelected = nil;
    }
  }
}

@end
