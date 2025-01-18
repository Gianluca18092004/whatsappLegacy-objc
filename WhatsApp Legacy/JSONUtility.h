//
//  JSONUtility.h
//  WhatsApp
//
//  Created by Gian Luca Russo on 26/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtility : NSObject

+ (NSDictionary *)JSONParse:(NSString *)dictionary;
+ (NSString *)JSONStringIfy:(NSDictionary *)dictionary;

@end