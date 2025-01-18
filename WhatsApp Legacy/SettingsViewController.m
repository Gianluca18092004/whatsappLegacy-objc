//
//  SettingsViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 13/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "SettingsViewController.h"
#import "CocoaFetch.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "GroupParticipantPreview.h"
#import "WhatsAppAPI.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

@interface SettingsViewController ()
@property (retain) AppDelegate *appDelegate;

@end

@implementation SettingsViewController
@synthesize appDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 1){
        return 5;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *participantItemIdentifier = @"GroupParticipantPreview";
    if (indexPath.section == 0){
        GroupParticipantPreview *cell = (GroupParticipantPreview *)[tableView dequeueReusableCellWithIdentifier:participantItemIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupParticipantPreview" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.contactNumber = [appDelegate.contactsViewController.myContact objectForKey:@"number"];
        cell.profileName.text = [appDelegate.contactsViewController.myContact objectForKey:@"pushname"];
        if([appDelegate.contactsViewController.myContact objectForKey:@"profileAbout"] != [NSNull null]){
            cell.profileAbout.text = [appDelegate.contactsViewController.myContact objectForKey:@"profileAbout"];
        } else {
            cell.profileAbout.text = WSPInfoType_toString[DEFAULT];
        }
        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
        if(!imageData){
            cell.largeImage = [UIImage imageNamed:@"PersonalChatOS6Large.png"];
        } else {
            [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
        }
        if(![appDelegate.profileImages objectForKey:[appDelegate.contactsViewController.myContact objectForKey:@"number"]]){
            //[self performSelectorInBackground:@selector(downloadAndProcessImageContact:) withObject:cell.contactNumber];
        } else {
            cell.largeImage = [appDelegate.profileImages objectForKey:[appDelegate.contactsViewController.myContact objectForKey:@"number"]];
            CGFloat targetWidth = 114.0; // Ajusta esto según tus necesidades
            CGFloat targetHeight = 114.0; // Ajusta esto según tus necesidades
            UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
            [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        switch (indexPath.section){
            case 1:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"Account";
                        cell.imageView.image = [UIImage imageNamed:@"gicons-key.png"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    case 1:
                        cell.textLabel.text = @"Privacy";
                        cell.imageView.image = [UIImage imageNamed:@"gicons-privacy.png"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    case 2:
                        cell.textLabel.text = @"Chats";
                        cell.imageView.image = [UIImage imageNamed:@"gicons-chats.png"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    case 3:
                        cell.textLabel.text = @"Notifications";
                        cell.imageView.image = [UIImage imageNamed:@"gicons-bell.png"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                    case 4:
                        cell.textLabel.text = @"Storage and Data";
                        cell.imageView.image = [UIImage imageNamed:@"gicons-datastorage.png"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                }
                break;
            case 2:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"About";
                        cell.imageView.image = [UIImage imageNamed:@"gicons-about.png"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                }
                break;
        }
        return cell;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return 70;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if(indexPath.section == 2 && indexPath.row == 0){
        AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        aboutViewController.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }
}

@end
