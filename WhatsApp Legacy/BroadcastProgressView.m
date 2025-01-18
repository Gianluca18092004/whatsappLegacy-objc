//
//  BroadcastProgressView.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "BroadcastProgressView.h"

@implementation BroadcastProgressView
@synthesize blockCompletition, totalBlocks, completedBlocks, completedColor, remainingColor, progressTimer, progressCompletition, currentBlock, delegate;

- (id)initWithFrame:(CGRect)frame withDelegate:(id<BroadcastProgressDelegate>)odelegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Valores por defecto
        self.blockCompletition = 0;
        self.totalBlocks = 10;
        self.completedBlocks = 3;
        self.completedColor = [UIColor redColor];
        self.remainingColor = [UIColor lightGrayColor];
        self.backgroundColor = [UIColor clearColor];
        if(odelegate){
            self.delegate = odelegate;
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat blockWidth = rect.size.width / self.totalBlocks;
    
    for (NSInteger i = 0; i < self.totalBlocks; i++) {
        CGRect blockRect; // Espacio entre bloques
        if (i == 0){
            blockRect = CGRectMake(0, 0, blockWidth, rect.size.height);
        } else {
            blockRect = CGRectMake((i * blockWidth) + 2, 0, blockWidth - 2, rect.size.height);
        }
        UIColor *color = self.remainingColor;
        [color setFill];
        UIRectFill(blockRect);
        if (i < self.completedBlocks){
            UIColor *color = self.completedColor;
            [color setFill];
            UIRectFill(blockRect);
        }
        if (i == self.completedBlocks){
            if (i == 0){
                blockRect = CGRectMake(0, 0, ((blockWidth / 50) * blockCompletition), rect.size.height);
            } else {
                blockRect = CGRectMake((i * blockWidth) + 2, 0, ((blockWidth / 50) * blockCompletition) - 2, rect.size.height);
            }
            UIColor *color = self.completedColor;
            [color setFill];
            UIRectFill(blockRect);
        }
    }
}

- (void)startProgressAnimation {
    currentBlock = self.completedBlocks;
    self.blockCompletition = 0;
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                     target:self
                                                   selector:@selector(updateProgress)
                                                   userInfo:nil
                                                    repeats:YES];
    progressCompletition = [NSTimer scheduledTimerWithTimeInterval:0.06
                                     target:self
                                   selector:@selector(updateBlockCompletition)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)updateProgress {
    if (currentBlock < self.totalBlocks) {
        self.blockCompletition = 0;
        self.completedBlocks = currentBlock + 1;
        currentBlock++;
        [self setNeedsDisplay];  // Redibuja la vista
        if ([self.delegate respondsToSelector:@selector(didUpdateBroadcastIndex:)])
        {
            [self.delegate didUpdateBroadcastIndex:currentBlock];
        }
    } else {
        [progressTimer invalidate];
        progressTimer = nil;
    }
}

- (void)updateBlockCompletition
{
    self.blockCompletition++;
    [self setNeedsDisplay];
}

@end
