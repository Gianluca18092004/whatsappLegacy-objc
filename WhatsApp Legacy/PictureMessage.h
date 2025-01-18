//
//  PictureMessage.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 17/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBubbleView.h"

@interface PictureMessage : UIView

- (id)initWithSize:(CGSize)size withId:(NSString *)messageId withFileSize:(NSInteger)fileSize andViewController:(UIViewController *)viewController;
- (void)setup;
@property (retain, nonatomic) IBOutlet UIView* view;
@property (copy, nonatomic) NSString *msgId;
@property (assign, nonatomic) NSInteger msgSize;
@property (retain, nonatomic) IBOutlet UIButton *msgImg;
@property (retain, nonatomic) IBOutlet UIViewController *viewController;
- (void)updateImage:(NSString *)urlString;
- (IBAction)imgTap:(id)sender;
- (IBAction)imgDoubleTap:(id)sender;

@end
