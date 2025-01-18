//
//  AppDelegate.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 27/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONUtility.h"
#import "WhatsAppAPI.h"

#import "SettingsViewController.h"
#import "SetupViewController.h"

#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
#define IS_IOS5orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0))

@implementation AppDelegate
@synthesize chatSocket = _chatSocket, serverConnect, window, activeProfileView, chatViewController, contactsViewController, myStatusViewController, chatsViewController, newsViewController, welcomeViewController, tabBarController, profileImages, mediaImages, mediaAudios, voiceNoteManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.voiceNoteManager = [[VoiceNoteAPI alloc] init];
    [self.voiceNoteManager setupAudioRecorder];
    self.serverConnect = 0;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.contactsViewController = [[ContactsViewController alloc] initWithNibName:@"ContactsViewController" bundle:nil];
    self.contactsViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    self.chatsViewController = [[ChatsViewController alloc] initWithNibName:@"ChatsViewController" bundle:nil];
    self.chatsViewController.tabBarItem.image = [UIImage imageNamed:@"Chats.png"];
    self.chatViewController = [[ChatViewController alloc] init];
    UIViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"Settings.png"];
    settingsViewController.title = NSLocalizedString(@"Settings", @"Settings");
    settingsViewController.navigationItem.title = settingsViewController.title;
    self.myStatusViewController = [[MyStatusViewController alloc] initWithNibName:@"MyStatusViewController" bundle:nil];
    self.myStatusViewController.tabBarItem.image = [UIImage imageNamed:@"My status.png"];
    self.myStatusViewController.title = NSLocalizedString(@"My Status", @"My Status");
    self.newsViewController = [[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:nil];
    self.newsViewController.tabBarItem.image = [UIImage imageNamed:@"News.png"];
    self.newsViewController.title = NSLocalizedString(@"News", @"News");
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             [[UINavigationController alloc] initWithRootViewController:self.myStatusViewController],
                                             [[UINavigationController alloc] initWithRootViewController:self.contactsViewController],
                                             [[UINavigationController alloc] initWithRootViewController:self.chatsViewController],
                                             [[UINavigationController alloc] initWithRootViewController:self.newsViewController],
                                             [[UINavigationController alloc] initWithRootViewController:settingsViewController],
                                             nil];
    self.tabBarController.selectedIndex = 2;
    
    /*[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];*/
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"wspl-address"] != nil){
        [self connectToServerWithIp:[[NSUserDefaults standardUserDefaults] stringForKey:@"wspl-address"] andWithPort:7300];
        [self.tabBarController.view setFrame: [[UIScreen mainScreen] applicationFrame]];
        [self.window addSubview: self.tabBarController.view];
    } else {
        self.welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
        [self.welcomeViewController.view setFrame: [[UIScreen mainScreen] applicationFrame]];
        [self.window addSubview: self.welcomeViewController.view];
    }
    [[self tabBarController]setDelegate:self];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    return YES;
}
-(void)dealloc
{
    self.chatSocket = nil;
    [super dealloc];
}

- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationPortraitUpsideDown){
        CGAffineTransform transform;
        
        if(orientation != UIDeviceOrientationPortraitUpsideDown){
            switch (orientation) {
                case UIDeviceOrientationLandscapeLeft:
                    transform = CGAffineTransformMakeRotation(M_PI_2);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    transform = CGAffineTransformMakeRotation(-M_PI_2);
                    break;
                case UIDeviceOrientationPortrait:
                default:
                    transform = CGAffineTransformIdentity;
                    break;
            }
            
            /*[UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];*/
            [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
            self.tabBarController.view.transform = transform;
            [self.tabBarController.view setFrame: [[UIScreen mainScreen] applicationFrame]];
            [self.window layoutIfNeeded];
            //[UIView commitAnimations];
        }
    }
}

