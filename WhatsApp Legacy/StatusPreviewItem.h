//
//  StatusPreviewItem.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressView.h"

@interface StatusPreviewItem : UITableViewCell
@property (assign) CircularProgressView *circularProgressView;
@property (retain, nonatomic) IBOutlet UILabel *profileName;
@property (retain, nonatomic) IBOutlet UILabel *profileTimestamp;
@property (assign) NSString *contactNumber;
@property (assign) NSInteger totalCount;
@property (assign) NSInteger unreadCount;
@property (retain, nonatomic) UIImage *largeImage;
@end
