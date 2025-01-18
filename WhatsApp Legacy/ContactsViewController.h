//
//  ContactsViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 29/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "JSONFetcher.h"

@class AppDelegate;
@interface ContactsViewController : UITableViewController <JSONFetcherDelegate>

@property (copy, nonatomic) NSArray* contactList;
@property (retain, nonatomic) NSArray* filteredContactList;
@property (copy, nonatomic) NSDictionary* myContact;
- (void)reloadContacts;

@end
