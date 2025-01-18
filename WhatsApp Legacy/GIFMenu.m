//
//  AttachMenu.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 02/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "GIFMenu.h"

@implementation GIFMenu
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
    [[NSBundle mainBundle] loadNibNamed:@"GIFMenu" owner:self options:nil];
    self.frame = self.view.frame;
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)frame {
    [super drawRect:frame];
    [[[UIImage imageNamed:@"keyboard-em.png"] stretchableImageWithLeftCapWidth:1.0f topCapHeight:214.0f] drawInRect:frame];
}

@end
