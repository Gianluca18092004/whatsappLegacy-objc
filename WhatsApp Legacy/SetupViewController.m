//
//  SetupViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 27/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "SetupViewController.h"
#import "AppDelegate.h"
#import "JSONUtility.h"
#import "AppDelegate.h"

@interface SetupViewController ()

@end

@implementation SetupViewController
@synthesize ipAddressTXT;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [ipAddressTXT resignFirstResponder];
    return true;
}

- (BOOL)isValidIPv4Address:(NSString *)ipAddress {
    // Expresión regular para validar una dirección IPv4
    NSString *ipv4Pattern = @"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\."
    "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\."
    "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\."
    "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
    
    NSPredicate *ipv4Predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipv4Pattern];
    return [ipv4Predicate evaluateWithObject:ipAddress];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [ipAddressTXT setDelegate:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
}

- (void)dealloc
{
    [self setIpAddressTXT:nil];
    [super dealloc];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneSetup:(id)sender {
    if(ipAddressTXT.text.length == 0){
        UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Address and Port must not be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alerta show];
    } else {
        NSString *urlString = ipAddressTXT.text;
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"HEAD"];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (connection) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [ipAddressTXT resignFirstResponder];
            
            HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:HUD];
            HUD.delegate = self;
            HUD.labelText = @"Processing Data";
            [HUD showWhileExecuting:@selector(waitToTimeout) onTarget:self withObject:nil animated:YES];
            
            [appDelegate connectToServerWithIp:ipAddressTXT.text andWithPort:7300];
        } else {
            UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Error" message:@"The Address entered is invalid, only IPv4 is supported" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alerta show];
        }
    }
}

- (void)executeAfterDelay {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setObject:ipAddressTXT.text forKey:@"wspl-address"];
    [appDelegate.tabBarController.view setFrame: [[UIScreen mainScreen] applicationFrame]];
    [appDelegate.window addSubview:appDelegate.tabBarController.view];
}

- (void)waitToTimeout {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sleep(5);
    if(appDelegate.serverConnect == (int*)2) {
        HUD.labelText = @"Synchronizing Messages";
        [appDelegate.chatsViewController loadMessagesFirstTime];
        [self executeAfterDelay];
    } else {
        appDelegate.serverConnect = 0;
        UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Timeout expired. Check your Internet connection or server is not available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alerta show];
    }
}
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

@end
