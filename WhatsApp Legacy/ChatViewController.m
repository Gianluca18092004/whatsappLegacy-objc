//
//  ChatViewController.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "ContactsViewController.h"
#import "ProfileViewController.h"
#import "WhatsAppAPI.h"
#import "CocoaFetch.h"
#import "UnknownMessage.h"
#import "VoiceNoteMessage.h"
#import "PictureMessage.h"
#import "DeletedMessage.h"
#import "LocationMessage.h"
#import "StickerMessage.h"
#import "VideoMessage.h"
#import "NSData+Base64.h"
#import "LocationViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)

@interface ChatViewController ()
@property (retain) AppDelegate *appDelegate;
@property (assign) NSInteger hiddenMessages;
@property (nonatomic, assign) CGPoint savedContentOffset;
@property (assign) BOOL loaded;
@end

@implementation ChatViewController
@synthesize appDelegate, levelNav, chatContacts, chatMessages, profileButton, smallImage, largeImage, contactNumber, timestamp, hiddenMessages, savedContentOffset, loaded, nameLabel, statusLabel, titleView, imagePicker;

#pragma mark - Initialization
- (UIButton *)sendButton
{
    // Override to use a custom send button
    // The button's frame is set automatically for you
    return [UIButton defaultSendButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.delegate = self;
    self.dataSource = self;
    self.inputToolBarView.textView.delegate = self;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    levelNav = 1;
    loaded = true;

    [self reloadChat];
    
    self.savedContentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.savedContentOffset = self.tableView.contentOffset;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        loaded = false;
        [self.attachToolBarView setHidden:YES];
        for (UIView *view in [self.tableView subviews]) {
            if ([view isKindOfClass:[UITableViewCell class]]) {
                [view removeFromSuperview];
                view = nil;
            }
        }
        self.contactNumber = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!CGPointEqualToPoint(self.savedContentOffset, CGPointZero) && loaded == TRUE) {
        [self.tableView setContentOffset:self.savedContentOffset animated:NO];
    }
    
    if (!loaded) {
        [self reloadChat];
        levelNav = 1;
        self.hiddenMessages = 0;
        [self.tableView reloadData];
        loaded = TRUE;
        [self scrollToBottomAnimated:NO];
        self.savedContentOffset = CGPointZero;
    }
    
    if(IS_IOS4orHIGHER){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

- (void)loadStatusText:(BOOL)fromContact withDic:(NSDictionary *)dic andStatus:(NSString *)statusText {
    [WhatsAppAPI sendSeenfromNumber:self.contactNumber isGroup:self.isGroup];
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (fromContact == YES ? 190 : 208), 44)];
    self.titleView.backgroundColor = [UIColor clearColor];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, (fromContact == YES ? 190 : 208), 24)];
    self.nameLabel.text = self.title;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:(fromContact == YES ? 18 : 19)];
    self.nameLabel.textAlignment = UITextAlignmentCenter;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    // Configura la fuente y el tamaño del texto según sea necesario
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, (fromContact == YES ? 190 : 208), 20)];
    self.statusLabel.textAlignment = UITextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:13];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        self.nameLabel.textColor = [UIColor grayColor]; // Gris oscuro
        self.statusLabel.textColor = [UIColor grayColor]; // Gris oscuro
        self.nameLabel.shadowOffset = CGSizeMake(0, 1); // Desplazamiento de la sombra
        self.statusLabel.shadowOffset = CGSizeMake(0, 1); // Desplazamiento de la sombra
        self.nameLabel.shadowColor = [UIColor whiteColor]; // Blanco
        self.statusLabel.shadowColor = [UIColor whiteColor]; // Blanco
    } else {
        // iPhone o iPod Touch
        self.nameLabel.textColor = [UIColor whiteColor]; // Blanco
        self.statusLabel.textColor = [UIColor whiteColor]; // Blanco
        self.nameLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
        self.statusLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
        self.nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Color de la sombra
        self.statusLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Color de la sombra
    }

    if (self.isGroup == false){
        BOOL isBusiness = [[appDelegate.activeProfileView objectForKey:@"isBusiness"] boolValue];
        BOOL isEnterprise = [[appDelegate.activeProfileView objectForKey:@"isEnterprise"] boolValue];
        if([statusText isEqualToString:@"TYPING"]){
            self.statusLabel.text = @"writing...";
        } else if([statusText isEqualToString:@"RECORDING_AUDIO"]){
            self.statusLabel.text = @"recording...";
        } else {
            if(isBusiness == false && isEnterprise == false){
                self.statusLabel.text = WSPContactType_toString[REGULARUSER];
            }
            if(isBusiness == true && isEnterprise == false){
                self.statusLabel.text = WSPContactType_toString[BUSINESSUSER];
            }
            if(isEnterprise == true){
                self.statusLabel.text = WSPContactType_toString[ENTERPRISEUSER];
            }
        }
    } else {
        NSMutableArray *participantsNames = [[NSMutableArray alloc] init];
        NSArray *participantsContacts = [[appDelegate.activeProfileView objectForKey:@"groupMetadata"] objectForKey:@"participants"];
        NSLog(@"Hello: %@", appDelegate.activeProfileView);
        for(NSDictionary *participantContact in participantsContacts){
            for(NSDictionary *contact in appDelegate.contactsViewController.contactList){
                if([[contact objectForKey:@"number"] isEqualToString:[[participantContact objectForKey:@"id"] objectForKey:@"user"]]){
                    
                    if([[contact objectForKey:@"number"] isEqualToString:[appDelegate.contactsViewController.myContact objectForKey:@"number"]]){
                        [participantsNames addObject:WSPContactType_toString[YOUUSER]];
                    } else {
                        if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                            [participantsNames addObject:[contact objectForKey:@"shortName"]];
                        } else {
                            [participantsNames addObject:[contact objectForKey:@"formattedNumber"]];
                        }
                    }
                }
            }
        }
        self.statusLabel.text = [participantsNames componentsJoinedByString:@", "];
    }
    
    [self.titleView addSubview:self.nameLabel];
    [self.titleView addSubview:self.statusLabel];
    self.navigationItem.titleView = self.titleView;
}

