//
//  InfoStatusViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 14/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString const *iAboutText;
@interface InfoStatusViewController : UIViewController <UITextViewDelegate>
@property (retain, nonatomic) IBOutlet UITextView *txtField;
@property (retain, nonatomic) IBOutlet UINavigationItem *titleBar;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnDone:(id)sender;

@end
