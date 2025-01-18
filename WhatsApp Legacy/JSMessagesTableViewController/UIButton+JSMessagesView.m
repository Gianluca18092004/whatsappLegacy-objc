//
//  UIButton+JSMessagesView.m
//  MessagesDemo
//
//  Created by Jesse Squires on 3/24/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//

#import "UIButton+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"

@implementation UIButton (JSMessagesView)

+ (UIButton *)defaultSendButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
    UIImage *sendBack;
    UIImage *sendBackHighLighted;
    
    if ([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)]) {
        // Para iOS 5 y versiones posteriores
        sendBack = [[UIImage imageNamed:@"send"] resizableImageWithCapInsets:insets];
        sendBackHighLighted = [[UIImage imageNamed:@"send-highlighted"] resizableImageWithCapInsets:insets];
    } else {
        // Para versiones anteriores a iOS 5
        sendBack = [[UIImage imageNamed:@"send.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        sendBackHighLighted = [[UIImage imageNamed:@"send-highlighted.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    }
    [sendButton setBackgroundImage:sendBack forState:UIControlStateNormal];
    [sendButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
    [sendButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
    
    
    NSString *title = NSLocalizedString(@"Send", nil);
    [sendButton setTitle:title forState:UIControlStateNormal];
    [sendButton setTitle:title forState:UIControlStateHighlighted];
    [sendButton setTitle:title forState:UIControlStateDisabled];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [sendButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
    [sendButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
    sendButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    return sendButton;
}

+ (UIButton *)defaultAttachButton
{
    UIButton *attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
    attachButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    UIImage *sendBack;
    UIImage *sendBackHighLighted;
    
    sendBack = [[UIImage imageNamed:@"FileButtonNormal.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    sendBackHighLighted = [[UIImage imageNamed:@"FileButtonPressed.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    [attachButton setBackgroundImage:sendBack forState:UIControlStateNormal];
    [attachButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
    [attachButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
    
    UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [attachButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
    [attachButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
    attachButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    [attachButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [attachButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [attachButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    return attachButton;
}

+ (UIButton *)defaultVoiceNoteButton
{
    UIButton *voiceNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceNoteButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    UIImage *sendBack;    
    sendBack = [[UIImage imageNamed:@"MicBtn.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    [voiceNoteButton setBackgroundImage:sendBack forState:UIControlStateNormal];
    [voiceNoteButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
    [voiceNoteButton setImage:[UIImage imageNamed:@"MicRecBtn.png"] forState:UIControlStateNormal];
    
    UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [voiceNoteButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
    [voiceNoteButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
    voiceNoteButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    [voiceNoteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [voiceNoteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [voiceNoteButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    return voiceNoteButton;
}

@end