- (void)profileButtonTapped {
    if(self.isGroup == true){
        appDelegate.activeProfileView = [WhatsAppAPI getGroupInfo:self.contactNumber];
    } else {
        appDelegate.activeProfileView = [WhatsAppAPI getContactInfo:self.contactNumber];
    }
    [self performSelectorOnMainThread:@selector(updateProfileView) withObject:nil waitUntilDone:NO];
}

- (void)updateProfileView {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.title = self.title;
    profileViewController.contactNumber = self.contactNumber;
    profileViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    profileViewController.profileImg.image = self.largeImage;
    [profileViewController release];
}

- (void)reloadChat {
    self.chatMessages = [[WhatsAppAPI getMessagesfromNumber:self.contactNumber] objectForKey:@"chatMessages"];
    
    if(appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        [WhatsAppAPI fetchMessagesfromNumberAsync:self.contactNumber isGroup:self.isGroup light:false];
    }
}

- (void)fetcherDidFinishWithJSON:(NSDictionary *)json error:(NSError *)error {
    if(json){
        [CocoaFetch saveDictionaryToJSON:json withFileName:[NSString stringWithFormat:@"%@-chatMessages", self.contactNumber]];
        if([[json objectForKey:@"fromNumber"] isEqualToString:self.contactNumber]){
            self.chatMessages = [json objectForKey:@"chatMessages"];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y == 0 && self.hiddenMessages > 0 && loaded == true){
        levelNav++;
        UIScrollView *scrollView = self.tableView;
        float oldScrollContentSizeHeight = scrollView.contentSize.height;
        [self.tableView reloadData];
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,scrollView.contentSize.height - oldScrollContentSizeHeight);
        
        // Crear una animación de transición
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - oldScrollContentSizeHeight - 100);
        [UIView commitAnimations];
    } else if (scrollView.contentOffset.y == 0) {
        [self reloadChat];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self freeResourcesForNonVisibleCells];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self freeResourcesForNonVisibleCells];
}

