//
//  ProfileViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 02/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "ProfileViewController.h"
#import "ContactIImgViewController.h"
#import "AppDelegate.h"
#import "WhatsAppAPI.h"
#import "CocoaFetch.h"
#import "GroupParticipantPreview.h"
#import "GroupCommonPreview.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]
#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)

@interface ProfileViewController ()
@property (retain) AppDelegate *appDelegate;
@end

@implementation ProfileViewController
@synthesize appDelegate, isGroup, isBlocked, isReadOnly, participants, profileImg, contactNumber;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = -44;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 208, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 208, 24)];
    nameLabel.text = self.title;
    nameLabel.font = [UIFont boldSystemFontOfSize:19];
    nameLabel.textAlignment = UITextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Color de la sombra
    nameLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
    // Configura la fuente y el tamaño del texto según sea necesario
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 208, 20)];
    statusLabel.textAlignment = UITextAlignmentCenter;
    statusLabel.font = [UIFont systemFontOfSize:13];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Color de la sombra
    statusLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
    if([[appDelegate.activeProfileView objectForKey:@"isGroup"] boolValue] == false){
        participants = [[appDelegate.activeProfileView objectForKey:@"commonGroups"] count];
        statusLabel.text = [appDelegate.activeProfileView objectForKey:@"formattedNumber"];
    } else {
        participants = [[[appDelegate.activeProfileView objectForKey:@"groupMetadata"] objectForKey:@"participants"] count];
        statusLabel.text = [NSString stringWithFormat:@"%d participants",participants];
    }
    isGroup = [[appDelegate.activeProfileView objectForKey:@"isGroup"] boolValue];
    isReadOnly = [[appDelegate.activeProfileView objectForKey:@"isReadOnly"] boolValue];
    if(isGroup == false){
        isBlocked = [[appDelegate.activeProfileView objectForKey:@"isBlocked"] boolValue];
    }
    
    [titleView addSubview:nameLabel];
    [titleView addSubview:statusLabel];
    
    self.navigationItem.titleView = titleView;
    
    // Crear el UIImageView
    self.profileImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PersonalChatOS6Large.png"]];
    self.profileImg.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImg.clipsToBounds = YES;
    
    // Ajustar el marco de la vista contenedora
    CGFloat headerHeight = 320.0; // Altura del encabezado
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerHeight)];
    
    // Ajustar el marco de UIImageView para que llene el headerView
    self.profileImg.frame = headerView.bounds;
    
    // Asegúrate de que autoresizingMask esté correctamente configurado
    self.profileImg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Agregar UIImageView al headerView
    [headerView addSubview:self.profileImg];
    
    // Establecer headerView como la vista de encabezado de la tabla
    self.tableView.tableHeaderView = headerView;
    
    if(IS_IOS4orHIGHER){
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [headerView addGestureRecognizer:tapGestureRecognizer];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)handleTap:(UITapGestureRecognizer *)doubleTapGestureRecognizer {
    ContactIImgViewController *cimgvc = [[ContactIImgViewController alloc] init];
    cimgvc.hidesBottomBarWhenPushed = true;
    cimgvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:cimgvc animated:YES];
    cimgvc.viewNav.title = self.title;
    cimgvc.imgView.image = self.profileImg.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
    {
        if(isGroup){
            if([self getAboutText] == nil){
                return 2;
            } else {
                return 3;
            }
        } else {
            return 1;
        }
    } else if(section == 1){
        if(!isGroup){
            return 3;
        } else {
            return 2;
        }
    } else if(section == 2) {
        if(isGroup == true){
            return participants + 2;
        } else {
            return participants + 1;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return @"Information";
    } else if (section == 1) {
        return @"Moderation";
    } else if (section == 2) {
        if(isGroup == true){
            return @"Participants";
        } else {
            return @"Common Groups";
        }
    }
    return nil;
}

