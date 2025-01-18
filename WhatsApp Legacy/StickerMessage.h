//
//  StickerMessage.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 11/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBubbleView.h"

@interface StickerMessage : UIView

- (id)initWithId:(NSString *)messageId;
- (void)setup;
@property (retain, nonatomic) IBOutlet UIView* view;
@property (retain, nonatomic) IBOutlet UIImageView *stickerView;
@property (retain, nonatomic) IBOutlet UIButton *downloadButton;
@property (copy, nonatomic) NSString *msgId;
- (void)updateImage:(NSString *)urlString;
- (IBAction)downloadTap:(id)sender;

@end
