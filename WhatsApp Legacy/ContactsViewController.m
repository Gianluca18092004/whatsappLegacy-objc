//
//  ContactsViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 29/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "AppDelegate.h"
#import "ContactsViewController.h"
#import "ContactItem.h"
#import "WhatsAppAPI.h"
#import "CocoaFetch.h"
#import "ChatViewController.h"
#import "CGLContact.h"
#import "CGLAlphabetizer.h"

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0))

@interface ContactsViewController ()

@property (retain) AppDelegate *appDelegate;
@property (assign, nonatomic) NSDictionary *alphabetizedDictionary;
@property (assign, nonatomic) NSArray *sectionIndexTitles;

@end

@implementation ContactsViewController
@synthesize appDelegate, contactList, filteredContactList = _filteredContactList, alphabetizedDictionary = _alphabetizedDictionary, sectionIndexTitles = _sectionIndexTitles, myContact;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Contacts", @"Contacts");
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.profileImages = [NSMutableDictionary dictionary];
    appDelegate.mediaImages = [NSMutableDictionary dictionary];
    appDelegate.mediaAudios = [NSMutableDictionary dictionary];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dealloc
{
    [contactList release];
    [_filteredContactList release];
    [_alphabetizedDictionary release];
    [_sectionIndexTitles release];
    [myContact release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFilteredContactList:(NSArray *)filteredContactList {
    if (_filteredContactList != filteredContactList){
        // Retener el nuevo array y liberar el anterior
        [_filteredContactList release];
        _filteredContactList = [filteredContactList retain];
        
        // Actualizar el diccionario y las secciones
        self.alphabetizedDictionary = [[CGLAlphabetizer alphabetizedDictionaryFromObjects:_filteredContactList usingKeyPath:@"name"] retain];
        self.sectionIndexTitles = [[CGLAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary] retain];
        
        [self.tableView reloadData];
        
    }
}

- (NSDictionary *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIndexTitle = [self.sectionIndexTitles objectAtIndex:indexPath.section];
    return [[self.alphabetizedDictionary objectForKey:sectionIndexTitle] objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionIndexTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionIndexTitle = [self.sectionIndexTitles objectAtIndex:section];
    return [[self.alphabetizedDictionary objectForKey:sectionIndexTitle] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self objectAtIndexPath:indexPath];
    static NSString *contactItemIdentifier = @"ContactItem";
    
    ContactItem *cell = (ContactItem *)[tableView dequeueReusableCellWithIdentifier:contactItemIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactItem" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.contactNumber = [dic objectForKey:@"number"];
    cell.navigationController = self.navigationController;
    cell.profileName.text = [dic objectForKey:@"name"];
    if([dic objectForKey:@"profileAbout"] != [NSNull null]){
        cell.profileAbout.text = [dic objectForKey:@"profileAbout"];
    } else {
        cell.profileAbout.text = WSPInfoType_toString[DEFAULT];
    }
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
    if(!imageData){
        cell.largeImage = [UIImage imageNamed:@"PersonalChatOS6Large.png"];
    } else {
        [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
    }
    if(![appDelegate.profileImages objectForKey:[dic objectForKey:@"number"]]){
        [self performSelectorInBackground:@selector(downloadAndProcessImageContact:) withObject:cell];
    } else {
        cell.largeImage = [appDelegate.profileImages objectForKey:[dic objectForKey:@"number"]];
        CGFloat targetWidth = (IS_RETINA ? 114.0 : 72.0);; // Ajusta esto según tus necesidades
        CGFloat targetHeight = (IS_RETINA ? 114.0 : 72.0);; // Ajusta esto según tus necesidades
        
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (scaledImage){
            [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
        }
    }

    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionIndexTitles objectAtIndex:section];
}

- (void)downloadAndProcessImageContact:(ContactItem *)cell {
    [WhatsAppAPI downloadAndProcessImage:cell.contactNumber andIsGroup:FALSE];
    //[self performSelectorOnMainThread:@selector(setImageCell:) withObject:cell waitUntilDone:YES];
    /*NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", cell.contactNumber]];
    if(imageData){
        [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:cell.contactNumber];
        cell.largeImage = [appDelegate.profileImages objectForKey:cell.contactNumber];
        CGFloat targetWidth = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
        CGFloat targetHeight = (IS_RETINA ? 114.0 : 72.0); // Ajusta esto según tus necesidades
        
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [cell.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (scaledImage){
            [cell.profileImg setBackgroundImage:scaledImage forState:UIControlStateNormal];
        }
    }*/
}

- (void)reloadContacts {
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        [WhatsAppAPI getContactListAsync];
    } else {
        NSMutableArray* filteredContactList = [[NSMutableArray alloc]init];
        self.contactList = [[CocoaFetch loadDictionaryFromJSONWithFileName:@"contactList"] objectForKey:@"contactList"];
        self.myContact = [WhatsAppAPI getMyContact];
        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", [self.myContact objectForKey:@"number"]]];
        if (!imageData){
            if(![appDelegate.profileImages objectForKey:[self.myContact objectForKey:@"number"]] && appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
                [WhatsAppAPI downloadAndProcessImage:[self.myContact objectForKey:@"number"] andIsGroup:FALSE];
            }
        } else {
            [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:[self.myContact objectForKey:@"number"]];
        }
        for (NSDictionary *contact in self.contactList){
            if([[contact objectForKey:@"isWAContact"] boolValue] == true && [[contact objectForKey:@"isMyContact"] boolValue] == true && [[contact objectForKey:@"isMe"] boolValue] == false && ![[contact objectForKey:@"number"] isEqualToString:@"0"]){
                [filteredContactList addObject:contact];
            }
        }
        self.filteredContactList = filteredContactList;
        [self.tableView reloadData];
    }
}

- (void)fetcherDidFinishWithJSON:(NSDictionary *)json error:(NSError *)error {
    if (json){
        NSMutableArray* filteredContactList = [[NSMutableArray alloc]init];
        [CocoaFetch saveDictionaryToJSON:json withFileName:@"contactList"];
        self.contactList = [json objectForKey:@"contactList"];
        self.myContact = [WhatsAppAPI getMyContact];
        for (NSDictionary *contact in self.contactList){
            if([[contact objectForKey:@"isWAContact"] boolValue] == true && [[contact objectForKey:@"isMyContact"] boolValue] == true && [[contact objectForKey:@"isMe"] boolValue] == false && ![[contact objectForKey:@"number"] isEqualToString:@"0"]){
                [filteredContactList addObject:contact];
            }
        }
        self.filteredContactList = filteredContactList;
        [self.tableView reloadData];
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
    // Navigation logic may go here. Create and push another view controller.
    ContactItem *cell = (ContactItem *)[tableView cellForRowAtIndexPath:indexPath];
    [appDelegate loadChatViewWithContactNumber:cell.contactNumber andFromContact:YES];
}

@end
