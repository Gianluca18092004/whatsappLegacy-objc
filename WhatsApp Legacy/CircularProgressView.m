//
//  CircularProgressView.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "CircularProgressView.h"

@implementation CircularProgressView
@synthesize totalBlocks, completedBlocks, maxProgress, completedColor, remainingColor, backgroundImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.totalBlocks = 10; // Por defecto, 10 bloques
        self.completedBlocks = 0; // Ningún bloque completado inicialmente
        self.maxProgress = 1.0; // Progreso máximo por defecto es 1.0 (100%)
        self.completedColor = [UIColor blueColor]; // Color por defecto para completado
        self.remainingColor = [UIColor lightGrayColor]; // Color por defecto para lo restante
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Centro del anillo
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Radio del anillo
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2 - 3.0f;
    
    // Ancho del anillo
    CGFloat lineWidth = 4.0f;
    
    // Dibujar los bloques de progreso
    CGFloat startAngle = -M_PI_2; // Empezar desde arriba
    CGFloat anglePerBlock = (2 * M_PI) / self.totalBlocks; // Ángulo por bloque
    
    for (NSInteger i = 0; i < self.totalBlocks; i++) {
        // Color de bloque: completado o restante
        UIColor *currentColor = (i < self.completedBlocks) ? self.completedColor : self.remainingColor;
        CGContextSetStrokeColorWithColor(ctx, currentColor.CGColor);
        CGContextSetLineWidth(ctx, lineWidth);
        
        CGFloat endAngle = startAngle + anglePerBlock - (self.totalBlocks == 1 ? 0 : 0.05); // Espacio entre bloques
        CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextStrokePath(ctx);
        
        startAngle += anglePerBlock;
    }
    
    // Dibuja la imagen de fondo circular en iOS 3.1 sin UIBezierPath
    if (self.backgroundImage) {
        CGRect imageRect = CGRectMake(4, 4, rect.size.width - 8, rect.size.height - 8);
        
        // Crear un camino circular manualmente
        CGContextAddEllipseInRect(ctx, imageRect);
        CGContextClip(ctx);  // Recortar la imagen en un círculo
        
        // Dibujar la imagen dentro del área circular
        [self.backgroundImage drawInRect:imageRect];
    }
}

@end
