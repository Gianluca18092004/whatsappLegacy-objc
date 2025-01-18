//
//  GroupCommonPreview.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 20/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCommonPreview : UITableViewCell
@property (retain, nonatomic) IBOutlet UIButton *profileImg;
@property (retain, nonatomic) IBOutlet UILabel *profileName;
@property (retain, nonatomic) IBOutlet UILabel *profileAbout;
@property (retain, nonatomic) IBOutlet UINavigationController *navigationController;
@property (assign) NSString *contactNumber;
@property (retain, nonatomic) UIImage *largeImage;

@end
