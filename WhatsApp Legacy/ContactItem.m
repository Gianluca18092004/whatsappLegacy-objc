//
//  ContactItem.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 30/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ContactItem.h"
#import "ContactIImgViewController.h"
#import "ProfileViewController.h"
#import "WhatsAppAPI.h"

@interface ContactItem ()
@property (retain) AppDelegate *appDelegate;
@end

@implementation ContactItem
@synthesize profileName, profileAbout, profileImg, contactNumber, navigationController, largeImage, appDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.profileImg.layer.cornerRadius = 6;
    self.profileImg.clipsToBounds = YES;

    // Configure the view for the selected state
}

- (IBAction)viewImg:(id)sender {
    [self performSelectorInBackground:@selector(fetchContactInfo) withObject:nil];
}

- (void)fetchContactInfo {
    // Obtén la información del contacto en segundo plano
    appDelegate.activeProfileView = [WhatsAppAPI getContactInfo:self.contactNumber];
    
    // Actualiza la interfaz de usuario en el hilo principal
    [self performSelectorOnMainThread:@selector(updateProfileView) withObject:nil waitUntilDone:NO];
}

- (void)updateProfileView {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.contactNumber = self.contactNumber;
    profileViewController.title = self.profileName.text;
    profileViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    profileViewController.profileImg.image = self.largeImage;
    [profileViewController release];
}

- (void)dealloc {
    [profileImg release];
    [super dealloc];
}

@end
