//
//  AppDelegate.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 27/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tcpSocketChat.h"
#import "ContactsViewController.h"
#import "ChatsViewController.h"
#import "ChatViewController.h"
#import "MyStatusViewController.h"
#import "NewsViewController.h"
#import "SetupViewController.h"
#import "WelcomeViewController.h"
#import "VoiceNoteAPI.h"
#import "JSBubbleView.h"

@interface AppDelegate : UIResponder <tcpSocketChatDelegate, UIApplicationDelegate, UITabBarControllerDelegate>

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) UITabBarController *tabBarController;

@property (retain, nonatomic) WelcomeViewController *welcomeViewController;

@property (retain, nonatomic) ContactsViewController *contactsViewController;

@property (retain, nonatomic) ChatsViewController *chatsViewController;

@property (assign, nonatomic) ChatViewController* chatViewController;

@property (retain, nonatomic) MyStatusViewController *myStatusViewController;

@property (retain, nonatomic) NewsViewController *newsViewController;

@property (nonatomic,retain) tcpSocketChat* chatSocket;

@property (nonatomic,assign) NSInteger* serverConnect;

@property (retain, nonatomic) NSMutableDictionary* profileImages;

@property (retain, nonatomic) NSCache* mediaImages;

@property (retain, nonatomic) NSMutableDictionary* mediaAudios;

@property (copy, nonatomic) NSDictionary* activeProfileView;

@property (nonatomic, retain) VoiceNoteAPI *voiceNoteManager;

-(void)connectToServerWithIp:(NSString *)ipaddress andWithPort:(NSInteger)port;
- (void)loadChatViewWithContactNumber:(NSString *)contactNumber andFromContact:(BOOL)fromContact;

extern NSDictionary* contactList;

@end
