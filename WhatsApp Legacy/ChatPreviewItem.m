//
//  ChatPreviewItem.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ChatPreviewItem.h"
#import "ProfileViewController.h"
#import "ContactIImgViewController.h"
#import "WhatsAppAPI.h"

@interface ChatPreviewItem ()
@property (retain) AppDelegate *appDelegate;
@property (assign) NSInteger _ackState;
@property (assign) WSPMsgMediaType _messageMediaType;
@end

@implementation ChatPreviewItem
@synthesize appDelegate;
@synthesize navigationController;
@synthesize contactNumber;
@synthesize _ackState;
@synthesize ackState;
@synthesize _messageMediaType;
@synthesize messageMediaType;
@synthesize timestamp;
@synthesize largeImage;
@synthesize mutedImg;
@synthesize isGroup;
@synthesize profileImg;
@synthesize profileName;
@synthesize profileLastUser;
@synthesize profileLastAck;
@synthesize profileLastMsg;
@synthesize profileLastHour;
@synthesize profileUnread;
@synthesize profileMediaType;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float estimatedAccesoryX = MAX(self.textLabel.frame.origin.x + self.textLabel.frame.size.width, self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width);
    
    for (UIView *subview in self.subviews) {
        if (subview != self.textLabel &&
            subview != self.detailTextLabel &&
            subview != self.backgroundView &&
            subview != self.contentView &&
            subview != self.selectedBackgroundView &&
            subview != self.imageView &&
            subview.frame.origin.x > estimatedAccesoryX) {
            
            // This subview should be the accessory view, change its frame
            CGRect frame = subview.frame;
            frame.origin.y += 12;
            subview.frame = frame;
            [self setNeedsDisplay];
            break;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.profileImg.layer.cornerRadius = 6;
    self.profileImg.clipsToBounds = YES;
    self.profileUnread.layer.cornerRadius = 8;


    // Configure the view for the selected state
}

- (NSInteger)unreadMessages
{
    return [profileUnread.text integerValue];
}

- (IBAction)viewImg:(id)sender {
    [self performSelectorInBackground:@selector(fetchProfileInfo) withObject:nil];
}

// Método que realiza la operación en segundo plano
- (void)fetchProfileInfo {
    if(self.isGroup){
        appDelegate.activeProfileView = [WhatsAppAPI getGroupInfo:self.contactNumber];
    } else {
        appDelegate.activeProfileView = [WhatsAppAPI getContactInfo:self.contactNumber];
    }
    
    // Volver al hilo principal para actualizar la UI
    [self performSelectorOnMainThread:@selector(updateUIWithProfile) withObject:nil waitUntilDone:NO];
}

// Método para actualizar la UI en el hilo principal
- (void)updateUIWithProfile {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.contactNumber = self.contactNumber;
    profileViewController.title = self.profileName.text;
    profileViewController.hidesBottomBarWhenPushed = YES;
    
    // Navegar al nuevo controlador
    [self.navigationController pushViewController:profileViewController animated:YES];
    
    // Asignar la imagen del perfil
    profileViewController.profileImg.image = self.largeImage;
    [profileViewController release];
}

- (void)setUnreadMessages:(NSInteger)unreadMessages
{
    profileUnread.text = [NSString stringWithFormat:@"%d", unreadMessages];
    if(unreadMessages == 0){
        CGRect frame = mutedImg.frame;
        frame.origin = CGPointMake(278,38);
        mutedImg.frame = frame;
        
        profileUnread.hidden = true;
    } else {
        CGRect frame = mutedImg.frame;
        frame.origin = CGPointMake(242,38);
        mutedImg.frame = frame;
        profileUnread.hidden = false;
    }
}

- (NSInteger)ackState {
    return _ackState;
}

- (void)setAckState:(NSInteger)oackState
{
    _ackState = oackState;
    switch (oackState){
        case 2:
            [profileLastAck setImage:[UIImage imageNamed:@"BrdtDoubleCheck.png"]];
            break;
        case 3:
            [profileLastAck setImage:[UIImage imageNamed:@"BrdtReaded.png"]];
            break;
        case 4:
            [profileLastAck setImage:[UIImage imageNamed:@"BrdtReaded.png"]];
            break;
        default:
            [profileLastAck setImage:[UIImage imageNamed:@"BrdtCheck.png"]];
            break;
    }
}

- (BOOL)hideAck {
    return [profileLastAck isHidden];
}

- (void)setHideAck:(BOOL)hideAck {
    [profileLastAck setHidden:hideAck];
}

- (BOOL)hideMedia {
    return [profileMediaType isHidden];
}

- (void)setHideMedia:(BOOL)hideMedia {
    [profileMediaType setHidden:hideMedia];
}

- (NSString *)messageUser {
    return [profileLastUser text];
}

- (void)setMessageUser:(NSString *)messageUser {
    if([messageUser length] == 0){
        [profileLastUser setHidden:YES];
    } else {
        [profileLastUser setText:messageUser];
        [profileLastUser setHidden:NO];
    }
}

- (NSString *)messageText {
    return [profileLastMsg text];
}

- (void)setMessageText:(NSString *)messageText {
    [profileLastMsg setText:messageText];
    [profileMediaType setFrame:CGRectMake(71 + ([profileLastAck isHidden] ? 0 : 22), profileMediaType.frame.origin.y + ([profileLastUser isHidden] ? 0.0f : 18.0f), profileMediaType.frame.size. width, profileMediaType.frame.size.height)];
    [profileLastAck setFrame:CGRectMake(71, profileLastAck.frame.origin.y + ([profileLastUser isHidden] ? 0.0f : 18.0f), profileMediaType.frame.size. width, profileLastAck.frame.size.height)];
    [profileLastMsg setFrame:CGRectMake(71 + ([profileLastAck isHidden] ? 0 : 22) + ([profileMediaType isHidden] ? 0 : 24), profileLastMsg.frame.origin.y + ([profileLastUser isHidden] ? 0.0f : 18.0f), self.frame.size.width - (self.unreadMessages > 0 ? 36.0f : 0.0f) - (![self.mutedImg isHidden] > 0 ? 20.0f : 0.0f) - 98 - ([profileLastAck isHidden] ? 0 : 22) - ([profileMediaType isHidden] ? 0 : 24), 21)];
    [profileLastUser setFrame:CGRectMake(71, profileLastUser.frame.origin.y, self.frame.size.width - (self.unreadMessages > 0 ? 36.0f : 0.0f) - (![self.mutedImg isHidden] > 0 ? 20.0f : 0.0f) - 98 - ([profileLastAck isHidden] ? 0 : 22) - ([profileMediaType isHidden] ? 0 : 24), 21)];
    //[profileLastMsg setBackgroundColor:[UIColor redColor]];
}

- (WSPMsgMediaType)messageMediaType {
    return _messageMediaType;
}

- (void)setMessageMediaType:(WSPMsgMediaType)omessageMediaType {
    _messageMediaType = omessageMediaType;
}

- (void)dealloc {
    [profileLastAck release];
    [profileMediaType release];
    [profileImg release];
    [profileLastUser release];
    [super dealloc];
}
@end