-(void)checkConnection
{
    if(![_chatSocket isConnected])
    {
        [_chatSocket reconnect];
    }
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    /*switch(self.tabBarController.selectedIndex){
        case 0:
            [self.chatsViewController reloadChats];
            break;
        case 1:
            [self.chatsViewController reloadChats];
            break;
    }*/
}

-(void)receivedMessage:(NSString *)data
{
    if(self.serverConnect == 0){
        NSDictionary *jsonObject = [JSONUtility JSONParse:data];
        NSString *sender = [jsonObject objectForKey:@"sender"];
        NSString *token = [jsonObject objectForKey:@"token"];
        
        if([token isEqualToString:@"3qGT_%78Dtr|&*7ufZoO"] && [sender isEqualToString:@"wspl-server"]){
            self.serverConnect = (int*)1;
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"wspl-client", @"sender",
                                        @"vC.I)Xsfe(;p4YB6E5@y", @"token",
                                        nil];
            
            NSString *jsonString = [JSONUtility JSONStringIfy:dictionary];
            [self.chatSocket sendMessage:jsonString];
        } else {
            [_chatSocket disconnect];
        }
    } else if (self.serverConnect == (int*)1){
        NSDictionary *jsonObject = [JSONUtility JSONParse:data];
        NSString *sender = [jsonObject objectForKey:@"sender"];
        NSString *response = [jsonObject objectForKey:@"response"];
        
        if([response isEqualToString:@"ok"] && [sender isEqualToString:@"wspl-server"]){
            self.serverConnect = (int*)2;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notificationIsActive"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            [_chatSocket disconnect];
        }
    } else if (self.serverConnect == (int*)2){
        NSDictionary *jsonObject = [JSONUtility JSONParse:data];
        NSString *sender = [jsonObject objectForKey:@"sender"];
        NSString *response = [jsonObject objectForKey:@"response"];
        
        if([response isEqualToString:@"CONTACT_CHANGE_STATE"] && [sender isEqualToString:@"wspl-server"]){
            NSDictionary *body = [jsonObject objectForKey:@"body"];
            NSString *from = [body objectForKey:@"from"];
            NSString *status = [body objectForKey:@"status"];
            if(self.chatViewController.isGroup == false && [self.chatViewController.contactNumber isEqualToString:from]){
                [self.chatViewController loadStatusText:NO withDic:nil andStatus:status];
            }
        }
        if(([response isEqualToString:@"NEW_MESSAGE"] || [response isEqualToString:@"ACK_MESSAGE"] || [response isEqualToString:@"REVOKE_MESSAGE"]) && [sender isEqualToString:@"wspl-server"]){
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(delegateReloadChats)
                                           userInfo:nil
                                            repeats:NO];
        }
        if([response isEqualToString:@"NEW_MESSAGE_NOTI"] && [sender isEqualToString:@"wspl-server"]) {
            NSDictionary *body = [jsonObject objectForKey:@"body"];
            NSString *from = [body objectForKey:@"from"];
            if(IS_IOS5orHIGHER){
                if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                    NSString *author = [body objectForKey:@"author"];
                    NSString *messageBody = [body objectForKey:@"msgBody"];
                    NSString *messageType = [body objectForKey:@"type"];
                    NSString* userThatWrited = @"";
                    
                    if([author length] > 0){
                        NSString *groupName = @"";
                        for(NSDictionary *group in self.chatsViewController.groupList){
                            if([[[group objectForKey:@"id"] objectForKey:@"user"] isEqualToString:from]){
                                groupName = [group objectForKey:@"name"];
                            }
                        }
                        for(NSDictionary *contact in self.contactsViewController.contactList){
                            if([[contact objectForKey:@"number"] isEqualToString:author]){
                                
                                if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                                    userThatWrited = [NSString stringWithFormat:@"%@ - %@: ", groupName, [contact objectForKey:@"shortName"]];
                                } else {
                                    userThatWrited = [NSString stringWithFormat:@"%@ - %@: ", groupName, [contact objectForKey:@"formattedNumber"]];
                                }
                            }
                        }
                    } else {
                        for(NSDictionary *contact in self.contactsViewController.contactList){
                            if([[contact objectForKey:@"number"] isEqualToString:from]){
                                
                                if([[contact objectForKey:@"isMyContact"] boolValue] == true){
                                    userThatWrited = [NSString stringWithFormat:@"%@: ", [contact objectForKey:@"shortName"]];
                                } else {
                                    userThatWrited = [NSString stringWithFormat:@"%@: ", [contact objectForKey:@"formattedNumber"]];
                                }
                            }
                        }
                    }
                    
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                    if([messageType isEqualToString:@"chat"]){
                        localNotification.alertBody = [NSString stringWithFormat:@"%@%@", userThatWrited, messageBody];
                        localNotification.userInfo = body;
                    } else {
                        if([messageType isEqualToString:@"ptt"]){
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[PTT]];
                        } else if([messageType isEqualToString:@"audio"]){
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[AUDIO]];
                        } else if([messageType isEqualToString:@"image"]) {
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[PICTURE]];
                        } else if([messageType isEqualToString:@"video"]) {
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[VIDEO]];
                        } else if([messageType isEqualToString:@"sticker"]) {
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[STICKER]];
                        } else if([messageType isEqualToString:@"revoked"]) {
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[REVOKED]];
                        } else if([messageType isEqualToString:@"location"]) {
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[LOCATION]];
                        } else {
                            localNotification.alertBody = [NSString stringWithFormat:@"%@(%@)", userThatWrited, WSPMsgMediaType_toString[UNKNOWN]];
                        }
                    }
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }
            }
            if((![[UIApplication sharedApplication] respondsToSelector:@selector(applicationState)] || [UIApplication sharedApplication].applicationState == UIApplicationStateActive) && [chatViewController.contactNumber isEqualToString:from]){
                [JSMessageSoundEffect playMessageReceivedSound];
                [WhatsAppAPI sendSeenfromNumber:self.chatViewController.contactNumber isGroup:self.chatViewController.isGroup];
            }
        }
        if (([response isEqualToString:@"NEW_MESSAGE_NOTI"] || [response isEqualToString:@"NEW_MESSAGE"] || [response isEqualToString:@"ACK_MESSAGE"] || [response isEqualToString:@"REVOKE_MESSAGE"]) && [sender isEqualToString:@"wspl-server"]){
            if(![[UIApplication sharedApplication] respondsToSelector:@selector(applicationState)] || [UIApplication sharedApplication].applicationState == UIApplicationStateActive){
                [WhatsAppAPI fetchMessagesfromNumberAsync:chatViewController.contactNumber isGroup:chatViewController.isGroup light:NO];
            }
        }
        if (([response isEqualToString:@"NEW_BROADCAST_NOTI"] || [response isEqualToString:@"ACK_MESSAGE"] || [response isEqualToString:@"REVOKE_MESSAGE"]) && [sender isEqualToString:@"wspl-server"]) {
            [self.newsViewController reloadNews];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Verificar si la aplicación está en primer plano o en segundo plano
    if (application.applicationState != UIApplicationStateActive) {
        NSDictionary *userInfo = notification.userInfo;
        if(![chatViewController.contactNumber isEqualToString:[userInfo objectForKey:@"from"]]){
            [chatViewController.navigationController popToRootViewControllerAnimated:NO];
            [self loadChatViewWithContactNumber:[userInfo objectForKey:@"from"] andFromContact:NO];
        }
    }
}

