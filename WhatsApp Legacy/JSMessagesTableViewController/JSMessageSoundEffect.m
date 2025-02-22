//
//  JSMessageSoundEffect.m
//
//  Created by Jesse Squires on 2/15/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSMessageSoundEffect.h"

@interface JSMessageSoundEffect ()

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type;

@end

static AVAudioPlayer *audioPlayer;

@implementation JSMessageSoundEffect

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        
        if (error) {
            NSLog(@"Error initializing audio player: %@", error.localizedDescription);
        } else {
            [audioPlayer prepareToPlay];
            audioPlayer.volume = 1.0; // Ajusta el volumen según sea necesario
            [audioPlayer play];
        }
    } else {
        NSLog(@"Error: audio file not found at path: %@", path);
    }
}

+ (void)playMessageReceivedSound
{
    [JSMessageSoundEffect playSoundWithName:@"incoming" type:@"aiff"];
}

+ (void)playMessageSentSound
{
    [JSMessageSoundEffect playSoundWithName:@"send_message" type:@"aiff"];
}

+ (void)playMessageVoiceNoteStartSound
{
    [JSMessageSoundEffect playSoundWithName:@"voice_note_start" type:@"aiff"];
}

+ (void)playMessageVoiceNoteStopSound
{
    [JSMessageSoundEffect playSoundWithName:@"voice_note_stop" type:@"aiff"];
}

+ (void)playMessageVoiceNoteErrorSound
{
    [JSMessageSoundEffect playSoundWithName:@"voice_note_error" type:@"aiff"];
}

+ (void)playMessageAudioStartSound
{
    [JSMessageSoundEffect playSoundWithName:@"audio_start" type:@"aiff"];
}

+ (void)playMessageAudioEndSound
{
    [JSMessageSoundEffect playSoundWithName:@"audio_end" type:@"aiff"];
}

@end