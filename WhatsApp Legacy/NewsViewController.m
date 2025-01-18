//
//  NewsViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 24/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "NewsViewController.h"
#import "StatusPreviewItem.h"
#import "CocoaFetch.h"
#import "WhatsAppAPI.h"
#import "AppDelegate.h"
#import "BroadcastViewController.h"

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0))

@interface NewsViewController ()

@end

@implementation NewsViewController
@synthesize broadcastList, _hasUnread;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PreviousIcon.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self reloadNews];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.broadcastList.count;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Status";
            break;
        case 1:
            return @"Channels";
        default:
            return nil;
            break;
    }
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *dic = [self.broadcastList objectAtIndex:indexPath.row];
    StatusPreviewItem *cell = (StatusPreviewItem *)[tableView dequeueReusableCellWithIdentifier:@"StatusPreviewItem"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StatusPreviewItem" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    cell.profileName.text = [[WhatsAppAPI getContactInfo:[[dic objectForKey:@"id"] objectForKey:@"user"]] objectForKey:@"name"];
    cell.totalCount = [[dic objectForKey:@"totalCount"] intValue];
    cell.unreadCount = [[dic objectForKey:@"unreadCount"] intValue];
    cell.contactNumber = [[dic objectForKey:@"id"] objectForKey:@"user"];
    
    NSInteger timestamp = [[dic objectForKey:@"timestamp"] intValue];
    cell.profileTimestamp.text = [CocoaFetch formattedDateHourFromTimestamp:(NSTimeInterval)timestamp];
    
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
    if(!imageData){
        if([cell.contactNumber isEqualToString:@"0"]){
            cell.largeImage = [UIImage imageNamed:@"oficialprofile.png"];
            CGFloat targetWidth = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
            CGFloat targetHeight = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
            
            UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
            [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            cell.largeImage = scaledImage;
        } else {
            cell.largeImage = [UIImage imageNamed:@"PersonalChatOS6Large.png"];
        }
    } else {
        [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
    }
    if(![appDelegate.profileImages objectForKey:cell.contactNumber]){
        [self performSelectorInBackground:@selector(downloadAndProcessImageProfile:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                 cell, @"cell",
                                                                                                 [NSNumber numberWithBool:false], @"isGroup", nil]];
    } else {
        cell.largeImage = [appDelegate.profileImages objectForKey:cell.contactNumber];
        CGFloat targetWidth = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
        CGFloat targetHeight = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
        
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cell.largeImage = scaledImage;
    }
    
    return cell;
}

- (void)downloadAndProcessImageProfile:(NSDictionary *)params {
    StatusPreviewItem *cell = [params objectForKey:@"cell"];
    [WhatsAppAPI downloadAndProcessImage:cell.contactNumber andIsGroup:false];
}

- (void)reloadNews
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self._hasUnread = false;
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        [WhatsAppAPI getBroadcastListAsync];
    } else {
        NSDictionary *dic = [CocoaFetch loadDictionaryFromJSONWithFileName:@"broadcastList"];
        self.broadcastList = [dic objectForKey:@"broadcastList"];
        for (NSDictionary *broadcastItem in self.broadcastList) {
            bool ohasUnread = [[broadcastItem objectForKey:@"unreadCount"] integerValue] > 0;
            if (ohasUnread == true){
                self._hasUnread = true;
            }
            
        }
        [self.tableView reloadData];
        self.hasUnread = self._hasUnread;
    }
}

- (void)fetcherDidFinishWithJSON:(NSDictionary *)json error:(NSError *)error
{
    if (json)
    {
        [CocoaFetch saveDictionaryToJSON:json withFileName:@"broadcastList"];
        self.broadcastList = [json objectForKey:@"broadcastList"];
        for (NSDictionary *broadcastItem in self.broadcastList) {
            bool ohasUnread = [[broadcastItem objectForKey:@"unreadCount"] integerValue] > 0;
            if (ohasUnread == true){
                self._hasUnread = true;
            }
            
        }
        [self.tableView reloadData];
        self.hasUnread = self._hasUnread;
    }
}

- (BOOL)hasUnread
{
    return ([self tabBarItem].badgeValue != nil);
}

- (void)setHasUnread:(BOOL)newHasUnread
{
    if (newHasUnread){
        [[self tabBarItem] setBadgeValue:@""];
    } else {
        [[self tabBarItem] setBadgeValue:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Navigation logic may go here. Create and push another view controller.
    
    StatusPreviewItem *cell = (StatusPreviewItem *)[tableView cellForRowAtIndexPath:indexPath];
     BroadcastViewController *broadcastViewController = [[BroadcastViewController alloc] initWithNibName:@"BroadcastViewController" bundle:nil];
    broadcastViewController.contactNumber = cell.contactNumber;
    broadcastViewController.unreadCount = (cell.unreadCount == 0 ? 0 : cell.totalCount - cell.unreadCount);
    broadcastViewController.totalCount = cell.totalCount;
    broadcastViewController.msgList = [[self.broadcastList objectAtIndex:indexPath.row] objectForKey:@"msgs"];
    broadcastViewController.title = cell.profileName.text;
    
    // Pass the selected object to the new view controller.
    broadcastViewController.hidesBottomBarWhenPushed = true;
    [self presentModalViewController:broadcastViewController animated:YES];
     [broadcastViewController release];
     
}

@end
