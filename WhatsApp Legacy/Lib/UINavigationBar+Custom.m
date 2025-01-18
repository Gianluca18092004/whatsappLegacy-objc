//
//  UINavigationBar+Custom.m
//  LiteTube
//
//  Created by Gian Luca Russo on 05/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "UINavigationBar+Custom.h"
#import "objc/runtime.h"


static char const *const kHeight = "Height";
@implementation UINavigationBar (CustomHeight)

- (void)setHeight:(CGFloat)height
{
    objc_setAssociatedObject(self, kHeight, [NSNumber numberWithFloat:height], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)height
{
    return objc_getAssociatedObject(self, kHeight);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize;
    
    if (self.height) {
        newSize = CGSizeMake(self.superview.bounds.size.width, [self.height floatValue]);
    } else {
        newSize = [super sizeThatFits:size];
    }
    
    return newSize;
}
@end