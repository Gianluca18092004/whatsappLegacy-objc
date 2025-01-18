//
//  JSBubbleTimestamp.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 07/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "JSBubbleTimestamp.h"
#import "JSMessageInputView.h"
#import "UIImage+JSMessagesView.h"
#import "CocoaFetch.h"

@implementation oJSBubbleTimestamp

@synthesize timestamp;

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 22.0f

#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization
- (id)withFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if(self) {
        [self setup];
    }
    //[[UIImage imageNamed:@"bubble-square-timestamp"] makeStretchableSquareIncoming];
    return self;
}

- (void)dealloc
{
    [timestamp release];
    [super dealloc];
}

- (void)setTimestamp:(NSDate *)newTimestamp {
    if (timestamp != newTimestamp) {
        [timestamp release];
        timestamp = [newTimestamp retain];
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)frame {
    [super drawRect:frame];
    
    // Dibuja la imagen de burbuja
    UIImage *image = [self bubbleImage];
    CGRect bubbleFrame = [self bubbleFrame];
    [image drawInRect:bubbleFrame];
    
    // Formatear la fecha
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *timestampString = [dateFormatter stringFromDate:self.timestamp];
    
    // Obtener tamaño del texto
    CGSize textSize = [timestampString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
                                  constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                      lineBreakMode:UILineBreakModeWordWrap];
    
    // Definir el frame del texto
    CGRect textFrame = CGRectMake((self.frame.size.width - textSize.width) / 2,
                                  kPaddingTop + kMarginTop + 0.0f,
                                  textSize.width,
                                  textSize.height);
    
    // Establecer color del texto
    [[CocoaFetch colorFromHexString:@"#365C70"] set];
    
    // Dibujar el texto de la fecha
    [timestampString drawInRect:textFrame
                       withFont:[UIFont boldSystemFontOfSize:14.0f]
                  lineBreakMode:UILineBreakModeWordWrap
                      alignment:UITextAlignmentLeft];
    
    // Liberar el formateador de fechas
    [dateFormatter release];
}

- (CGRect)bubbleFrame {
    CGSize bubbleSize;
    if(IS_IOS4orHIGHER){
        bubbleSize = [oJSBubbleTimestamp bubbleSizeForText:[NSDateFormatter localizedStringFromDate:self.timestamp
                                                                                                 dateStyle:NSDateFormatterLongStyle
                                                                                          timeStyle:NSDateFormatterNoStyle]];
        return CGRectMake((self.frame.size.width - bubbleSize.width) / 2,
                          kMarginTop,
                          bubbleSize.width,
                          bubbleSize.height);
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSString *timestampString = [dateFormatter stringFromDate:self.timestamp];
        
        // Obtener tamaño de la burbuja
        bubbleSize = [timestampString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
                                        constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                            lineBreakMode:UILineBreakModeWordWrap];
        
        // Liberar el formateador de fechas
        [dateFormatter release];
        return CGRectMake((self.frame.size.width - bubbleSize.width - 16) / 2,
                          kMarginTop,
                          bubbleSize.width + 16,
                          bubbleSize.height + 12);
    }
}

- (UIImage *)bubbleImage {
    return [UIImage bubbleSquareTimestamp];
}

+ (CGSize)textSizeForTimestamp:(NSString *)txt
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat maxHeight = [JSMessageInputView textViewLineHeight];
    
    CGSize textSize = [txt sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(maxWidth, maxHeight)
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat adjustedWidth = textSize.width;
    
    return CGSizeMake(adjustedWidth, textSize.height);
}

+ (CGSize)bubbleSizeForText:(NSString *)txt
{
    CGSize textSize = [oJSBubbleTimestamp textSizeForTimestamp:txt];
    
    CGFloat bubbleWidth = textSize.width + kBubblePaddingRight;
    
    return CGSizeMake(bubbleWidth,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

@end
