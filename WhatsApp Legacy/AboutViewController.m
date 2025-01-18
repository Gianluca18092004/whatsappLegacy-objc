//
//  AboutViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 13/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize versionLabel;

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
    self.title = @"About";
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", appVersion];
    [appVersion release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [versionLabel release];
    [super dealloc];
}
@end
