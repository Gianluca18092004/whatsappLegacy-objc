//
//  JSBubbleMessageCell.h
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
#import "JSBubbleView.h"
#import "JSBubbleTimestamp.h"

typedef enum {
    JSAvatarStyleCircle = 0,
    JSAvatarStyleSquare,
    JSAvatarStyleSemiCircle,
    JSAvatarStyleNone
} JSAvatarStyle;


@interface JSBubbleMessageCell : UITableViewCell

#pragma mark - Initialization
- (id)initWithBubbleType:(JSBubbleMessageType)type
                   msgId:(NSString *)msgId
             avatarStyle:(JSAvatarStyle)avatarStyle
            hasTimestamp:(BOOL)hasTimestamp
                showUser:(BOOL)showUser
                hasReply:(BOOL)hasReply
                hasMedia:(BOOL)hasMedia
               mediaView:(UIView *)mediaView
         reuseIdentifier:(NSString *)reuseIdentifier;

#pragma mark - Message cell
- (void)setUserWrited:(NSString *)user;
- (void)setQuotedUser:(NSString *)user;
- (void)setMessage:(NSString *)msg;
- (void)setQuotedMessage:(NSString *)msg;
- (void)setTimestamp:(NSDate *)date;
- (void)setAvatarImage:(UIImage *)image;
- (void)setAck:(NSInteger *)ack;
- (void)setIsAudioNextMessage:(BOOL)isAudio;

+ (CGFloat)neededHeightForText:(NSString *)bubbleViewText
                     timestamp:(BOOL)hasTimestamp
                        avatar:(BOOL)hasAvatar
                      userName:(BOOL)showUserName
                         media:(BOOL)hasMedia
                     mediaHeight:(CGFloat)mediaHeight
                    quotedText:(NSString *)quotedText;

@end