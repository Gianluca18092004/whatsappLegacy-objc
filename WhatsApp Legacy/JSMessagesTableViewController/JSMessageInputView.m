//
//  JSMessageInputView.m
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

#import "JSMessageInputView.h"
#import "JSBubbleView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "GIFMenu.h"

#define SEND_BUTTON_WIDTH 78.0f
#define IS_IOS32orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)

@interface JSMessageInputView ()

- (void)setup;
- (void)setupTextView;

@end



@implementation JSMessageInputView

@synthesize sendButton, attachButton, voiceNoteButton, inputFieldBack, startTime, textView, hTextView, timer, timeLabel, slideLabel, redMic;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
           delegate:(id<UITextViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    self.frame = frame;
    if(self) {
        [self setup];
        self.hTextView.delegate = delegate;
        self.textView.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.redMic = nil;
    self.sendButton = nil;
    self.slideLabel = nil;
    self.voiceNoteButton = nil;
    [super dealloc];
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    [self.hTextView resignFirstResponder];
    return [super resignFirstResponder];
}
#pragma mark - Setup
- (void)setup
{
    self.image = [UIImage inputBar];
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    [self setupTextView];
}

- (void)setupTextView
{
    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH - 33.0f;
    CGFloat widthSlide = self.frame.size.width - SEND_BUTTON_WIDTH - 100.0f;
    CGFloat height = [JSMessageInputView textViewLineHeight];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(43.0f, 3.0f, width, height)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.textView.scrollEnabled = YES;
    self.textView.scrollsToTop = NO;
    self.textView.userInteractionEnabled = YES;
    self.textView.font = [JSBubbleView font];
    self.textView.textColor = [UIColor blackColor];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.returnKeyType = UIReturnKeyDefault;
    [self addSubview:self.textView];
    
    GIFMenu *gifMenu = [[GIFMenu alloc] init];
    
    if (IS_IOS32orHIGHER){
        self.hTextView = [[UITextView alloc] init];
        self.hTextView.inputView = gifMenu;
        [self addSubview:self.hTextView];
    }
    
    self.redMic = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 6.0f, 18.0f, 29.0f)];
    [self.redMic setImage:[UIImage imageNamed:@"MicRecRed.png"]];
    self.redMic.hidden = YES;
    [self addSubview:self.redMic];
    
    self.timeLabel = [[UILabel  alloc] initWithFrame:CGRectMake(43.0f, 3.0f, width, height + 4.0f)];
    self.timeLabel.font = [UIFont systemFontOfSize:22.0f];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.shadowOffset = CGSizeMake(0, 1);
    self.timeLabel.shadowColor = [UIColor whiteColor];
    self.timeLabel.hidden = YES;
    [self addSubview:self.timeLabel];
    
    self.slideLabel = [[UILabel  alloc] initWithFrame:CGRectMake(100.0f, 5.0f, widthSlide, height + 4.0f)];
    self.slideLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.slideLabel.textColor = [UIColor blackColor];
    self.slideLabel.backgroundColor = [UIColor clearColor];
    self.slideLabel.shadowOffset = CGSizeMake(0, 1);
    self.slideLabel.shadowColor = [UIColor whiteColor];
    self.slideLabel.text = @"slide to cancel";
    self.slideLabel.hidden = YES;
    [self addSubview:self.slideLabel];
	
    self.inputFieldBack = [[UIImageView alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x - 1.0f,
                                                                                0.0f,
                                                                                self.textView.frame.size.width + 2.0f,
                                                                                self.frame.size.height)];
    self.inputFieldBack.image = [UIImage inputField];
    self.inputFieldBack.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.inputFieldBack.backgroundColor = [UIColor clearColor];
    [self addSubview:self.inputFieldBack];
}

#pragma mark - Setters
- (void)setSendButton:(UIButton *)btn
{
    if(sendButton)
        [sendButton removeFromSuperview];
    
    sendButton = btn;
    [self addSubview:self.sendButton];
}

- (void)setAttachButton:(UIButton *)btn
{
    if(attachButton)
        [attachButton removeFromSuperview];
    
    attachButton = btn;
    [self addSubview:self.attachButton];
}

- (void)setVoiceNoteButton:(UIButton *)btn
{
    if(voiceNoteButton)
        [voiceNoteButton removeFromSuperview];
    
    voiceNoteButton = btn;
    [self addSubview:self.voiceNoteButton];
}

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    int numLines = MAX([JSBubbleView numberOfLinesForMessage:self.textView.text],
                       [self.textView.text numberOfLines]);
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    self.textView.scrollEnabled = (numLines >= 4);
    
    if(numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 30.0f; // for fontSize 15.0f
}

+ (CGFloat)maxLines
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]){
        return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 4.0f : 8.0f;
    } else {
        return 4.0f;
    }
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

@end