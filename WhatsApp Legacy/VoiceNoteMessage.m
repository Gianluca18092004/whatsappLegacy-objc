//
//  VoiceNoteMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 16/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "VoiceNoteMessage.h"
#import "WhatsAppAPI.h"
#import "AudioPlayer.h"
#import "CocoaFetch.h"
#import "AppDelegate.h"

#define IS_IOS5orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0))

@implementation VoiceNoteMessage
@synthesize ackImg, profileImg, durationLabel, vnButton, view, msgId, msgDuration, viewController, audioPlayer, slideView, progressUpdateTimer, isVoiceNote, isPlayed, messageType;

- (id)initWithId:(NSString *)messageId withDuration:(NSInteger)duration withViewController:(UIViewController *)oViewController audioVoiceNote:(BOOL)oisVoiceNote audioPlayed:(BOOL)oisPlayed andMsgType:(JSBubbleMessageType)msgType
{
    self = [super init];
    if (self) {
        [self setup];
        self.messageType = msgType;
        self.msgId = messageId;
        self.msgDuration = duration;
        self.isVoiceNote = oisVoiceNote;
        self.isPlayed = oisPlayed;
        self.durationLabel.text = [NSString stringWithFormat:@"0:00 / %@", [CocoaFetch formattedTimeFromSeconds:duration]];
        self.viewController = oViewController;
        [self.slideView setThumbImage:[UIImage imageNamed:@"Scrubber.png"] forState:UIControlStateNormal];
        [self.slideView setMinimumTrackImage:[[UIImage imageNamed:(msgType == JSBubbleMessageTypeIncoming ? @"ScrubberTrackProgressInc.png" : @"ScrubberTrackProgressOut.png")] stretchableImageWithLeftCapWidth:4.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [self.slideView setMaximumTrackImage:[[UIImage imageNamed:@"ScrubberBar.png"] stretchableImageWithLeftCapWidth:4.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [self updateAudio:self.msgId];
        if (!oisVoiceNote){
            [self.ackImg setHidden:YES];
            [self.profileImg setImage:[UIImage imageNamed:@"AudioMessageBackground.png"]];
        }
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"VoiceNoteMessage" owner:self options:nil];
    self.frame = self.view.frame;
    self.tag = (NSInteger)@"VoiceNoteMessage";
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
    self.profileImg.layer.cornerRadius = 6;
    self.profileImg.clipsToBounds = YES;
}

- (void)downloadAudioFromURL:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oaudioData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaaudio", urlString]];
    if(oaudioData){
        [appDelegate.mediaAudios setObject:oaudioData forKey:urlString];
    }
    if(![appDelegate.mediaAudios objectForKey:urlString]){
        [self performSelectorInBackground:@selector(downloadAndProcessMediaAudio:) withObject:urlString];
    } else {
        [self.vnButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        [self.vnButton setImage:[UIImage imageNamed:@"PlayPressed.png"] forState:UIControlStateHighlighted];
    }
}

- (void)downloadAndProcessMediaAudio:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        NSData *oaudioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7301/getAudioData/%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"wspl-address"], urlString]]];
        
        // Verificar si la imagen se descargó correctamente
        if (oaudioData) {
            // Guardar la imagen en el cache y en NSUserDefaults
            [appDelegate.mediaAudios setObject:oaudioData forKey:urlString];
            [[NSUserDefaults standardUserDefaults] setObject:oaudioData forKey:[NSString stringWithFormat:@"%@-mediaaudio", urlString]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setupAudioPlayerWithData:[appDelegate.mediaAudios objectForKey:urlString]];
            [self.vnButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
            [self.vnButton setImage:[UIImage imageNamed:@"PlayPressed.png"] forState:UIControlStateHighlighted];
            
        } else {
            [self performSelectorOnMainThread:@selector(showDownloadError) withObject:nil waitUntilDone:NO];
        }
    } else {
        [self performSelectorOnMainThread:@selector(showDownloadError) withObject:nil waitUntilDone:NO];
    }
}

