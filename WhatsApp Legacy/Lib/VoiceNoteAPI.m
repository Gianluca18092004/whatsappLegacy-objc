//
//  VoiceNoteAPI.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 12/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "VoiceNoteAPI.h"
#import "JSMessageSoundEffect.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation VoiceNoteAPI
@synthesize audioData, audioPlayer, audioRecorder;

- (void)setupAudioRecorder {
    NSString *tempDir = NSTemporaryDirectory();
    
    NSString *tempFile = [tempDir stringByAppendingPathComponent:@"tempRecording.caf"];
    NSURL *outputFileURL = [NSURL fileURLWithPath:tempFile];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
                              [NSNumber numberWithFloat:44100.0f], AVSampleRateKey,
                              [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:16], AVEncoderBitDepthHintKey,
                              [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:settings error:&error];
    if (error) {
        NSLog(@"Error setting up audio recorder: %@", [error localizedDescription]);
    } else {
        [self.audioRecorder prepareToRecord];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError = nil;
        
        // Configurar la categoría para permitir la reproducción y grabación
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if (sessionError) {
            NSLog(@"Error setting audio session category: %@", [sessionError localizedDescription]);
            return;
        }
        
        // Cambiar la ruta de salida de audio al altavoz
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        // Activar la sesión de audio
        NSError *activationError = nil;
        [session setActive:YES error:&activationError];
        
        if (activationError) {
            NSLog(@"Error activating audio session: %@", [activationError localizedDescription]);
            return;
        }
    }
}

- (void)startRecording {
    if(!self.audioRecorder.recording){
        [self.audioRecorder record];
    } else {
        [self.audioRecorder stop];
        [self.audioRecorder record];
    }
    NSLog(@"Recording started");
}

- (BOOL)stopRecordingNormally:(BOOL)isNormal {
    if(self.audioRecorder.recording && isNormal == YES){
        [JSMessageSoundEffect playMessageVoiceNoteStopSound];
        [self.audioRecorder stop];
        self.audioData = [NSData dataWithContentsOfURL:self.audioRecorder.url];
        return true;
    } else if (!self.audioRecorder.recording){
        [JSMessageSoundEffect playMessageVoiceNoteErrorSound];
        [self.audioRecorder stop];
    }
    return false;
}

- (void)playRecordedAudio {
    if (!self.audioRecorder.recording) {
        // Configura la sesión de audio
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError = nil;
        
        // Configurar la categoría para permitir la reproducción y grabación
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if (sessionError) {
            NSLog(@"Error setting audio session category: %@", [sessionError localizedDescription]);
            return;
        }
        
        // Cambiar la ruta de salida de audio al altavoz
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        // Activar la sesión de audio
        NSError *activationError = nil;
        [session setActive:YES error:&activationError];
        
        if (activationError) {
            NSLog(@"Error activating audio session: %@", [activationError localizedDescription]);
            return;
        }
        
        // Configura el reproductor y reproduce el audio
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:nil];
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer play];
    }

}

- (void)playAudioFromFilePath:(NSData *)data {
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    
    if (error) {
        NSLog(@"Error initializing audio player: %@", [error localizedDescription]);
    } else {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

@end
