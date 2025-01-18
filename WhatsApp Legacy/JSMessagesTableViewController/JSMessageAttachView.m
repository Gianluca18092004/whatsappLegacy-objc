//
//  JSMessageAttachView.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "JSMessageAttachView.h"
#import "UIImage+JSMessagesView.h"
#import "NSString+JSMessagesView.h"
#import "AppDelegate.h"
#import "CocoaFetch.h"

#define INPUT_HEIGHT 40.0f
#define ATTACH_HEIGHT 80.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 24.0f
#define kPaddingLeft 16.0f

@interface JSMessageAttachView ()

- (void)setup;

@end



@implementation JSMessageAttachView
@synthesize closeAttachView, text, userName, msgId, bubbleReply;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
           delegate:(id<UITextViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    self.frame = frame;
    if(self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup
- (void)setup
{
    self.image = [UIImage inputBar];
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    self.closeAttachView = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 29, 0, 29, 29)];
    [self.closeAttachView setBackgroundImage:[UIImage closeNotification] forState:UIControlStateNormal];
    [self.closeAttachView setBackgroundImage:[UIImage closeNotificationSelected] forState:UIControlStateHighlighted];
    bubbleReply = [[JSBubbleReply alloc] initWithFrame:CGRectMake(0, 0, 320, ATTACH_HEIGHT)];
    [self addSubview:bubbleReply];
    [self addSubview:self.closeAttachView];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, appDelegate.chatViewController.view.frame.size.height - (appDelegate.chatViewController.attachToolBarView.hidden == YES ? appDelegate.chatViewController.inputToolBarView.frame.origin.y : appDelegate.chatViewController.attachToolBarView.frame.origin.y) - INPUT_HEIGHT, 0.0f);
    appDelegate.chatViewController.tableView.contentInset = insets;
    appDelegate.chatViewController.tableView.scrollIndicatorInsets = insets;
    [appDelegate.chatViewController scrollToBottomAnimated:YES];
    self.text = @"Gasa Judia";
    self.userName = @"c";
}

- (void)setUserName:(NSString *)newUserName {
    if (userName != newUserName) {
        [userName release];
        userName = [newUserName retain];
        bubbleReply.userName = newUserName;
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)newText {
    if (text != newText) {
        [text release];
        text = [newText retain];
        bubbleReply.text = newText;
        [self setNeedsDisplay];
    }
}

@end
