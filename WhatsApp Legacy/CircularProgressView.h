//
//  CircularProgressView.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularProgressView : UIView

@property (nonatomic, assign) NSInteger totalBlocks;    // Número total de bloques (por ejemplo, 10)
@property (nonatomic, assign) NSInteger completedBlocks; // Bloques completados (por ejemplo, 3)
@property (nonatomic, assign) CGFloat maxProgress; // Progreso máximo (por defecto es 1.0)
@property (nonatomic, retain) UIColor *completedColor;  // Color de los bloques completados
@property (nonatomic, retain) UIColor *remainingColor;  // Color de los bloques restantes
@property (nonatomic, retain) UIImage *backgroundImage; // Imagen de fondo del anillo

@end