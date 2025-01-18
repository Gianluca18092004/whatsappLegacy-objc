//
//  AudioPlayer.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 17/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer
@synthesize audioPlayer;

- (void)playAudioFromFilePath:(NSString *)filePath {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    
    if (error) {
        NSLog(@"Error initializing audio player: %@", [error localizedDescription]);
    } else {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

@end
