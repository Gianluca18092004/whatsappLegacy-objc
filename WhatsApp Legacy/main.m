//
//  main.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 27/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    [pool release];
    return retVal;
}
