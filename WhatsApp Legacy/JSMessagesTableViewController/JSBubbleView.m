//
//  JSBubbleView.m
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

#import "JSBubbleView.h"
#import "JSMessageInputView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "CocoaFetch.h"
#import "UnknownMessage.h"
#import "JSBubbleReply.h"

CGFloat const kJSAvatarSize = 50.0f;
CGFloat const kJSUserNameSize = 22.0f;

@interface JSBubbleView()

- (void)setup;

@end



@implementation JSBubbleView

@synthesize type;
@synthesize userName;
@synthesize showUser;
@synthesize text;
@synthesize quotedText;
@synthesize timestamp;
@synthesize ack;
@synthesize selectedToShowCopyMenu;
@synthesize hasReply;
@synthesize hasMedia;
@synthesize mediaView;
@synthesize msgId;

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 24.0f
#define kBubblePaddingRight 35.0f

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization
- (id)msgId:(NSString *)oMsgId
   showUser:(BOOL)oShowUser
     withFrame:(CGRect)rect
    bubbleType:(JSBubbleMessageType)bubleType
      hasReply:(BOOL)oHasReply
      hasMedia:(BOOL)oHasMedia
     mediaView:(UIView *)oMediaView
{
    self = [super initWithFrame:rect];
    if(self) {
        [self setup];
        self.msgId = oMsgId;
        self.showUser = oShowUser;
        self.type = bubleType;
        self.hasReply = oHasReply;
        self.hasMedia = oHasMedia;
        self.mediaView = oMediaView;
        [self addSubview:self.mediaView];
        if (self.mediaView.tag == (NSInteger)@"StickerMessage") {
            [self sendSubviewToBack:self.mediaView];
        }

    }
    return self;
}

- (void)dealloc
{
    [userName release];
    [msgId release];
    [text release];
    [quotedText release];
    [timestamp release];
    [mediaView release];
    [super dealloc];
}

#pragma mark - Setters
- (void)setType:(JSBubbleMessageType)newType {
    type = newType;
    [self setNeedsDisplay];
}

- (void)setUserName:(NSString *)newUserName {
    if (userName != newUserName) {
        [userName release];
        userName = [newUserName retain];
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)newText {
    if (text != newText) {
        [text release];
        text = [newText retain];
        [self setNeedsDisplay];
    }
}

- (void)setQuotedText:(NSString *)newQuotedText {
    if (quotedText != newQuotedText) {
        [quotedText release];
        quotedText = [newQuotedText retain];
        [self setNeedsDisplay];
    }
}

- (void)setTimestamp:(NSDate *)newTimestamp {
    if (timestamp != newTimestamp) {
        [timestamp release];
        timestamp = [newTimestamp retain];
        [self setNeedsDisplay];
    }
}

- (void)setAck:(NSInteger)newAck {
    ack = newAck;
    [self setNeedsDisplay];
}

- (void)setSelectedToShowCopyMenu:(BOOL)isSelected {
    selectedToShowCopyMenu = isSelected;
    [self setNeedsDisplay];
}

- (void)setHasMedia:(BOOL)newHasMedia {
    hasMedia = newHasMedia;
    [self setNeedsDisplay];
}

- (void)setMediaView:(UIView *)newMediaView {
    mediaView = newMediaView;
    [self setNeedsDisplay];
}

/*- (void)setUserShow:(BOOL)isShow {
    userShow = isShow;
    kJSShowUser = isShow;
    [self setNeedsDisplay];
}*/

#pragma mark - Drawing
- (CGRect)bubbleFrame {
    CGFloat userHeight = (self.showUser == true ? kJSUserNameSize : 0.0f);
    CGFloat mediaWidth = (self.hasMedia == true ? self.mediaView.frame.size.width + 35.0f : 0.0f);
    CGFloat mediaHeight = (self.hasMedia == true ? self.mediaView.frame.size.height : 0.0f);
    CGSize bubbleSize = [JSBubbleView bubbleSizeForText:self.text withUser:self.userName withMediaWidth:mediaWidth andReply:self.quotedText];
    return CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - MAX(bubbleSize.width,mediaWidth) : 0.0f),
                      kMarginTop,
                      MAX(bubbleSize.width,mediaWidth),
                      bubbleSize.height + userHeight + mediaHeight - (self.mediaView.tag == (NSInteger)@"VoiceNoteMessage" ? 17.0f : 0.0f));
}

- (UIImage *)bubbleImage {
    if (self.mediaView.tag == (NSInteger)@"StickerMessage") {
        return (self.type == JSBubbleMessageTypeIncoming) ? [UIImage bubbleStickerIncoming] : [UIImage bubbleStickerOutgoing];
    } else {
        return (self.type == JSBubbleMessageTypeIncoming) ? [UIImage bubbleSquareIncoming] : [UIImage bubbleSquareOutgoing];
    }
}

