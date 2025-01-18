//
//  JSMessageAttachView.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBubbleReply.h"

@interface JSMessageAttachView : UIImageView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
           delegate:(id<UITextViewDelegate>)delegate;
@property (retain, nonatomic) UIButton* closeAttachView;
@property (retain, nonatomic) JSBubbleReply* bubbleReply;

@property (copy, nonatomic) NSString *msgId;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *userName;

@end
