//
//  JSBubbleView.h
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

extern CGFloat const kJSAvatarSize;
extern CGFloat const kJSUserNameSize;

typedef enum {
    JSBubbleMessageTypeIncoming = 0,
    JSBubbleMessageTypeOutgoing
} JSBubbleMessageType;


@interface JSBubbleView : UIView

@property (assign, nonatomic) JSBubbleMessageType type;
@property (copy, nonatomic) NSString *userName;
@property (assign, nonatomic) BOOL showUser;
@property (copy, nonatomic) NSString *msgId;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *quotedText;
@property (copy, nonatomic) NSDate *timestamp;
@property (assign, nonatomic) NSInteger ack;
@property (assign, nonatomic) BOOL selectedToShowCopyMenu;
@property (assign, nonatomic) BOOL hasReply;
@property (assign, nonatomic) BOOL hasMedia;
@property (assign, nonatomic) UIView* mediaView;

#pragma mark - Initialization
- (id)msgId:(NSString *)msgId
      showUser:(BOOL)showUser
     withFrame:(CGRect)rect
    bubbleType:(JSBubbleMessageType)bubleType
      hasReply:(BOOL)hasReply
      hasMedia:(BOOL)hasMedia
     mediaView:(UIView *)mediaView;

#pragma mark - Drawing
- (CGRect)bubbleFrame;
- (UIImage *)bubbleImage;
- (UIImage *)bubbleImageHighlighted;

#pragma mark - Bubble view

+ (UIFont *)font;

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)boldTextSizeForText:(NSString *)txt;
+ (CGSize)bubbleSizeForText:(NSString *)txt withUser:(NSString *)user withMediaWidth:(CGFloat)mediaWidth andReply:(NSString *)reply;
+ (CGFloat)cellHeightForText:(NSString *)txt andQuotedText:(NSString *)quoted;

+ (int)maxCharactersPerLine;
+ (int)numberOfLinesForMessage:(NSString *)txt;

@end