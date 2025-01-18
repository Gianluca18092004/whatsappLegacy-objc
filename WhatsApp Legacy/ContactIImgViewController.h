//
//  ContactIImgViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 31/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactIImgViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *imgView;
@property (retain, nonatomic) IBOutlet UINavigationItem *viewNav;
- (IBAction)viewDone:(id)sender;

@end
