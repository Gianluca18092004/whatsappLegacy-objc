//
//  CGLAlphabetizer.m
//
//  Created by Chris Ladd on 4/26/14.
//  Copyright (c) 2014 Chris Ladd. All rights reserved.
//

#import "CGLAlphabetizer.h"

NSString * const CGLAlphabetizerGroupSortNameKey = @"name";
NSString * const CGLAlphabetizerGroupObjectsKey = @"objects";
NSString * const CGLAlphabetizerGroupDisplayNameKey = @"displayName";

@implementation CGLAlphabetizer

+ (NSDictionary *)alphabetizedDictionaryFromObjects:(NSArray *)objects usingKeyPath:(NSString *)keyPath {
    return [self alphabetizedDictionaryFromObjects:objects
                                      usingKeyPath:keyPath
                          nonAlphabeticPlaceholder:nil];
}

+ (NSMutableArray *)findOrCreateArrayForKey:(NSString *)key inDictionary:(NSMutableDictionary *)dictionary {
    NSMutableArray *array = [dictionary objectForKey:key];
    
    if (!array) {
        array = [NSMutableArray array];
        [dictionary setObject:array forKey:key];
    }
    
    return array;
}

+ (NSMutableDictionary *)findOrCreateDictionaryForKey:(NSString *)key inDictionary:(NSMutableDictionary *)dictionary {
    NSMutableDictionary *keyedDictionary = [dictionary objectForKey:key];
    
    if (!keyedDictionary) {
        keyedDictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:keyedDictionary forKey:key];
    }
    
    return keyedDictionary;
}

+ (NSString *)keyFromObject:(id)object usingKeyPath:(NSString *)keyPath result:(NSString **)keyPathResult placeholder:(NSString *)placeholder maxLength:(NSUInteger)maxLength validCharacterSet:(NSCharacterSet *)validCharacterSet {
    NSString *result = placeholder;
    NSString *key = placeholder;
    
    if ([object respondsToSelector:NSSelectorFromString(keyPath)] || [object isKindOfClass:[NSDictionary class]]) {
        id possibleKey = [object valueForKeyPath:keyPath];
        
        if ([possibleKey isKindOfClass:[NSString class]] && [possibleKey length]) {
            result = possibleKey;
            key = possibleKey;
            
            if (maxLength > 0 && [key length] > maxLength) {
                key = [key substringToIndex:maxLength];
            }
            
            NSString *ignorableBeginning = [self ignorableBeginningWordFromString:key];
            
            if ([ignorableBeginning length]) {
                key = [[key substringFromIndex:[ignorableBeginning length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                key = [key stringByAppendingFormat:@", %@", ignorableBeginning];
            }
            
            if (validCharacterSet) {
                NSCharacterSet *keyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:key];
                if (![validCharacterSet isSupersetOfSet:keyCharacterSet]) {
                    key = placeholder;
                }
            }
        }
    }
    
    if (keyPathResult) {
        *keyPathResult = result;
    }
    
    return key;
}

+ (NSString *)ignorableBeginningWordFromString:(NSString *)string {
    NSArray *ignorableWords = [NSArray arrayWithObjects:@"A ", @"The ", nil];
    
    for (NSString *ignorable in ignorableWords) {
        if ([string rangeOfString:ignorable].location == 0) {
            return ignorable;
        }
    }
    
    return nil;
}

+ (NSDictionary *)groupedDictionaryFromObjects:(NSArray *)objects usingKeyPath:(NSString *)keyPath sortBy:(NSString *)sortableKeyPath nonAlphabeticPlaceholder:(NSString *)placeholder {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *nonLetterPlaceholder = [placeholder length] ? placeholder : @"#";
    for (id object in objects) {
        NSString *name;
        NSString *key = [self keyFromObject:object usingKeyPath:keyPath result:&name placeholder:nonLetterPlaceholder maxLength:0 validCharacterSet:nil];
        
        NSMutableDictionary *keyedDictionary = [self findOrCreateDictionaryForKey:[key uppercaseString]
                                                                     inDictionary:dictionary];
        
        NSMutableArray *array = [self findOrCreateArrayForKey:CGLAlphabetizerGroupObjectsKey inDictionary:keyedDictionary];
        [keyedDictionary setObject:key forKey:CGLAlphabetizerGroupSortNameKey];
        [keyedDictionary setObject:name forKey:CGLAlphabetizerGroupDisplayNameKey];
        
        [array addObject:object];
    }
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortableKeyPath ascending:YES] autorelease];
    for (NSString *key in dictionary) {
        NSMutableDictionary *keyedDictionary = [dictionary objectForKey:key];
        NSMutableArray *objectsArray = [keyedDictionary objectForKey:CGLAlphabetizerGroupObjectsKey];
        [objectsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    return [self alphabetizedDictionaryFromObjects:[dictionary allValues]
                                      usingKeyPath:CGLAlphabetizerGroupSortNameKey
                          nonAlphabeticPlaceholder:placeholder];
}

+ (NSDictionary *)alphabetizedDictionaryFromObjects:(NSArray *)objects
                                       usingKeyPath:(NSString *)keyPath
                           nonAlphabeticPlaceholder:(NSString *)placeholder {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *nonLetterPlaceholder = [placeholder length] ? placeholder : @"#";
    for (id object in objects) {
        NSString *firstLetter = [self keyFromObject:object usingKeyPath:keyPath result:nil placeholder:nonLetterPlaceholder maxLength:1 validCharacterSet:[NSCharacterSet letterCharacterSet]];
        firstLetter = [firstLetter uppercaseString];
        NSMutableArray *array = [self findOrCreateArrayForKey:firstLetter inDictionary:dictionary];
        [array addObject:object];
    }
    
    // now sort all the arrays
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:keyPath ascending:YES] autorelease];
    for (NSString *key in dictionary) {
        [[dictionary objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    return dictionary;
}

+ (NSArray *)indexTitlesFromAlphabetizedDictionary:(NSDictionary *)alphabetizedDictionary {
    return [[alphabetizedDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