- (void)loadChatViewWithContactNumber:(NSString *)contactNumber andFromContact:(BOOL)fromContact {
    NSDictionary* dic = (fromContact == YES ? [WhatsAppAPI getContactInfo:contactNumber] : [WhatsAppAPI getChatInfo:contactNumber]);
    self.chatViewController.hidesBottomBarWhenPushed = true;
    self.chatViewController.title = [dic objectForKey:@"name"];
    
    
    self.chatViewController.contactNumber = (fromContact == YES ? [dic objectForKey:@"number"] : [[dic objectForKey:@"id"] objectForKey:@"user"]);
    self.chatViewController.isGroup = (fromContact == NO ? [[dic objectForKey:@"isGroup"] boolValue] : false);
    self.chatViewController.isReadOnly = [[dic objectForKey:@"isReadOnly"] boolValue];
    self.chatViewController.timestamp = (fromContact == NO ? [[dic objectForKey:@"timestamp"] integerValue] : 0);
    self.chatViewController.chatContacts = (fromContact == NO ? chatsViewController.groupList : nil);
    
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-largeprofile", self.chatViewController.contactNumber]];
    if(!imageData){
        if([self.chatViewController.contactNumber isEqualToString:@"0"]){
            self.chatViewController.largeImage = [UIImage imageNamed:@"oficialprofile.png"];
        } else {
            if(self.chatViewController.isGroup == false){
                self.chatViewController.largeImage = [UIImage imageNamed:@"PersonalChatOS6Large.png"];
            } else {
                self.chatViewController.largeImage = [UIImage imageNamed:@"GroupChatOS6Large.png"];
            }
        }
    } else {
        [self.profileImages setObject:[UIImage imageWithData:imageData] forKey:self.chatViewController.contactNumber];
        self.chatViewController.largeImage = [UIImage imageWithData:imageData];
    }
    
    // Redimensionar la imagen para mejorar la calidad en pantallas no Retina
    CGFloat targetWidth = (IS_RETINA ? 64.0 : 32.0); // Ajusta esto según tus necesidades
    CGFloat targetHeight = (IS_RETINA ? 64.0 : 32.0); // Ajusta esto según tus necesidades
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [self.chatViewController.largeImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[profileButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [profileButton setImage:scaledImage forState:UIControlStateNormal];
    profileButton.frame = CGRectMake(0, 0, 32, 32);
    profileButton.layer.cornerRadius = 4; // Hace la imagen redonda
    profileButton.clipsToBounds = YES;
    [profileButton addTarget:self.chatViewController action:@selector(profileButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.chatViewController.isGroup == false){
        self.activeProfileView = (fromContact == YES ? dic : [WhatsAppAPI getContactInfo:self.chatViewController.contactNumber]);
    } else {
        self.activeProfileView = [WhatsAppAPI getGroupInfo:self.chatViewController.contactNumber];
    }
    [self.chatViewController loadStatusText:fromContact withDic:dic andStatus:nil];
    
    if (self.chatViewController.isReadOnly == true){
        [self.chatViewController.inputToolBarView removeFromSuperview];
    } else {
        [self.chatViewController.view addSubview:self.chatViewController.inputToolBarView];
    }
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.chatViewController.navigationItem.rightBarButtonItem = rightBarButton;
    if (fromContact){
        [self.contactsViewController.view endEditing:YES];
        [self.contactsViewController.navigationController pushViewController:self.chatViewController animated:YES];
    } else {
        [self.chatsViewController.view endEditing:YES];
        [self.chatsViewController.navigationController pushViewController:self.chatViewController animated:YES];
    }
}

- (void)delegateReloadChats {
    [self.chatsViewController reloadChats];
}

-(void)connectToServerWithIp:(NSString *)ipaddress andWithPort:(NSInteger)port
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _chatSocket = [[tcpSocketChat alloc] initWithDelegate:self AndSocketHost:ipaddress AndPort:port];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if(IS_IOS4orHIGHER){
        UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid; // Inicializar la variable
        
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
        }];
        
        // Mantener el socket activo en segundo plano
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Mantener la tarea en ejecución en segundo plano
            while (bgTask != UIBackgroundTaskInvalid) {
                [NSThread sleepForTimeInterval:1];
            }
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(delegateReloadChats)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
