//
//  VoiceNoteAPI.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 12/08/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VoiceNoteAPI : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSData *audioData;

- (void)setupAudioRecorder;
- (void)startRecording;
- (BOOL)stopRecordingNormally:(BOOL)isNormal;
- (void)playRecordedAudio;
- (void)playAudioFromFilePath:(NSData *)data;
@end
