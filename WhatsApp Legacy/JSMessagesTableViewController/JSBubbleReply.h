//
//  JSBubbleReply.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBubbleView.h"

extern CGFloat const kJSMiniUserNameSize;

@interface JSBubbleReply : UIView

#pragma mark - Initialization
- (id)showUser:(BOOL)oShowUser
     withFrame:(CGRect)rect
    bubbleType:(JSBubbleMessageType)bubbleType;
- (id)initWithFrame:(CGRect)rect;

@property (assign, nonatomic) JSBubbleMessageType type;
@property (copy, nonatomic) NSString *userName;
@property (assign, nonatomic) BOOL showUser;
@property (assign, nonatomic) BOOL isAttached;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *parentText;
@property (copy, nonatomic) NSString *msgId;

#pragma mark - Drawing
- (CGRect)bubbleFrame;
- (UIImage *)bubbleImage;

#pragma mark - Bubble view

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)boldTextSizeForText:(NSString *)txt;
+ (CGSize)bubbleSizeForText:(NSString *)txt withParentText:(NSString *)ptxt withUser:(NSString *)user;

+ (int)maxCharactersPerLine;
+ (int)numberOfLinesForMessage:(NSString *)txt;

@end
