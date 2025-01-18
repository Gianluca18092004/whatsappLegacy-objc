//
//  MyStatusViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 19/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "MyStatusViewController.h"
#import "InfoStatusViewController.h"
#import "WhatsAppAPI.h"
#import "AppDelegate.h"

@interface MyStatusViewController ()
@property (retain) AppDelegate *appDelegate;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, copy) NSString* statusText;
@end

@implementation MyStatusViewController
@synthesize selectedRow, statusText, appDelegate;

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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.statusText = [appDelegate.contactsViewController.myContact objectForKey:@"profileAbout"];
    self.selectedRow = -1;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 11;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        // Crear una nueva celda para esta sección y fila en particular sin reutilizar
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    } else {
        static NSString *CellIdentifier = @"StatusCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    // Configura la celda según la sección y fila
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell setText:self.statusText];
            [cell setTextAlignment:UITextAlignmentLeft];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    } else if (indexPath.section == 1) {
        [cell setText:WSPInfoType_toString[indexPath.row+1]];
        [cell setTextAlignment:UITextAlignmentLeft];
        if (indexPath.row == self.selectedRow) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [cell setText:@"Clear Status"];
            [cell setTextColor:[UIColor whiteColor]];
            [cell setTextAlignment:UITextAlignmentCenter];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIImage *normalImage = [[UIImage imageNamed:@"RedButton.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:7.0f];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:normalImage];
            cell.backgroundView = backgroundImageView;
            
            UIImage *selectedImage = [[UIImage imageNamed:@"RedButtonPressed.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:7.0f];
            UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithImage:selectedImage];
            cell.selectedBackgroundView = selectedBackgroundImageView;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Your current status is:";
            break;
        case 1:
            return @"Select your new status";
            break;
        default:
            return @"";
            break;
    }
}

- (void)fetcherDidFinishWithJSON:(NSDictionary *)json error:(NSError *)error {
    if (json){
        [appDelegate.chatsViewController reloadChats];
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
    if (indexPath.section == 0){
        UITableViewCell *myCell = [tableView cellForRowAtIndexPath:indexPath];
        InfoStatusViewController *infoStatusViewController = [[InfoStatusViewController alloc] init];
        [self presentModalViewController:infoStatusViewController animated:YES];
        infoStatusViewController.txtField.text = myCell.textLabel.text;
        [infoStatusViewController textViewDidChange:infoStatusViewController.txtField];
    }
    if (self.selectedRow != indexPath.row && indexPath.section == 1) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:1];
        self.selectedRow = indexPath.row; // Actualizar la celda seleccionada
        
        // Recargar las celdas
        UITableViewCell *sCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITableViewCell *myCell = [tableView cellForRowAtIndexPath:indexPath];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        myCell.accessoryType = UITableViewCellAccessoryCheckmark;
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        [sCell setText:myCell.text];
        self.statusText = myCell.text;
        [WhatsAppAPI setStatusMsg:[myCell.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (indexPath.section == 2) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:1];
        self.selectedRow = indexPath.row; // Actualizar la celda seleccionada
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        [WhatsAppAPI setStatusMsg:[WSPInfoType_toString[DEFAULT] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        self.statusText = WSPInfoType_toString[DEFAULT];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // Si se presionó "OK"
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *newText = textField.text;
        UITableViewCell *sCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [sCell setText:newText];
        self.statusText = newText;
    }
}

@end
