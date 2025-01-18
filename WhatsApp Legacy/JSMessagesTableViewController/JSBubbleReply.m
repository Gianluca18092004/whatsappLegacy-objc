//
//  JSBubbleReply.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "JSBubbleReply.h"
#import "JSBubbleView.h"
#import "JSMessageInputView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "CocoaFetch.h"

CGFloat const kJSMiniUserNameSize = 21.0f;

@interface JSBubbleReply()

- (void)setup;

@end



@implementation JSBubbleReply
@synthesize type, userName, text, parentText, showUser, isAttached, msgId;

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 24.0f
#define kPaddingLeft 16.0f
#define kBubblePaddingRight 35.0f

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (id)showUser:(BOOL)oShowUser
     withFrame:(CGRect)rect
    bubbleType:(JSBubbleMessageType)bubbleType
{
    self = [super initWithFrame:rect];
    if (self) {
        [self setup];
        self.showUser = oShowUser;
        self.type = bubbleType;
        self.isAttached = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if (self) {
        [self setup];
        self.showUser = YES;
        self.isAttached = YES;
    }
    return self;
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

- (void)setParentText:(NSString *)newParentText {
    if (parentText != newParentText) {
        [parentText release];
        parentText = [newParentText retain];
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)frame
{
    [super drawRect:frame];
    
    // Dibuja la imagen de burbuja
    UIImage *image = [self bubbleImage];
    CGRect bubbleFrame = [self bubbleFrame];
    [image drawInRect:bubbleFrame];
    
    CGSize textSize = [JSBubbleReply textSizeForText:self.text];
    CGSize userSize = [JSBubbleReply boldTextSizeForText:self.userName];
    
    if(userSize.width > textSize.width){
        textSize = CGSizeMake(userSize.width, textSize.height);
    }
    
    CGFloat textX = image.leftCapWidth - 3.0f + (self.type == JSBubbleMessageTypeOutgoing ? bubbleFrame.origin.x + kPaddingTop : kPaddingLeft + 3.0f);
    
    CGRect textFrame;
    if (self.isAttached == YES){
        textFrame = CGRectMake(textX,
                               kPaddingTop + kJSMiniUserNameSize + (self.showUser == true ? kJSUserNameSize + 5.0f : 5.0f),
                               textSize.width,
                               textSize.height);
    } else {
        textFrame = CGRectMake(textX,
                               kPaddingTop + kMarginTop + kJSMiniUserNameSize + (self.showUser == true ? kJSUserNameSize + 5.0f : 5.0f),
                               textSize.width,
                               textSize.height);
    }
    
    CGRect userFrame;
    if (self.isAttached == YES){
        userFrame = CGRectMake(textX, kPaddingTop + (self.showUser == true ? kJSUserNameSize + 5.0f : 5.0f), userSize.width, kJSMiniUserNameSize);
    } else {
        userFrame = CGRectMake(textX, kPaddingTop + kMarginTop + (self.showUser == true ? kJSUserNameSize + 5.0f : 5.0f), userSize.width, kJSMiniUserNameSize);
    }
    
    
	[self.text drawInRect:textFrame
                 withFont:[UIFont systemFontOfSize:14.0f]
            lineBreakMode:UILineBreakModeWordWrap
                alignment:UITextAlignmentLeft];
    
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
                     withFont:[UIFont boldSystemFontOfSize:14.0f]
                lineBreakMode:UILineBreakModeClip
                    alignment:UITextAlignmentLeft];
}

- (CGRect)bubbleFrame {
    CGFloat userHeight = (self.showUser == true ? kJSUserNameSize + 5.0f : 5.0f);
    CGSize bubbleSize = [JSBubbleReply bubbleSizeForText:self.text withParentText:self.parentText withUser:self.userName];
    if (self.isAttached == YES){
        return CGRectMake(6.0f,
                          userHeight,
                          self.frame.size.width - 12.0f,
                          self.frame.size.height - 32.0f);
    } else {
        return CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width- kPaddingLeft : kPaddingLeft),
                          kMarginTop + userHeight,
                          bubbleSize.width,
                          bubbleSize.height);
    }
}

- (UIImage *)bubbleImage {
    return [UIImage bubbleSquareReply];
}

#pragma mark - Bubble view

+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat maxHeight = MAX([JSBubbleReply numberOfLinesForMessage:txt],
                            [txt numberOfLines]) * [JSMessageInputView textViewLineHeight];
    
    CGSize textSize = [txt sizeWithFont:[UIFont systemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(maxWidth, maxHeight)
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat adjustedWidth = textSize.width;
    
    return CGSizeMake(adjustedWidth, textSize.height);
}

+ (CGSize)boldTextSizeForText:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat maxHeight = [JSMessageInputView textViewLineHeight];
    
    CGSize textSize = [txt sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(maxWidth, maxHeight)
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat adjustedWidth = textSize.width;
    
    return CGSizeMake(adjustedWidth, textSize.height);
}

+ (CGSize)bubbleSizeForText:(NSString *)txt withParentText:(NSString *)ptxt withUser:(NSString *)user
{
    CGSize textSize = [JSBubbleReply textSizeForText:txt];
    CGSize parentTextSize = [JSBubbleView textSizeForText:ptxt];
    CGSize userSize = [JSBubbleReply boldTextSizeForText:user];
    
    CGFloat minWidth = 72.0f;
    CGFloat bubbleWidth = MAX(MAX((textSize.width > userSize.width ? textSize.width : userSize.width) + kBubblePaddingRight - kPaddingLeft, minWidth),parentTextSize.width + kPaddingLeft);
    
    return CGSizeMake(bubbleWidth,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

+ (int)maxCharactersPerLine
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]){
        return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 28 : 104;
    } else {
        return 28;
    }
}

+ (int)numberOfLinesForMessage:(NSString *)txt
{
    return (txt.length / [JSBubbleReply maxCharactersPerLine]) + 1;
}

@end