- (void)updateAudio:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oaudioData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaaudio", urlString]];
    if(oaudioData){
        [appDelegate.mediaAudios setObject:oaudioData forKey:urlString];
        [self setupAudioPlayerWithData:[appDelegate.mediaAudios objectForKey:urlString]];
        [self.vnButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        [self.vnButton setImage:[UIImage imageNamed:@"PlayPressed.png"] forState:UIControlStateHighlighted];
        
    }
}

- (void)showDownloadError {
    UIAlertView *audioerror = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was a problem downloading the audio" delegate:viewController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [audioerror show];
    [audioerror release];
}

- (void)setupAudioPlayerWithData:(NSData *)audioData {
    NSError *error = nil;
    
    // Inicializar AVAudioPlayer con el NSData
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    
    if (error) {
        NSLog(@"Error al inicializar el reproductor: %@", error.localizedDescription);
        return;
    }
    
    // Establecer el delegado para capturar eventos del reproductor
    self.audioPlayer.delegate = self;
    
    // Preparar para la reproducción
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer release];
}

- (void)playAudio {
    // Comenzar la reproducción
    [self.audioPlayer play];
    [self.vnButton setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
    [self.vnButton setImage:[UIImage imageNamed:@"PausePressed.png"] forState:UIControlStateHighlighted];
    
    // Iniciar el temporizador para actualizar la barra de progreso
    self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                target:self
                                                              selector:@selector(updateProgress)
                                                              userInfo:nil
                                                               repeats:YES];
}

- (void)pauseAudio {
    [self.audioPlayer pause];
    
    // Detener el temporizador cuando se pausa
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
    [self.vnButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
    [self.vnButton setImage:[UIImage imageNamed:@"PlayPressed.png"] forState:UIControlStateHighlighted];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
    
    // Resetear la barra de progreso al final
    [self.slideView setValue:0.0];
    [self.vnButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
    [self.vnButton setImage:[UIImage imageNamed:@"PlayPressed.png"] forState:UIControlStateHighlighted];
}

- (void)updateProgress {
    // Calcular el progreso como el tiempo actual de reproducción dividido por la duración total
    float progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    
    // Actualizar la barra de progreso
    //[self.progressView setProgress:progress animated:YES];
    [self.slideView setValue:(progress * (isVoiceNote == YES ? 1 : 2))];
    self.durationLabel.text = [NSString stringWithFormat:@"%@ / %@", [CocoaFetch formattedTimeFromSeconds:self.audioPlayer.currentTime], [CocoaFetch formattedTimeFromSeconds:self.msgDuration]];
}

- (void)dealloc {
    [vnButton release];
    [durationLabel release];
    [slideView release];
    [profileImg release];
    [ackImg release];
    [super dealloc];
}

- (void)setIsPlayed:(BOOL)newIsPlayed {
    if(newIsPlayed){
        self.ackImg.image = [UIImage imageNamed:@"MicReadedBrdt.png"];
    } else {
        if (self.messageType == JSBubbleMessageTypeIncoming){
            self.ackImg.image = [UIImage imageNamed:@"MicNewBrdt.png"];
        }
    }
}

- (UIImage *)avatarImage
{
    return profileImg.image;
}

- (void)setAvatarImage:(UIImage *)newAvatarImage
{
    CGFloat targetWidth = (IS_RETINA ? 96.0 : 48.0); // Ajusta esto según tus necesidades
    CGFloat targetHeight = (IS_RETINA ? 96.0 : 48.0); // Ajusta esto según tus necesidades
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [newAvatarImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    profileImg.image = scaledImage;
}

- (IBAction)vnPressed:(id)sender {
    if (self.audioPlayer == nil){
        [self downloadAudioFromURL:self.msgId];
    } else {
        if (self.audioPlayer.isPlaying){
            [self pauseAudio];
        } else {
            [self playAudio];
        }
    }
}

- (IBAction)updateTime:(id)sender {
    float progress = (self.slideView.value * self.audioPlayer.duration / (isVoiceNote == YES ? 1 : 2));
    [self.audioPlayer setCurrentTime:progress];
}

@end
