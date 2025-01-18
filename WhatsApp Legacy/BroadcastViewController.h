//
//  BroadcastViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BroadcastProgressView.h"

@interface BroadcastViewController : UIViewController <BroadcastProgressDelegate>
- (IBAction)closeModal:(id)sender;
- (void)downloadImageFromURL:(NSString *)urlString;
- (UIFont *)fontForText:(NSString *)text withMaxFontSize:(CGFloat)maxFontSize inLabelSize:(CGSize)labelSize;
@property (retain, nonatomic) BroadcastProgressView *progressBar;
@property (retain, nonatomic) IBOutlet UIImageView *picImage;
@property (retain, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (retain, nonatomic) IBOutlet UILabel *lblBroadcastBody;
@property (retain, nonatomic) IBOutlet UILabel *lblBroadcastCaption;
@property (retain, nonatomic) NSArray *msgList;
@property (assign) NSString *contactNumber;
@property (assign) NSInteger totalCount;
@property (assign) NSInteger unreadCount;
@property (assign) CGPoint startLocation;

@end
