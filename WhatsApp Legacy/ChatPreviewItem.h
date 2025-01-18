//
//  ChatPreviewItem.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsAppAPI.h"

@interface ChatPreviewItem : UITableViewCell <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *mutedImg;
@property (retain, nonatomic) IBOutlet UIButton *profileImg;
@property (retain, nonatomic) IBOutlet UILabel *profileName;
@property (retain, nonatomic) IBOutlet UILabel *profileLastUser;
@property (retain, nonatomic) IBOutlet UIImageView *profileLastAck;
@property (retain, nonatomic) IBOutlet UILabel *profileLastMsg;
@property (retain, nonatomic) IBOutlet UILabel *profileLastHour;
@property (retain, nonatomic) IBOutlet UILabel *profileUnread;
@property (retain, nonatomic) IBOutlet UIImageView *profileMediaType;
@property (retain, nonatomic) IBOutlet UINavigationController *navigationController;
@property NSInteger ackState;
@property WSPMsgMediaType messageMediaType;
@property NSInteger unreadMessages;
@property NSInteger timestamp;
@property (assign) NSString *messageUser;
@property (assign) NSString *messageText;
@property (assign) NSString *contactNumber;
@property (retain, nonatomic) UIImage *largeImage;
@property BOOL isGroup;
@property BOOL hideAck;
@property BOOL hideMedia;

- (IBAction)viewImg:(id)sender;
@end