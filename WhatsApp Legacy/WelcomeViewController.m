//
//  WelcomeViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 06/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SetupViewController.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()
@property (retain, nonatomic) AppDelegate *appDelegate;
@end

@implementation WelcomeViewController
@synthesize appDelegate, navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PaymentWPad.jpg"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PaymentWP.jpg"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(id)sender {
    SetupViewController *setupViewController = [[SetupViewController alloc] init];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationTransition:UIModalTransitionStyleCrossDissolve forView:window cache:NO];
    
    [setupViewController.view setFrame: [[UIScreen mainScreen] applicationFrame]];
    [window addSubview:setupViewController.view];
    
    [UIView commitAnimations];
}
- (void)dealloc {
    [self setNavBar:nil];
    [super dealloc];
}
@end
