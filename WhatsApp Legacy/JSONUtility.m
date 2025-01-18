//
//  JSONUtility.m
//  WhatsApp
//
//  Created by Gian Luca Russo on 26/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "JSONUtility.h"
#import "JSONKit.h"

@implementation JSONUtility

+ (NSDictionary *)JSONParse:(NSString *)data {
    if (!data) {
        NSLog(@"Input string is nil");
        return nil;
    };
    
    // Convertir el string a NSDictionary usando JSONKit
    NSDictionary *jsonObject = [data objectFromJSONString];
    if (!jsonObject) {
        NSLog(@"Error converting string to dictionary.");
    }
    return jsonObject;
}

+ (NSString *)JSONStringIfy:(NSDictionary *)dictionary {
    if (!dictionary) {
        NSLog(@"Input dictionary is nil");
        return nil;
    };
    
    // Convertir el string a NSDictionary usando JSONKit
    NSString *jsonString = [dictionary JSONString];
    if (!jsonString) {
        NSLog(@"Error converting dictionary to string.");
    }
    return jsonString;
}

@end