//
//  VoiceNoteMessage.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 16/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JSBubbleView.h"

@interface VoiceNoteMessage : UIView <AVAudioPlayerDelegate>
- (id)initWithId:(NSString *)messageId withDuration:(NSInteger)duration withViewController:(UIViewController *)oViewController audioVoiceNote:(BOOL)isVoiceNote audioPlayed:(BOOL)isPlayed andMsgType:(JSBubbleMessageType)msgType;
- (void)setup;
@property (retain, nonatomic) IBOutlet UIView* view;
@property (copy, nonatomic) NSString *msgId;
@property (assign, nonatomic) NSInteger msgDuration;
@property (assign, nonatomic) BOOL isVoiceNote;
@property (assign, nonatomic) BOOL isPlayed;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (retain, nonatomic) IBOutlet UISlider *slideView;
@property (nonatomic, retain) NSTimer *progressUpdateTimer;
@property (retain, nonatomic) IBOutlet UILabel *durationLabel;
@property (retain, nonatomic) IBOutlet UIImageView *profileImg;
@property (retain, nonatomic) IBOutlet UIImageView *ackImg;
@property (retain, nonatomic) IBOutlet UIButton *vnButton;
@property (retain, nonatomic) IBOutlet UIViewController *viewController;
@property (assign, nonatomic) JSBubbleMessageType messageType;
@property (assign, nonatomic) UIImage* avatarImage;
- (void)updateAudio:(NSString *)urlString;
- (void)setupAudioPlayerWithData:(NSData *)audioData;
- (void)playAudio;
- (IBAction)vnPressed:(id)sender;
- (IBAction)updateTime:(id)sender;

@end
