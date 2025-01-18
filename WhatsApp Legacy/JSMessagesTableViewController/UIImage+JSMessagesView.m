//
//  UIImage+JSMessagesView.m
//
//  Created by Jesse Squires on 7/25/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIImage+JSMessagesView.h"

@implementation UIImage (JSMessagesView)

#pragma mark - Avatar styles
- (UIImage *)circleImageWithSize:(CGFloat)size
{
    return [self imageAsRoundedRectWithDiameter:size
                                    borderColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.8f alpha:1.0f]
                                    borderWidth:1.0f
                                   shadowOffSet:CGSizeMake(0.0f, 1.0f)
                                   cornerRadius:size / 2];  // El círculo tiene un radio igual a la mitad del tamaño
}

- (UIImage *)squareImageWithSize:(CGFloat)size
{
    return [self imageAsRoundedRectWithDiameter:size
                                    borderColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.8f alpha:1.0f]
                                    borderWidth:1.0f
                                   shadowOffSet:CGSizeMake(0.0f, 1.0f)
                                   cornerRadius:0.0f];  // Sin esquinas redondeadas
}

- (UIImage *)imageAsRoundedRectWithDiameter:(CGFloat)diameter
                                borderColor:(UIColor *)borderColor
                                borderWidth:(CGFloat)borderWidth
                               shadowOffSet:(CGSize)shadowOffset
                               cornerRadius:(CGFloat)cornerRadius
{
    // Incrementar el tamaño para el borde y la sombra
    CGFloat increase = diameter * 0.15f;
    CGFloat newSize = diameter + increase;
    
    CGRect newRect = CGRectMake(0.0f, 0.0f, newSize, newSize);
    
    // Ajustar la imagen dentro del borde y la sombra
    CGRect imgRect = CGRectMake(increase, increase, newRect.size.width - (increase * 2.0f), newRect.size.height - (increase * 2.0f));
    
    // Usar UIGraphicsBeginImageContext para compatibilidad con iOS 3
    UIGraphicsBeginImageContext(newRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Dibujar sombra si se especifica
    if (!CGSizeEqualToSize(shadowOffset, CGSizeZero)) {
        CGContextSetShadowWithColor(context, shadowOffset, 3.0f, [[UIColor colorWithWhite:0.0f alpha:0.45f] CGColor]);
    }
    
    // Dibujar el borde redondeado
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    
    // Dibujar un rectángulo redondeado con CoreGraphics (reemplaza UIBezierPath)
    CGPathRef roundedRectPath = [self createRoundedRectPathForRect:imgRect radius:cornerRadius];
    CGContextAddPath(context, roundedRectPath);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // Recortar al rectángulo redondeado
    CGContextAddPath(context, roundedRectPath);
    CGContextClip(context);
    
    [self drawInRect:imgRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPathRelease(roundedRectPath);  // Liberar el CGPath
    
    return newImage;
}

- (CGPathRef)createRoundedRectPathForRect:(CGRect)rect radius:(CGFloat)radius {
    // Crear un path de rectángulo redondeado manualmente usando CoreGraphics
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    return path;
}

#pragma mark - Input bar
+ (UIImage *)inputBar
{
    UIImage *inputBarImage = [UIImage imageNamed:@"input-bar.png"];
    // Compatibilidad con iOS 3
    return [inputBarImage stretchableImageWithLeftCapWidth:3.0f topCapHeight:19.0f];
}

+ (UIImage *)inputField
{
    UIImage *inputFieldImage = [UIImage imageNamed:@"input-field.png"];
    // Compatibilidad con iOS 3
    return [inputFieldImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:20.0f];
}

#pragma mark - Bubble cap insets
- (UIImage *)makeStretchableDefaultIncoming {
    return [self stretchableImageWithLeftCapWidth:20.0f topCapHeight:15.0f];
}

- (UIImage *)makeStretchableDefaultOutgoing {
    return [self stretchableImageWithLeftCapWidth:20.0f topCapHeight:15.0f];
}

- (UIImage *)makeStretchableSquareIncoming {
    return [self stretchableImageWithLeftCapWidth:25.0f topCapHeight:15.0f];
}

- (UIImage *)makeStretchableSquareOutgoing {
    return [self stretchableImageWithLeftCapWidth:18.0f topCapHeight:15.0f];
}

- (UIImage *)makeStretchableSquareTimestamp {
    return [self stretchableImageWithLeftCapWidth:14.0f topCapHeight:5.0f];
}

- (UIImage *)makeStretchableSquareReply {
    return [self stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
}

#pragma mark - Incoming message bubbles
+ (UIImage *)bubbleSquareIncoming
{
    return [[UIImage imageNamed:@"bubble-square-incoming.png"] makeStretchableSquareIncoming];
}

+ (UIImage *)bubbleSquareIncomingSelected
{
    return [[UIImage imageNamed:@"bubble-square-incoming-selected.png"] makeStretchableSquareIncoming];
}

#pragma mark - Outgoing message bubbles
+ (UIImage *)bubbleSquareOutgoing
{
    return [[UIImage imageNamed:@"bubble-square-outgoing.png"] makeStretchableSquareOutgoing];
}

+ (UIImage *)bubbleSquareOutgoingSelected
{
    return [[UIImage imageNamed:@"bubble-square-outgoing-selected.png"] makeStretchableSquareOutgoing];
}

#pragma mark - Sticker bubbles
+ (UIImage *)bubbleStickerIncoming
{
    return [[UIImage imageNamed:@"bubble-sticker-incoming.png"] makeStretchableSquareTimestamp];
}

+ (UIImage *)bubbleStickerOutgoing
{
    return [[UIImage imageNamed:@"bubble-sticker-outgoing.png"] makeStretchableSquareTimestamp];
}

+ (UIImage *)bubbleStickerSelected
{
    return [[UIImage imageNamed:@"bubble-sticker-selected.png"] makeStretchableSquareTimestamp];
}

#pragma mark - Timestamp message bubbles
+ (UIImage *)bubbleSquareTimestamp
{
    return [[UIImage imageNamed:@"bubble-square-timestamp.png"] makeStretchableSquareTimestamp];
}

#pragma mark - Reply message bubbles
+ (UIImage *)bubbleSquareReply
{
    return [[UIImage imageNamed:@"replyback.png"] makeStretchableSquareReply];
}

#pragma mark - Sticker Manager
+ (UIImage *)stickerIcon
{
    return [UIImage imageNamed:@"ksticker.png"];
}

+ (UIImage *)stickerIconPressed
{
    return [UIImage imageNamed:@"kstickerPressed.png"];
}

+ (UIImage *)keyboardIcon
{
    return [UIImage imageNamed:@"kinormal.png"];
}

+ (UIImage *)keyboardIconPressed
{
    return [UIImage imageNamed:@"kinormalPressed.png"];
}

#pragma mark - Attach Box
+ (UIImage *)closeNotification
{
    return [UIImage imageNamed:@"NotificationClose.png"];
}

+ (UIImage *)closeNotificationSelected
{
    return [UIImage imageNamed:@"NotificationCloseSelected.png"];
}

@end