- (void)freeResourcesForNonVisibleCells {
    NSArray *visibleCells = [self.tableView visibleCells];
    NSArray *subviews = [self.tableView subviews];
    
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UITableViewCell class]] && ![visibleCells containsObject:view]) {
            [view removeFromSuperview];
            view = nil;
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.chatMessages.count <= (levelNav * 100)){
        return self.chatMessages.count;
    } else {
        self.hiddenMessages = self.chatMessages.count - (levelNav * 100);
        if(self.hiddenMessages >= 100){
            return (levelNav * 100);
        } else {
            self.hiddenMessages = 0;
            return self.chatMessages.count;
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        NSString *base64String = [data base64EncodedString];
        [WhatsAppAPI sendMessageFromNumber:self.contactNumber isGroup:self.isGroup bodyMsg:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            base64String, @"mediaBase64",
                                                                                            @"true", @"sendAsPhoto",
                                                                                            [CocoaFetch contentTypeForImageData:data], @"mimeType",
                                                                                            nil]];
        [JSMessageSoundEffect playMessageSentSound];
        [WhatsAppAPI fetchMessagesfromNumberAsync:self.contactNumber isGroup:self.isGroup light:NO];
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSLog(@"Video recorded");
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // Descartar el picker cuando el usuario cancela
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    NSMutableDictionary* msgToSend = [[NSMutableDictionary alloc] init];
    [msgToSend setValue:text forKey:@"messageText"];
    if (self.attachToolBarView.hidden == NO){
        [msgToSend setValue:self.attachToolBarView.bubbleReply.msgId forKey:@"replyTo"];
        self.attachToolBarView.hidden = YES;
    }
    [WhatsAppAPI sendMessageFromNumber:self.contactNumber isGroup:self.isGroup bodyMsg:msgToSend];
    [JSMessageSoundEffect playMessageSentSound];
    [WhatsAppAPI clearStatefromNumber:self.contactNumber isGroup:self.isGroup];
    [self finishSend];
    [WhatsAppAPI fetchMessagesfromNumberAsync:self.contactNumber isGroup:self.isGroup light:NO];
}

- (void)attachPressed:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Photos and Videos", @"Camera", @"Location", @"Sticker", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)finishSendVoiceNote
{
    NSData *fileData = [NSData dataWithContentsOfURL:appDelegate.voiceNoteManager.audioRecorder.url];
    if (fileData){
        NSString *base64String = [fileData base64EncodedString];
        [WhatsAppAPI sendMessageFromNumber:self.contactNumber isGroup:self.isGroup bodyMsg:[NSDictionary dictionaryWithObjectsAndKeys:
                base64String, @"mediaBase64",
                @"true", @"sendAsVoiceNote",
                nil]];
        [JSMessageSoundEffect playMessageSentSound];
        [WhatsAppAPI fetchMessagesfromNumberAsync:self.contactNumber isGroup:self.isGroup light:NO];
    }
}

-(void)voiceNoteStatus {
    [WhatsAppAPI setTypingStatusfromNumber:self.contactNumber isGroup:self.isGroup isVoiceNote:true];
}

-(void)voiceNoteClear {
    [WhatsAppAPI clearStatefromNumber:self.contactNumber isGroup:self.isGroup];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"fromMe"] boolValue] == true){
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
    //return (indexPath.row % 2) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyCustom;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*NSString *msgType = [[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"type"];
    if([msgType isEqualToString:@"ptt"]){
        return JSAvatarStyleSquare;
    }*/
    return JSAvatarStyleNone;
}


