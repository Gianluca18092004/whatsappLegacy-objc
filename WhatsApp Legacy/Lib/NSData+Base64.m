//
//  NSDataPollyfill.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 20/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "NSData+Base64.h"

static const char base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (Base64)

- (NSString *)base64EncodedString {
    const uint8_t *input = (const uint8_t *)[self bytes];
    NSInteger length = [self length];
    
    NSMutableString *result = [NSMutableString stringWithCapacity:((length + 2) / 3) * 4];
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        [result appendFormat:@"%c", base64EncodingTable[(value >> 18) & 0x3F]];
        [result appendFormat:@"%c", base64EncodingTable[(value >> 12) & 0x3F]];
        [result appendFormat:@"%c", ((i + 1) < length) ? base64EncodingTable[(value >> 6) & 0x3F] : '='];
        [result appendFormat:@"%c", ((i + 2) < length) ? base64EncodingTable[value & 0x3F] : '='];
    }
    
    return result;
}

@end