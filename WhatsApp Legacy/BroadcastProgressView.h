//
//  BroadcastProgressView.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BroadcastProgressDelegate <NSObject>
- (void)didUpdateBroadcastIndex:(NSInteger)newIndex;
@end

@interface BroadcastProgressView : UIView

@property (nonatomic, assign) NSTimer *progressTimer;
@property (nonatomic, assign) NSTimer *progressCompletition;
@property (nonatomic, assign) NSInteger blockCompletition;
@property (nonatomic, assign) NSInteger currentBlock;  // Bloque que se está llenando actualmente

@property (nonatomic, assign) NSInteger totalBlocks;      // Número total de bloques
@property (nonatomic, assign) NSInteger completedBlocks;  // Número de bloques completados
@property (nonatomic, retain) UIColor *completedColor;    // Color de los bloques completados
@property (nonatomic, retain) UIColor *remainingColor;    // Color de los bloques restantes

- (void)startProgressAnimation;
- (id)initWithFrame:(CGRect)frame withDelegate:(id<BroadcastProgressDelegate>)odelegate;
@property (nonatomic, retain) id<BroadcastProgressDelegate> delegate;

@end