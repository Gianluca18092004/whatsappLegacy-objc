//
//  ProfileViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 02/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UITableViewController
@property (assign) UIImageView *profileImg;
@property (assign, nonatomic) NSString *contactNumber;
@property int participants;
@property BOOL isGroup;
@property BOOL isBlocked;
@property BOOL isReadOnly;

- (NSString *)getAboutText;
@end
