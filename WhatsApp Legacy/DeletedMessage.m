//
//  DeletedMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 20/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "DeletedMessage.h"

@implementation DeletedMessage
@synthesize view;

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"DeletedMessage" owner:self options:nil];
    self.frame = self.view.frame;
    self.tag = (NSInteger)@"DeletedMessage";
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)dealloc {
    [super dealloc];
}

@end