//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    [WhatsAppAPI setTypingStatusfromNumber:self.contactNumber isGroup:self.isGroup isVoiceNote:false];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Inicializar UIImagePickerController
            self.imagePicker = [[UIImagePickerController alloc] init];
            self.imagePicker.delegate = self;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.allowsEditing = NO;
            self.imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
            
            // Presentar la cámara
            [self presentModalViewController:self.imagePicker animated:YES];
            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                // Verificar si la grabación de video está disponible
                NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                
                if ([availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
                    // Inicializar UIImagePickerController
                    self.imagePicker = [[UIImagePickerController alloc] init];
                    self.imagePicker.delegate = self;
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.imagePicker.allowsEditing = NO;
                    
                    // Configurar para permitir fotos y videos
                    self.imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
                    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                    self.imagePicker.videoMaximumDuration = 60.0; // Duración máxima del video
                    
                    // Presentar la cámara
                    [self presentModalViewController:self.imagePicker animated:YES];
                    
                } else {
                    // Puedes presentar una alerta o simplemente permitir la captura de fotos
                    self.imagePicker = [[UIImagePickerController alloc] init];
                    self.imagePicker.delegate = self;
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.imagePicker.allowsEditing = NO;
                    self.imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil]; // Solo fotos
                    
                    // Presentar la cámara
                    [self presentModalViewController:self.imagePicker animated:YES];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"This device doesn't have an camera"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            break;
        case 2:
            if (IS_IOS4orHIGHER){
                LocationViewController *locationViewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
                [self presentModalViewController:locationViewController animated:YES];
            }
            break;
        case 3:
            
            break;
        default:
            break;
    }
}

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *msgType = [[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"type"];
    if([msgType isEqualToString:@"location"]){
        return nil;
    }
    return [[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"body"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSTimeInterval timeint = [[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"timestamp"] doubleValue];
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:timeint];
    return time;
}


-(BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row > 0){
        NSTimeInterval timeint = [[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"timestamp"] doubleValue];
        NSTimeInterval previoustimeint = [[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)-1] objectForKey:@"timestamp"] doubleValue];
        if([CocoaFetch isDifferentDayWithTimestamp:timeint previousTimestamp:previoustimeint]){
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (NSInteger *)ackForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (int *)[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"ack"] integerValue];
}

- (BOOL)showUserPolicyForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.isGroup == true && ([self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming));
}

- (NSString *)msgIdForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"_serialized"];
}

- (NSString *)userNameForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *author = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"participant"] objectForKey:@"user"];
    
    for(NSDictionary *contact in appDelegate.contactsViewController.contactList){
        if([[contact objectForKey:@"number"] isEqualToString:author]){
            if([[contact objectForKey:@"number"] isEqualToString:[appDelegate.contactsViewController.myContact objectForKey:@"number"]]){
                return WSPContactType_toString[YOUUSER];
            } else {
                if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                    return [contact objectForKey:@"shortName"];
                } else {
                    return [contact objectForKey:@"formattedNumber"];
                }
            }
        }
    }
    return @"";
    
    // Mover esta línea fuera del bucle para devolver un valor predeterminado solo si no se encuentra una coincidencia
    //return [participant objectForKey:@"formattedNumber"];
}

- (BOOL)hasReplyForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"hasQuotedMsg"] boolValue];
}

- (NSString *)quotedTextForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *messageBody = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"quotedMsg"] objectForKey:@"body"];
    NSString *messageType = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"quotedMsg"] objectForKey:@"type"];
    
    if(messageBody == nil){
        return nil;
    }
    
    if([messageType isEqualToString:@"chat"]){
        return [NSString stringWithFormat:@"%@", messageBody];
    } else {
        if([messageType isEqualToString:@"ptt"]){
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[PTT]];
        } else if([messageType isEqualToString:@"audio"]){
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[AUDIO]];
        } else if([messageType isEqualToString:@"image"]) {
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[PICTURE]];
        } else if([messageType isEqualToString:@"sticker"]) {
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[STICKER]];
        } else if([messageType isEqualToString:@"video"]) {
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[VIDEO]];
        } else if([messageType isEqualToString:@"revoked"]) {
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[REVOKED]];
        } else if([messageType isEqualToString:@"location"]) {
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[LOCATION]];
        } else {
            return [NSString stringWithFormat:@"(%@)", WSPMsgMediaType_toString[UNKNOWN]];
        }
    }
}

- (NSString *)quotedUserNameForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* author = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"quotedParticipant"] objectForKey:@"user"];
    
    for(NSDictionary *contact in appDelegate.contactsViewController.contactList){
        if([[contact objectForKey:@"number"] isEqualToString:author]){
            if([[contact objectForKey:@"number"] isEqualToString:[appDelegate.contactsViewController.myContact objectForKey:@"number"]]){
                return WSPContactType_toString[YOUUSER];
            } else {
                if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                    return [contact objectForKey:@"shortName"];
                } else {
                    return [contact objectForKey:@"formattedNumber"];
                }
            }
        }
    }
    return @"";
}

- (BOOL)hasMediaForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *msgType = [[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"type"];
    if([msgType isEqualToString:@"chat"]){
        return NO;
    }
    return YES;
}

