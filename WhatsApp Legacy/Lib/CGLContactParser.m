//
//  CGLContactParser.m
//  CGLAlphabetizerDemo
//
//  Created by Chris Ladd on 4/26/14.
//  Copyright (c) 2014 Chris Ladd. All rights reserved.
//

#import "CGLContactParser.h"
#import "CGLContact.h"

@implementation CGLContactParser

+ (NSArray *)contactsWithContentsOfFile:(NSString *)filePath {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSString *contactString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    NSArray *lines = [contactString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        // Asumir que la última "palabra" es el apellido
        NSRange finalSpaceRange = [line rangeOfString:@" " options:NSBackwardsSearch];
        
        if (finalSpaceRange.location != NSNotFound) {
            // Crear el contacto usando el nombre y apellido
            NSString *firstName = [line substringToIndex:finalSpaceRange.location];
            NSString *lastName = [line substringFromIndex:NSMaxRange(finalSpaceRange)];
            
            CGLContact *contact = [CGLContact contactWithFirstName:firstName lastName:lastName];
            
            // Agregar el contacto al array si ambos campos tienen contenido
            if ([contact.firstName length] && [[contact lastName] length]) {
                [contacts addObject:contact];
            }
        }
    }
    
    return [contacts copy];
}

@end
