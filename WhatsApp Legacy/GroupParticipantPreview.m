//
//  GroupParticipantPreview.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 10/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "GroupParticipantPreview.h"
#import "ProfileViewController.h"
#import "WhatsAppAPI.h"

@interface GroupParticipantPreview ()
@property (retain) AppDelegate *appDelegate;
@end

@implementation GroupParticipantPreview
@synthesize profileName, profileNumber, profileAdmin, profileAbout, profileImg, navigationController, appDelegate, contactNumber, largeImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)viewImg:(id)sender {
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.profileImg.layer.cornerRadius = 6;
    self.profileImg.clipsToBounds = YES;

    // Configure the view for the selected state
}

- (void)dealloc {
    [profileImg release];
    [super dealloc];
}

@end
