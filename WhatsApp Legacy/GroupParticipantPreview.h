//
//  GroupParticipantPreview.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 10/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupParticipantPreview : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *profileNumber;
@property (retain, nonatomic) IBOutlet UILabel *profileName;
@property (retain, nonatomic) IBOutlet UILabel *profileAbout;
@property (retain, nonatomic) IBOutlet UIButton *profileImg;
@property (retain, nonatomic) IBOutlet UIImageView *profileAdmin;
@property (retain, nonatomic) IBOutlet UINavigationController *navigationController;
@property (assign) NSString *contactNumber;
@property (retain, nonatomic) UIImage *largeImage;

@end