- (UIView *)mediaViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *msgType = [[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"type"];
    if([msgType isEqualToString:@"ptt"] || [msgType isEqualToString:@"audio"]){
        VoiceNoteMessage *vnm = [[VoiceNoteMessage alloc] initWithId:[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"_serialized"] withDuration:[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"duration"] integerValue] withViewController:self audioVoiceNote:[msgType isEqualToString:@"ptt"] audioPlayed:([[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"ack"] integerValue] == 4) andMsgType:[self.delegate messageTypeForRowAtIndexPath:indexPath]];
        if ([msgType isEqualToString:@"ptt"]){
            vnm.avatarImage = ([self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming ? [self.dataSource avatarImageForIncomingMessageForRowAtIndexPath:indexPath] : [self.dataSource avatarImageForOutgoingMessage]);
        }
        return vnm;
    }
    if([msgType isEqualToString:@"image"]){
        CGFloat width = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"width"] floatValue] ? : 220.0f;
        CGFloat height = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"height"] floatValue] ? : 220.0f;
        return [[PictureMessage alloc] initWithSize:CGSizeMake(width, height) withId:[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"_serialized"] withFileSize:[[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"size"] intValue] andViewController:self];
    }
    if([msgType isEqualToString:@"sticker"]){
        return [[StickerMessage alloc] initWithId:[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"_serialized"]];
    }
    if ([msgType isEqualToString:@"video"]){
        CGFloat width = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"width"] floatValue] ? : 220.0f;
        CGFloat height = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"height"] floatValue] ? : 220.0f;
        return [[VideoMessage alloc] initWithSize:CGSizeMake(width, height) withId:[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"_serialized"] withDuration:[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"duration"] integerValue]];
    }
    if([msgType isEqualToString:@"revoked"]){
        return [[DeletedMessage alloc] init];
    }
    if([msgType isEqualToString:@"location"]){
        return [[LocationMessage alloc] initWithLatitude:[[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"lat"] floatValue] andLongitude:[[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"_data"] objectForKey:@"lng"] floatValue]];
    }
    return [[UnknownMessage alloc] initWithType:[self.delegate messageTypeForRowAtIndexPath:indexPath]];
}

- (void)downloadAndProcessImageContact:(NSString *)ocontactNumber {
    [WhatsAppAPI downloadAndProcessImage:ocontactNumber andIsGroup:FALSE];
}

- (UIImage *)avatarImageForIncomingMessageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isGroup){
        NSString *author = [[[[self.chatMessages objectAtIndex:(indexPath.row + hiddenMessages)] objectForKey:@"id"] objectForKey:@"participant"] objectForKey:@"user"];UIImage *cachedImage = [appDelegate.profileImages objectForKey:author];
        
        if (cachedImage) {
            return cachedImage;
        }
        
        // Cargar y cachear imagen
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", author]];
        UIImage *image = imageData ? [UIImage imageWithData:imageData] : [UIImage imageNamed:@"PersonalChatOS6Large.png"];
        
        [appDelegate.profileImages setObject:image forKey:author];
        return image;
    } else {
        if(![appDelegate.profileImages objectForKey:self.contactNumber]){
            NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", self.contactNumber]];
            if(!imageData){
                return [UIImage imageNamed:@"PersonalChatOS6Large.png"];
            } else {
                [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:self.contactNumber];
                return [appDelegate.profileImages objectForKey:self.contactNumber];
            }
        } else {
            return [appDelegate.profileImages objectForKey:self.contactNumber];
        }
    }
}

- (UIImage *)avatarImageForOutgoingMessage
{
    if(![appDelegate.profileImages objectForKey:[appDelegate.contactsViewController.myContact objectForKey:@"number"]]){
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", [appDelegate.contactsViewController.myContact objectForKey:@"number"]]];
        if(!imageData){
            return [UIImage imageNamed:@"PersonalChatOS6Large.png"];
        } else {
            [appDelegate.profileImages setObject:[UIImage imageWithData:imageData] forKey:[appDelegate.contactsViewController.myContact objectForKey:@"number"]];
            return [appDelegate.profileImages objectForKey:[appDelegate.contactsViewController.myContact objectForKey:@"number"]];
        }
    } else {
        return [appDelegate.profileImages objectForKey:[appDelegate.contactsViewController.myContact objectForKey:@"number"]];
    }
}

@end