- (UIImage *)bubbleImageHighlighted {
    if (self.mediaView.tag == (NSInteger)@"StickerMessage") {
        return [UIImage bubbleStickerSelected];
    } else {
        return (self.type == JSBubbleMessageTypeIncoming) ? [UIImage bubbleSquareIncomingSelected] : [UIImage bubbleSquareOutgoingSelected];
    }
}

- (void)drawRect:(CGRect)frame
{
    [super drawRect:frame];
    UIImage *image;
    CGRect bubbleFrame = [self bubbleFrame];
    image = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    
    if (!(self.mediaView.tag == (NSInteger)@"StickerMessage")){
        [image drawInRect:bubbleFrame];
    }
	
    CGFloat mediaWidth = (self.hasMedia == true ? self.mediaView.frame.size.width : 0.0f);
    CGSize textSize = [JSBubbleView textSizeForText:self.text];
    CGSize userSize = [JSBubbleView boldTextSizeForText:self.userName];
    CGSize replySize = [JSBubbleReply bubbleSizeForText:self.quotedText withParentText:self.text withUser:@""];
    
    if(userSize.width > textSize.width){
        textSize = CGSizeMake(userSize.width, textSize.height);
    }
    if(replySize.width - 12.0f > textSize.width){
        textSize = CGSizeMake(replySize.width - 12.0f, textSize.height);
    }
    if(mediaWidth != 0.0f && mediaWidth != textSize.width){
        textSize = CGSizeMake(mediaWidth, textSize.height);
    }
    
	CGSize timeStampSize = [JSBubbleView textSizeForText:[CocoaFetch stringWithTime:self.timestamp]];
	
    CGFloat textX = image.leftCapWidth - 3.0f + (self.type == JSBubbleMessageTypeOutgoing ? bubbleFrame.origin.x : 0.0f);
    self.mediaView.frame = CGRectMake(textX,kPaddingTop + kMarginTop + (self.showUser == true ? kJSUserNameSize : 0.0f),mediaWidth,self.mediaView.frame.size.height);
    
    CGRect textFrame = CGRectMake(textX,
                                  kPaddingTop + kMarginTop + (self.showUser == true ? kJSUserNameSize : 0.0f) + (self.hasReply ? replySize.height + kPaddingTop : 0.0f) + (self.hasMedia == true ? self.mediaView.frame.size.height : 0.0f),
                                  textSize.width,
                                  textSize.height);
    
    CGRect timeStampFrame = CGRectMake(textX,
                                       kPaddingTop + kMarginTop + kPaddingTop + textFrame.size.height + (self.showUser == true ? kJSUserNameSize : 0.0f) + (self.hasReply ? replySize.height + kPaddingTop : 0.0f) + (self.hasMedia == true ? self.mediaView.frame.size.height : 0.0f) - (self.mediaView.tag == (NSInteger)@"VoiceNoteMessage" ? 17.0f : 0.0f),
                                       (type == JSBubbleMessageTypeOutgoing && self.mediaView.tag != (NSInteger)@"DeletedMessage" ? textSize.width - 20 : textSize.width),
                                       timeStampSize.height);
    
    
    if (self.mediaView.tag == (NSInteger)@"StickerMessage"){
        [image drawInRect:CGRectMake(self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - timeStampSize.width - 24.0f : 220 - timeStampSize.width - 24.0f,185 + (self.showUser == true ? kJSUserNameSize : 0.0f),timeStampSize.width + (self.type == JSBubbleMessageTypeOutgoing ? 12.0f : 0.0f),25)];
    }
    
    CGRect userFrame = CGRectMake(textX, kPaddingTop + kMarginTop, userSize.width, kJSUserNameSize);
    
    if(self.type == JSBubbleMessageTypeOutgoing && self.mediaView.tag != (NSInteger)@"DeletedMessage"){
        UIImage *smallImage;
        switch (self.ack){
            case 2:
                smallImage = [UIImage imageNamed:@"BrdtDoubleCheck.png"];
                break;
            case 3:
                smallImage = [UIImage imageNamed:@"BrdtReaded.png"];
                break;
            case 4:
                smallImage = [UIImage imageNamed:@"BrdtReaded.png"];
                break;
            default:
                smallImage = [UIImage imageNamed:@"BrdtCheck.png"];
                break;
        }
        
        CGRect imageFrame = CGRectMake(CGRectGetMaxX(timeStampFrame) + 5,
                                       CGRectGetMidY(timeStampFrame) - 8,
                                       20,
                                       12);
        
        [smallImage drawInRect:imageFrame];
    }
    
	[self.text drawInRect:textFrame
                 withFont:[JSBubbleView font]
            lineBreakMode:UILineBreakModeWordWrap
                alignment:UITextAlignmentLeft];
    [[UIColor darkGrayColor] set];
	[[CocoaFetch stringWithTime:self.timestamp] drawInRect:timeStampFrame
                                                  withFont:[UIFont italicSystemFontOfSize:12.0f]
                                             lineBreakMode:UILineBreakModeClip
                                                 alignment:UITextAlignmentRight];
    if(self.showUser == true){
        UIColor *userColor;
        switch ([CocoaFetch singleDigitFromString:self.userName]) {
            case 0:
                userColor = [CocoaFetch colorFromHexString:@"#E53935"];
                break;
            case 1:
                userColor = [CocoaFetch colorFromHexString:@"#D81B60"];
                break;
            case 2:
                userColor = [CocoaFetch colorFromHexString:@"#5E35B1"];
                break;
            case 3:
                userColor = [CocoaFetch colorFromHexString:@"#3949AB"];
                break;
            case 4:
                userColor = [CocoaFetch colorFromHexString:@"#0277BD"];
                break;
            case 5:
                userColor = [CocoaFetch colorFromHexString:@"#00897B"];
                break;
            case 6:
                userColor = [CocoaFetch colorFromHexString:@"#43A047"];
                break;
            case 7:
                userColor = [CocoaFetch colorFromHexString:@"#7CB342"];
                break;
            case 8:
                userColor = [CocoaFetch colorFromHexString:@"#FB8C00"];
                break;
            case 9:
                userColor = [CocoaFetch colorFromHexString:@"#6D4C41"];
                break;
            default:
                userColor = [UIColor darkGrayColor];
                break;
        }
        [userColor set];
        [self.userName drawInRect:userFrame
                         withFont:[UIFont boldSystemFontOfSize:16.0f]
                    lineBreakMode:UILineBreakModeClip
                        alignment:UITextAlignmentLeft];
        
    }
}

