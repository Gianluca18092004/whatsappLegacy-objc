//
//  JSBubbleTimestamp.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 07/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface oJSBubbleTimestamp : UIView
@property (copy, nonatomic) NSDate *timestamp;

#pragma mark - Initialization
- (id)withFrame:(CGRect)rect;

#pragma mark - Drawing
- (CGRect)bubbleFrame;
- (UIImage *)bubbleImage;

+ (CGSize)textSizeForTimestamp:(NSString *)txt;
+ (CGSize)bubbleSizeForText:(NSString *)txt;

@end
