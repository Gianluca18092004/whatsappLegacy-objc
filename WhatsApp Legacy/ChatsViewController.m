//
//  ChatsViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 29/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "ChatsViewController.h"
#import "ProfileViewController.h"
#import "ChatPreviewItem.h"
#import "WhatsAppAPI.h"
#import "CocoaFetch.h"
#import <QuartzCore/QuartzCore.h>

#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0))
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

@interface ChatsViewController ()
@property (retain) AppDelegate *appDelegate;
@end

@implementation ChatsViewController
@synthesize isFiltered, appDelegate, searchBar, filteredChatList, chatBadge, chatList, groupList, unreadCount, btnMetaAiView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFiltered = false;
    self.searchBar.delegate = self;
    self.title = NSLocalizedString(@"Chats", @"Chats");
    self.navigationItem.title = self.title;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.profileImages = [NSMutableDictionary dictionary];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.btnMetaAiView = [[UIView alloc] initWithFrame:CGRectMake(258.0f, [[UIScreen mainScreen] bounds].size.height - 190.0f,50.0f, 50.0f)];
    self.btnMetaAiView.backgroundColor = [UIColor clearColor];
    [self.btnMetaAiView setHidden:YES];
    
    UIButton *mai = [[UIButton alloc] initWithFrame:self.btnMetaAiView.bounds];
    [mai setBackgroundImage:[[UIImage imageNamed:@"GrayButton.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:7.0f] forState:UIControlStateNormal];
    [mai setImage:[UIImage imageNamed:@"metaai.png"] forState:UIControlStateNormal];
    [mai addTarget:self action:@selector(maiPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMetaAiView addSubview:mai];
    
    [self.view addSubview:self.btnMetaAiView];
    [self.view bringSubviewToFront:self.btnMetaAiView];
    [self reloadChats];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![self.navigationController.viewControllers containsObject:appDelegate.chatViewController]) {
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(reloadChats)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)maiPressed:(UIButton*)pressed {
    [appDelegate loadChatViewWithContactNumber:@"13135550002" andFromContact:NO];
}

- (void)loadSearchResults {
    if(self.searchBar.text.length == 0 && self.searchBar.selectedScopeButtonIndex == 0){
        isFiltered = false;
    } else {
        isFiltered = true;
        filteredChatList = [[NSMutableArray alloc] init];
        
        for (NSDictionary *chatItem in self.chatList) {
            BOOL notFound = false;
            if(self.searchBar.text.length > 0){
                NSRange nameRange = [[chatItem objectForKey:@"name"] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                if(nameRange.location == NSNotFound){
                    notFound = true;
                }
            }
            if(notFound == false){
                bool isGroup = [[chatItem objectForKey:@"isGroup"] boolValue];
                bool hasUnread = [[chatItem objectForKey:@"unreadCount"] integerValue] > 0;
                if(self.searchBar.selectedScopeButtonIndex == 0 ||
                   (self.searchBar.selectedScopeButtonIndex == 1 && hasUnread == true) ||
                   (self.searchBar.selectedScopeButtonIndex == 2 && isGroup == true)){
                    [filteredChatList addObject:chatItem];
                }
            }
        }
    }
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self loadSearchResults];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self loadSearchResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.btnMetaAiView.frame;
    frame.origin.y = self.tableView.contentOffset.y + [[UIScreen mainScreen] bounds].size.height - 190.0f; // Mantener a 100 puntos del borde superior
    self.btnMetaAiView.frame = frame;
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
    if(isFiltered){
        [self.btnMetaAiView setHidden:(filteredChatList.count == 0)];
        return filteredChatList.count;
    }
    [self.btnMetaAiView setHidden:(self.chatList.count == 0)];
    return [self.chatList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic;
    if(isFiltered){
        dic = [filteredChatList objectAtIndex:indexPath.row];
    } else {
        dic = [self.chatList objectAtIndex:indexPath.row];
    }
    bool isGroup = [[dic objectForKey:@"isGroup"] boolValue];
    bool isMuted = [[dic objectForKey:@"muteExpiration"] integerValue] != 0;
    NSString* userThatWrited = @"";
    NSInteger ack = [[[dic objectForKey:@"lastMessage"] objectForKey:@"ack"] integerValue];
    NSInteger timestamp = [[dic objectForKey:@"timestamp"] integerValue];
    NSInteger oUnreadCount = [[dic objectForKey:@"unreadCount"] integerValue];
    NSString* messageBody = [[dic objectForKey:@"lastMessage"] objectForKey:@"body"];
    NSString* messageType = [[dic objectForKey:@"lastMessage"] objectForKey:@"type"];
    static NSString *chatPreviewItemIdentifier = @"ChatPreviewItem";
    
    ChatPreviewItem *cell = (ChatPreviewItem *)[tableView dequeueReusableCellWithIdentifier:chatPreviewItemIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatPreviewItem" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if(isMuted == true) cell.mutedImg.hidden = false;
    cell.ackState = ack;
    cell.hideAck = ![[[dic objectForKey:@"lastMessage"] objectForKey:@"fromMe"] boolValue];
    cell.hideMedia = [[[dic objectForKey:@"lastMessage"] objectForKey:@"type"] isEqualToString:@"chat"];
    cell.timestamp = timestamp;
    cell.unreadMessages = oUnreadCount;
    cell.isGroup = isGroup;
    cell.contactNumber = [[dic objectForKey:@"id"] objectForKey:@"user"];
    cell.navigationController = self.navigationController;
    cell.profileName.text = [dic objectForKey:@"name"];
    cell.profileLastHour.text = [CocoaFetch formattedDateFromTimestamp:(NSTimeInterval)timestamp];
    
    if(isGroup){
        NSString* author = [[[[dic objectForKey:@"lastMessage"] objectForKey:@"_data"] objectForKey:@"author"] objectForKey:@"user"];
        for(NSDictionary *contact in appDelegate.contactsViewController.contactList){
            if([[contact objectForKey:@"number"] isEqualToString:author]){
                
                if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                    userThatWrited = [NSString stringWithFormat:@"%@:", [contact objectForKey:@"shortName"]];
                } else {
                    userThatWrited = [NSString stringWithFormat:@"%@:", [contact objectForKey:@"formattedNumber"]];
                }
            }
        }
    }
    
    cell.messageUser = [NSString stringWithFormat:@"%@", userThatWrited];
    if([messageType isEqualToString:@"chat"]){
        cell.messageText = [NSString stringWithFormat:@"%@", messageBody];
    } else {
        if([messageType isEqualToString:@"ptt"]){
            NSString* messageDuration = [CocoaFetch formattedTimeFromSeconds:[[[dic objectForKey:@"lastMessage"] objectForKey:@"duration"] integerValue]];
            cell.messageText = [NSString stringWithFormat:@"%@ (%@)", WSPMsgMediaType_toString[PTT], messageDuration];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewVoiceNote.png"];
        } else if([messageType isEqualToString:@"audio"]){
            NSString* messageDuration = [CocoaFetch formattedTimeFromSeconds:[[[dic objectForKey:@"lastMessage"] objectForKey:@"duration"] integerValue]];
            cell.messageText = [NSString stringWithFormat:@"%@ (%@)", WSPMsgMediaType_toString[AUDIO], messageDuration];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewAudio.png"];
        } else if([messageType isEqualToString:@"image"]) {
            cell.messageText = [NSString stringWithFormat:@"%@", WSPMsgMediaType_toString[PICTURE]];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewImage.png"];
        } else if([messageType isEqualToString:@"video"]) {
            NSString* messageDuration = [CocoaFetch formattedTimeFromSeconds:[[[dic objectForKey:@"lastMessage"] objectForKey:@"duration"] integerValue]];
            cell.messageText = [NSString stringWithFormat:@"%@ (%@)", WSPMsgMediaType_toString[VIDEO], messageDuration];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewVideo.png"];
        } else if([messageType isEqualToString:@"sticker"]) {
            cell.messageText = [NSString stringWithFormat:@"%@", WSPMsgMediaType_toString[STICKER]];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewSticker.png"];
        } else if([messageType isEqualToString:@"revoked"]) {
            cell.messageText = [NSString stringWithFormat:@"%@", WSPMsgMediaType_toString[REVOKED]];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewDeleted.png"];
        } else if([messageType isEqualToString:@"location"]) {
            cell.messageText = [NSString stringWithFormat:@"%@", WSPMsgMediaType_toString[LOCATION]];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewLocation.png"];
        } else {
            cell.messageText = [NSString stringWithFormat:@"%@", WSPMsgMediaType_toString[UNKNOWN]];
            cell.profileMediaType.image = [UIImage imageNamed:@"PreviewUnknown.png"];
        }
    }
    
    if(isGroup == false){
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
                
                [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
            } else {
                cell.largeImage = [UIImage imageNamed:@"PersonalChatOS6Large.png"];
            }
        } else {
            [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
        }
        if(![appDelegate.profileImages objectForKey:cell.contactNumber]){
            [self performSelectorInBackground:@selector(downloadAndProcessImageProfile:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                     cell, @"cell",
                                                                                                     [NSNumber numberWithBool:isGroup], @"isGroup", nil]];
        } else {
            cell.largeImage = [appDelegate.profileImages objectForKey:cell.contactNumber];
            CGFloat targetWidth = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
            CGFloat targetHeight = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
            
            UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
            [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
        }
    } else {
        [cell.profileImg setBackgroundImage:[UIImage imageNamed:@"GroupChatOS6.png"] forState:UIControlStateNormal];
        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
        if(!imageData){
            cell.largeImage = [UIImage imageNamed:@"GroupChatOS6Large.png"];
        } else {
            [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
        }
        if(![appDelegate.profileImages objectForKey:cell.contactNumber]){
            [self performSelectorInBackground:@selector(downloadAndProcessImageProfile:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                   cell, @"cell",
                                                                                                   [NSNumber numberWithBool:isGroup], @"isGroup", nil]];
        } else {
            cell.largeImage = [appDelegate.profileImages objectForKey:cell.contactNumber];
            CGFloat targetWidth = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
            CGFloat targetHeight = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
            
            UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
            [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

- (void)downloadAndProcessImageProfile:(NSDictionary *)params {
    ChatPreviewItem *cell = [params objectForKey:@"cell"];
    BOOL isGroup = [[params objectForKey:@"isGroup"] boolValue];
    [WhatsAppAPI downloadAndProcessImage:cell.contactNumber andIsGroup:isGroup];
}

- (void)onlyReload {
    [self.tableView reloadData];
}

- (void)reloadChats {
    [appDelegate.contactsViewController reloadContacts];
    [appDelegate.newsViewController reloadNews];
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        [WhatsAppAPI getChatListAsync];
    } else {
        chatBadge = 0;
        unreadCount = 0;
        NSDictionary *dic = [CocoaFetch loadDictionaryFromJSONWithFileName:@"chatList"];
        self.chatList = [dic objectForKey:@"chatList"];
        self.groupList = [dic objectForKey:@"groupList"];
        for (NSDictionary *chatItem in self.chatList) {
            bool hasUnread = [[chatItem objectForKey:@"unreadCount"] integerValue] > 0;
            int unreadCountI = [[chatItem objectForKey:@"unreadCount"] integerValue];
            bool isMuted = [[chatItem objectForKey:@"muteExpiration"] integerValue] != 0;
            if(hasUnread == true){
                chatBadge++;
            }
            if(isMuted == false){
                unreadCount = unreadCount + unreadCountI;
            }
        }
        if(chatBadge > 0){
            NSString *badgeValue = [NSString stringWithFormat:@"%ld", (long)chatBadge];
            [[self tabBarItem] setBadgeValue:badgeValue];
        } else {
            [[self tabBarItem] setBadgeValue:nil];
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)fetcherDidFinishWithJSON:(NSDictionary *)json error:(NSError *)error {
    if (json){
        chatBadge = 0;
        unreadCount = 0;
        [CocoaFetch saveDictionaryToJSON:json withFileName:@"chatList"];
        self.chatList = [json objectForKey:@"chatList"];
        self.groupList = [json objectForKey:@"groupList"];
        for (NSDictionary *chatItem in self.chatList) {
            bool hasUnread = [[chatItem objectForKey:@"unreadCount"] integerValue] > 0;
            int unreadCountI = [[chatItem objectForKey:@"unreadCount"] integerValue];
            bool isMuted = [[chatItem objectForKey:@"muteExpiration"] integerValue] != 0;
            if(hasUnread == true){
                chatBadge++;
            }
            if(isMuted == false){
                unreadCount = unreadCount + unreadCountI;
            }
        }
        if(chatBadge > 0){
            NSString *badgeValue = [NSString stringWithFormat:@"%ld", (long)chatBadge];
            [[self tabBarItem] setBadgeValue:badgeValue];
        } else {
            [[self tabBarItem] setBadgeValue:nil];
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)loadMessagesFirstTime {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    for (NSDictionary *dic in self.chatList) {
        bool isGroup = [[dic objectForKey:@"isGroup"] boolValue];
        NSString* contactNumber = [[dic objectForKey:@"id"] objectForKey:@"user"];
        [WhatsAppAPI fetchMessagesfromNumberAsync:contactNumber isGroup:isGroup light:false];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    ChatPreviewItem *cell = (ChatPreviewItem *)[tableView cellForRowAtIndexPath:indexPath];
    [appDelegate loadChatViewWithContactNumber:cell.contactNumber andFromContact:NO];
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

- (void)dealloc {
    [searchBar release];
    [super dealloc];
}
@end
