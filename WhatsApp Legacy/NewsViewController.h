//
//  NewsViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 24/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONFetcher.h"

@interface NewsViewController : UITableViewController <JSONFetcherDelegate>
@property (copy, nonatomic) NSArray* broadcastList;
@property BOOL _hasUnread;
@property BOOL hasUnread;

-(void)reloadNews;
@end
