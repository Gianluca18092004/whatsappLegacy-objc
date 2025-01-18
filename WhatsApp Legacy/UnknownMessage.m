//
//  UnknownMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 08/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "UnknownMessage.h"

@implementation UnknownMessage
@synthesize view;
@synthesize lblInfo;

- (id)initWithType:(JSBubbleMessageType)type
{
    self = [super init];
    if (self) {
        [self setup];
        lblInfo.text = [NSString stringWithFormat:@"You have %@ an message, but it is not compatible with this WhatsApp version.", (type == JSBubbleMessageTypeOutgoing ? @"sended" : @"received")];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"UnknownMessage" owner:self options:nil];
    self.frame = self.view.frame;
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)dealloc {
    [lblInfo release];
    [super dealloc];
}
@end
