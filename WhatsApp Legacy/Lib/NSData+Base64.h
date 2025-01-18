//
//  NSDataPollyfill.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 20/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

- (NSString *)base64EncodedString;

@end
