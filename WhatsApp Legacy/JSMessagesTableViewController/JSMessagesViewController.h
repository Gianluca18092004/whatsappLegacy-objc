//
//  JSMessagesViewController.h
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "JSBubbleMessageCell.h"
#import "JSMessageInputView.h"
#import "JSMessageAttachView.h"
#import "JSMessageSoundEffect.h"
#import "UIButton+JSMessagesView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(_v)  ( floor(NSFoundationVersionNumber) >= _v ? YES : NO )

typedef enum {
    JSMessagesViewTimestampPolicyAll = 0,
    JSMessagesViewTimestampPolicyAlternating,
    JSMessagesViewTimestampPolicyEveryThree,
    JSMessagesViewTimestampPolicyEveryFive,
    JSMessagesViewTimestampPolicyEveryDay,
    JSMessagesViewTimestampPolicyCustom
} JSMessagesViewTimestampPolicy;


typedef enum {
    JSMessagesViewAvatarPolicyIncomingOnly = 0,
    JSMessagesViewAvatarPolicyBoth,
    JSMessagesViewAvatarPolicyNone
} JSMessagesViewAvatarPolicy;


@protocol JSMessagesViewDelegate <NSObject>
@required
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text;
- (void)attachPressed:(UIButton *)sender;
- (void)voiceNoteStatus;
- (void)voiceNoteClear;
- (void)finishSendVoiceNote;
- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath;
- (JSMessagesViewTimestampPolicy)timestampPolicy;
- (JSMessagesViewAvatarPolicy)avatarPolicy;
- (BOOL)showUserPolicyForRowAtIndexPath:(NSIndexPath *)indexPath;
- (JSAvatarStyle)avatarStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)hasMediaForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)hasReplyForRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@protocol JSMessagesViewDataSource <NSObject>
@required
- (NSString *)msgIdForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger *)ackForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)userNameForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)avatarImageForIncomingMessageForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)avatarImageForOutgoingMessage;

@optional
- (NSString *)quotedTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)quotedUserNameForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)mediaViewForRowAtIndexPath:(NSIndexPath *)indexPath;
@end



@interface JSMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) id<JSMessagesViewDelegate> delegate;
@property (retain, nonatomic) id<JSMessagesViewDataSource> dataSource;
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) JSMessageInputView *inputToolBarView;
@property (retain, nonatomic) JSMessageAttachView *attachToolBarView;
@property (nonatomic) CGFloat previousTextViewContentHeight;
@property (nonatomic) BOOL isGroup;
@property (nonatomic) BOOL isReadOnly;
@property (copy, nonatomic) NSArray *chatContacts;
@property (assign, nonatomic) BOOL keyboardIsShowing;

#pragma mark - Initialization
- (UIButton *)sendButton;
- (UIButton *)attachButton;
- (UIButton *)voiceNoteButton;

#pragma mark - Actions
- (void)sendPressed:(UIButton *)sender;
- (void)voiceNoteDown:(UIButton *)sender;
//- (void)voiceNotePressed:(UIButton *)sender;

#pragma mark - Messages view controller
- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldHaveAvatarForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldShowUserName:(NSIndexPath *)indexPath;
- (BOOL)shouldHasMedia:(NSIndexPath *)indexPath;
- (void)finishSend;
- (void)setBackgroundColor:(UIColor *)color;
- (void)scrollToBottomAnimated:(BOOL)animated;

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification;
- (void)handleWillHideKeyboard:(NSNotification *)notification;
- (void)keyboardWillShowHide:(NSNotification *)notification;

@end