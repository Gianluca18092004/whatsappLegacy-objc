//
//  AudioPlayer.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 17/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
- (void)playAudioFromFilePath:(NSString *)filePath;
@end
