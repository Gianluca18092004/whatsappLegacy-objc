//
//  UnknownMessage.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 08/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBubbleView.h"

@interface UnknownMessage : UITableViewCell
- (id)initWithType:(JSBubbleMessageType)type;
- (void)setup;
@property (retain, nonatomic) IBOutlet UIView* view;
@property (retain, nonatomic) IBOutlet UILabel *lblInfo;
@end