- (NSString *)getAboutText {
    if(isGroup){
        if([appDelegate.activeProfileView objectForKey:@"groupDesc"] != [NSNull null]){
            return [appDelegate.activeProfileView objectForKey:@"groupDesc"];
        } else {
            return nil;
        }
    } else {
        if([appDelegate.activeProfileView objectForKey:@"profileAbout"] == [ NSNull null ]){
            return WSPInfoType_toString[DEFAULT];
        } else {
            return [appDelegate.activeProfileView objectForKey:@"profileAbout"];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0){
        NSString *text = [self getAboutText];
        
        if(text != nil){
            // Configuración de la fuente de la etiqueta
            UIFont *font = [UIFont systemFontOfSize:16.0];
            
            // Configuración del ancho disponible en la celda (restando márgenes)
            CGFloat width = tableView.frame.size.width - 40; // Ajusta según los márgenes
            
            // Calcular la altura necesaria
            CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
            CGSize labelSize = [text sizeWithFont:font constrainedToSize:constraintSize];
            
            // Devuelve la altura calculada más un margen para el espaciado
            return labelSize.height + 20; // Añade espacio adicional si es necesario
        }
    }
    if(indexPath.section == 2){
        if(isGroup == false){
            if(indexPath.row >= 1){
                return 70;
            }
        } else {
            if(indexPath.row >= 2){
                return 70;
            }
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"SettingsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (indexPath.row == 0){
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            if([self getAboutText] == nil && self.isGroup == true && self.isReadOnly == false){
                cell.textLabel.text = @"Add an description";
                cell.textLabel.textColor = UIColorFromRGB(0x008800);
                cell.imageView.image = [UIImage imageNamed:@"gicons-addinfo.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.textLabel.font = [UIFont systemFontOfSize:16.0];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.text = [self getAboutText];
            }
        }
        if(isGroup == true){
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            if ((indexPath.row == 1 && [self getAboutText] == nil) || (indexPath.row == 2 && [self getAboutText] != nil)){
                NSTimeInterval creationint = [[[appDelegate.activeProfileView objectForKey:@"groupMetadata"] objectForKey:@"creation"] doubleValue];
                NSDate *creation = [NSDate dateWithTimeIntervalSince1970:creationint];
                cell.textLabel.text = @"Group Created";
                cell.detailTextLabel.text = [CocoaFetch stringWithDate:creation];
            }
            if (indexPath.row == 1 && [self getAboutText] != nil){
                NSTimeInterval desctimeint = [[[appDelegate.activeProfileView objectForKey:@"groupMetadata"] objectForKey:@"descTime"] doubleValue];
                NSDate *desctime = [NSDate dateWithTimeIntervalSince1970:desctimeint];
                cell.textLabel.text = @"Last Updated";
                cell.detailTextLabel.text = [CocoaFetch stringWithDate:desctime];
            }
        }
        
        return cell;
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            static NSString *SwitchCellIdentifier = @"SwitchCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SwitchCellIdentifier];
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                cell.accessoryView = switchView;
                switchView.tag = 100;
                [switchView addTarget:self action:@selector(muteNotifications:) forControlEvents:UIControlEventValueChanged];
                
                
                float muteExpiration = [[appDelegate.activeProfileView objectForKey:@"muteExpiration"] doubleValue];
                if(muteExpiration != 0){
                    switchView.on = TRUE;
                }
            }
            
            cell.textLabel.text = @"Mute Notifications";
            return cell;
        } else {
            static NSString *CellIdentifier = @"SettingsCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if(isGroup == false){
                if (indexPath.row == 1) {
                    if (isBlocked == false){
                        cell.textLabel.text = @"Block Contact";
                    } else {
                        cell.textLabel.text = @"Unblock Contact";
                    }
                    cell.textLabel.textColor = UIColorFromRGB(0x880000);
                    cell.imageView.image = [UIImage imageNamed:@"gicons-block.png"];
                }  else if (indexPath.row == 2) {
                    cell.textLabel.text = @"Delete Chat";
                    cell.textLabel.textColor = UIColorFromRGB(0x880000);
                    cell.imageView.image = [UIImage imageNamed:@"gicons-trash.png"];
                }
            } else {
                if (indexPath.row == 1) {
                    if (isReadOnly == false){
                        cell.textLabel.text = @"Leave Group";
                    } else {
                        cell.textLabel.text = @"Delete Group";
                    }
                    cell.textLabel.textColor = UIColorFromRGB(0x880000);
                    cell.imageView.image = [UIImage imageNamed:@"gicons-logout.png"];
                }
            }
            
            return cell;
        }
    }
    if (indexPath.section == 2 && isGroup == true) {
        if(indexPath.row < 2){
            static NSString *CellIdentifier = @"SettingsCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Add Participant";
                cell.textLabel.textColor = UIColorFromRGB(0x008800);
                cell.imageView.image = [UIImage imageNamed:@"gicons-adduser.png"];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Link to Invite Participant";
                cell.textLabel.textColor = UIColorFromRGB(0x008800);
                cell.imageView.image = [UIImage imageNamed:@"gicons-inviteuser.png"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        } else {
            NSDictionary *dic = [[[appDelegate.activeProfileView objectForKey:@"groupMetadata"] objectForKey:@"participants"] objectAtIndex:indexPath.row - 2];
            static NSString *participantItemIdentifier = @"GroupParticipantPreview";
            
            GroupParticipantPreview *cell = (GroupParticipantPreview *)[tableView dequeueReusableCellWithIdentifier:participantItemIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupParticipantPreview" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            for(NSDictionary *contact in appDelegate.contactsViewController.contactList){
                if([[contact objectForKey:@"number"] isEqualToString:[[dic objectForKey:@"id"] objectForKey:@"user"]]){
                    cell.contactNumber = [contact objectForKey:@"number"];
                    cell.navigationController = self.navigationController;
                    if([contact objectForKey:@"name"]){
                        if([[contact objectForKey:@"number"] isEqualToString:[appDelegate.contactsViewController.myContact objectForKey:@"number"]]){
                            cell.profileName.text = WSPContactType_toString[YOUUSER];
                        } else {
                            cell.profileName.text = [contact objectForKey:@"name"];
                        }
                    } else {
                        //cell.profileName.text = [dic objectForKey:@"formattedNumber"];
                        cell.profileName.text = [NSString stringWithFormat:@"~ %@",[contact objectForKey:@"pushname"]];
                        cell.profileNumber.hidden = false;
                        cell.profileNumber.text = [contact objectForKey:@"formattedNumber"];
                    }
                    cell.profileAdmin.hidden = ![[dic objectForKey:@"isAdmin"] boolValue];
                    if([contact objectForKey:@"profileAbout"] != [NSNull null]){
                        cell.profileAbout.text = [contact objectForKey:@"profileAbout"];
                    } else {
                        cell.profileAbout.text = WSPInfoType_toString[DEFAULT];
                    }
                    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
                    if(!imageData){
                        cell.largeImage = [UIImage imageNamed:@"PersonalChatOS6Large.png"];
                    } else {
                        [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
                    }
                    if(![appDelegate.profileImages objectForKey:[contact objectForKey:@"number"]]){
                        [self performSelectorInBackground:@selector(downloadAndProcessImageContact:) withObject:cell.contactNumber];
                    } else {
                        cell.largeImage = [appDelegate.profileImages objectForKey:[contact objectForKey:@"number"]];
                        CGFloat targetWidth = 114.0; // Ajusta esto según tus necesidades
                        CGFloat targetHeight = 114.0; // Ajusta esto según tus necesidades
                        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
                        [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
                        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
                    }
                }
            }
            
            return cell;
        }
    }
    if (indexPath.section == 2 && isGroup == false) {
        if (indexPath.row == 0){
            static NSString *CellIdentifier = @"SettingsCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"New group with %@", [appDelegate.activeProfileView objectForKey:@"shortName"]];
            cell.textLabel.textColor = UIColorFromRGB(0x008800);
            cell.imageView.image = [UIImage imageNamed:@"gicons-addgroup.png"];
            cell.backgroundColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        } else {
            NSString *groupId = [[[appDelegate.activeProfileView objectForKey:@"commonGroups"] objectAtIndex:indexPath.row - 1] objectForKey:@"user"];
            NSDictionary *dic = [WhatsAppAPI getGroupInfo:groupId];
            static NSString *groupPreviewIdentifier = @"GroupCommonPreview";
            
            GroupCommonPreview *cell = (GroupCommonPreview *)[tableView dequeueReusableCellWithIdentifier:groupPreviewIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupCommonPreview" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            cell.contactNumber = groupId;
            cell.profileName.text = [dic objectForKey:@"name"];
            NSArray *participantsContacts = [[dic objectForKey:@"groupMetadata"] objectForKey:@"participants"];
            NSMutableArray *participantsNames = [NSMutableArray array];
            for(NSDictionary *_contact in participantsContacts){
                for(NSDictionary *contact in appDelegate.contactsViewController.contactList){
                    if([[contact objectForKey:@"number"] isEqualToString:[[_contact objectForKey:@"id"] objectForKey:@"user"]]){
                        if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                            [participantsNames addObject:[contact objectForKey:@"shortName"]];
                        } else {
                            [participantsNames addObject:[contact objectForKey:@"formattedNumber"]];
                        }
                    }
                }
            }
            cell.profileAbout.text = [participantsNames componentsJoinedByString:@", "];
            NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
            if(!imageData){
                cell.largeImage = [UIImage imageNamed:@"GroupChatOS6Large.png"];
            } else {
                [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
            }
            if(![appDelegate.profileImages objectForKey:cell.contactNumber]){
                [self performSelectorInBackground:@selector(downloadAndProcessImageGroup:) withObject:cell.contactNumber];
            } else {
                cell.largeImage = [appDelegate.profileImages objectForKey:cell.contactNumber];
                CGFloat targetWidth = 114.0; // Ajusta esto según tus necesidades
                CGFloat targetHeight = 114.0; // Ajusta esto según tus necesidades
                UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
                [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
                UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
            }
            
            return cell;
        }
    }
    return nil;
}

- (void)muteNotifications:(UISwitch *)sender {
    if(sender.on == TRUE){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mute Notifications"
                                                        message:@"Other participants will not see that muted the chat. You still be notified if you are mentioned."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"For 8 hours", @"For a week", @"Always", nil];
        alert.tag = (NSInteger)@"silentNotifications";
        [alert show];
    } else {
        [WhatsAppAPI setMutefromNumber:self.contactNumber isGroup:self.isGroup muteState:-1];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == (NSInteger)@"silentNotifications"){
        if(alertView.cancelButtonIndex == buttonIndex){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            UISwitch *oswitch = (UISwitch *)cell.accessoryView;
            oswitch.on = NO;
        }
        else {
            [WhatsAppAPI setMutefromNumber:self.contactNumber isGroup:self.isGroup muteState:buttonIndex - 1];
        }
    }
    if(alertView.tag == (NSInteger)@"blockContact" && buttonIndex != [alertView cancelButtonIndex]){
        [WhatsAppAPI setBlockfromNumber:self.contactNumber isGroup:self.isGroup];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if(alertView.tag == (NSInteger)@"deleteChat" && buttonIndex != [alertView cancelButtonIndex]){
        [WhatsAppAPI deleteChatfromNumber:self.contactNumber isGroup:self.isGroup];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if(alertView.tag == (NSInteger)@"leaveGroup" && buttonIndex != [alertView cancelButtonIndex]){
        [WhatsAppAPI leaveGroupfromNumber:self.contactNumber];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)downloadAndProcessImageContact:(NSString *)ocontactNumber {
    [WhatsAppAPI downloadAndProcessImage:ocontactNumber andIsGroup:FALSE];
}

- (void)downloadAndProcessImageGroup:(NSString *)ocontactNumber {
    [WhatsAppAPI downloadAndProcessImage:ocontactNumber andIsGroup:TRUE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(IS_IOS4orHIGHER){
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        }];
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(IS_IOS4orHIGHER){
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        }];
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        if (indexPath.row != 0){
            NSString* actionName = @"";
            NSInteger actionTag = 0;
            if (isGroup == false){
                switch (indexPath.row) {
                    case 1:
                        if (isBlocked == false) {
                            actionName = @"Do you wanna to block %@?";
                        } else {
                            actionName = @"Do you wanna to unblock %@?";
                        }
                        actionTag = (NSInteger)@"blockContact";
                        break;
                    case 2:
                        actionName = @"Do you wanna to delete %@'s chat?";
                        actionTag = (NSInteger)@"deleteChat";
                        break;
                }
            } else {
                switch (indexPath.row) {
                    case 1:
                        if (isReadOnly == false){
                            actionName = @"Do you wanna to leave %@?";
                            actionTag = (NSInteger)@"leaveGroup";
                        } else {
                            actionName = @"Do you wanna to delete %@ group?";
                            actionTag = (NSInteger)@"deleteChat";
                        }
                        break;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:actionName,self.title]
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
            alert.tag = actionTag;
            [alert show];
        }
    }
}

- (void)dealloc {
    [self setProfileImg:nil];
    [super dealloc];
}
@end