#pragma mark - Bubble view

+ (UIFont *)font
{
    return [UIFont systemFontOfSize:16.0f];
}

+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat maxHeight = MAX([JSBubbleView numberOfLinesForMessage:txt],
                            [txt numberOfLines]) * [JSMessageInputView textViewLineHeight];
    
    CGSize textSize = [txt sizeWithFont:[JSBubbleView font]
                      constrainedToSize:CGSizeMake(maxWidth - kJSAvatarSize, maxHeight + kJSAvatarSize)
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat minWidth = 72.0f;
    CGFloat adjustedWidth = MAX(textSize.width, minWidth);
    
    return CGSizeMake(adjustedWidth, textSize.height);
}

+ (CGSize)boldTextSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat maxHeight = MAX([JSBubbleView numberOfLinesForMessage:txt],
                            [txt numberOfLines]) * [JSMessageInputView textViewLineHeight];
    
    CGSize textSize = [txt sizeWithFont:[UIFont boldSystemFontOfSize:16.0f]
                      constrainedToSize:CGSizeMake(maxWidth - kJSAvatarSize, maxHeight + kJSAvatarSize)
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat minWidth = 72.0f;
    CGFloat adjustedWidth = MAX(textSize.width, minWidth);
    
    return CGSizeMake(adjustedWidth, textSize.height);
}

+ (CGSize)bubbleSizeForText:(NSString *)txt withUser:(NSString *)user withMediaWidth:(CGFloat)mediaWidth andReply:(NSString *)reply
{
    CGSize textSize = [JSBubbleView textSizeForText:txt];
    CGSize userSize = [JSBubbleView boldTextSizeForText:user];
    CGSize replySize = [JSBubbleReply bubbleSizeForText:reply withParentText:txt withUser:@""];
    
    CGFloat minWidth = 72.0f;
    CGFloat bubbleWidth = MAX((MAX(textSize.width, replySize.width - 12.0f) > userSize.width ? MAX(textSize.width, replySize.width - 12.0f)  : userSize.width) + kBubblePaddingRight, minWidth);
    
    return CGSizeMake(bubbleWidth,
                      textSize.height + (reply != nil && reply != NULL && [reply length] > 0 ? replySize.height + kPaddingTop : 0.0f) + kPaddingTop + kPaddingBottom);
}
+ (CGFloat)cellHeightForText:(NSString *)txt andQuotedText:(NSString *)quoted
{
    return [JSBubbleView bubbleSizeForText:txt withUser:@"" withMediaWidth:0.0f andReply:quoted].height + kMarginTop + kMarginBottom;
}

+ (int)maxCharactersPerLine
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]){
        return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
    } else {
        return 33;
    }
}

+ (int)numberOfLinesForMessage:(NSString *)txt
{
    return (txt.length / [JSBubbleView maxCharactersPerLine]) + 1;
}

@end