//
//  InfoStatusViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 14/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "InfoStatusViewController.h"
#import "AppDelegate.h"
#import "WhatsAppAPI.h"

@interface InfoStatusViewController ()

@end

NSString const *iAboutText = @"About";

@implementation InfoStatusViewController
@synthesize txtField;
@synthesize titleBar;

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
    self.txtField.delegate = self;
    [self.txtField becomeFirstResponder];
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnDone:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITableViewCell *myCell = [appDelegate.myStatusViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [WhatsAppAPI setStatusMsg:[txtField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    myCell.textLabel.text = txtField.text;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.titleBar.title = [NSString stringWithFormat:@"%@ (%i)",iAboutText, 139 - [textView.text length]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 139;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [txtField release];
    [titleBar release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTxtField:nil];
    [self setTitleBar:nil];
    [super viewDidUnload];
}
@end
