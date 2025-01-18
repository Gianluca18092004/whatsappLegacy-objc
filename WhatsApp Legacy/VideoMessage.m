//
//  VideoMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 12/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "VideoMessage.h"
#import "AppDelegate.h"
#import "CocoaFetch.h"

#define IS_IOS32orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)

@implementation VideoMessage
@synthesize imgPreview;
@synthesize durationLabel;
@synthesize view, msgId, msgDuration, moviePlayer, moviePlayerOS4;

- (id)initWithSize:(CGSize)size withId:(NSString *)messageId withDuration:(NSInteger)duration
{
    CGSize redSize = [CocoaFetch resizeToWidth:220.0f fromSize:size];
    self = [super initWithFrame:CGRectMake(0, 0, redSize.width, redSize.height)];
    if (self) {
        [self setup];
        self.msgId = messageId;
        self.msgDuration = duration;
        self.durationLabel.text = [NSString stringWithFormat:@"%@", [CocoaFetch formattedTimeFromSeconds:duration]];
        [self updatePreview:self.msgId];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"VideoMessage" owner:self options:nil];
    self.view.frame = self.frame;
    self.tag = (NSInteger)@"VideoMessage";
    [self addSubview:self.view];
}

- (IBAction)downloadPlayTap:(id)sender {
    NSString *tempPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.msgId]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:tempPath]) {
        [self performSelectorOnMainThread:@selector(playVideo) withObject:nil waitUntilDone:NO];
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
            [self downloadVideoFromURL:[NSString stringWithFormat:@"http://192.168.100.32:7301/getMediaData/%@", self.msgId]];
        }
    }
}

- (void)dealloc {
    [msgId release];
    [durationLabel release];
    [imgPreview release];
    if(IS_IOS32orHIGHER){
        [moviePlayerOS4 release];
    } else {
        [moviePlayer release];
    }
    [super dealloc];
}

- (void)downloadVideoFromURL:(NSString *)urlString {
    [self performSelectorInBackground:@selector(downloadAndProcessMediaVideo:) withObject:urlString];
}

- (void)downloadAndProcessMediaVideo:(NSString*)urlString {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    if (data) {
        // Guardar video en la galería y reproducirlo
        [self saveVideoToGalleryWithData:data];
    }
}

- (void)saveVideoToGalleryWithData:(NSData *)videoData {
    NSString *tempPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.msgId]];
    [videoData writeToFile:tempPath atomically:YES];
    
    if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempPath)){
        UISaveVideoAtPathToSavedPhotosAlbum(tempPath, self, nil, NULL);
        [self performSelectorOnMainThread:@selector(playVideo) withObject:nil waitUntilDone:NO];

    }
}

- (void)playVideo {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *tempPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.msgId]];
    
    NSURL *videoURL = [NSURL fileURLWithPath:tempPath];
    // Reproducir video
    if(IS_IOS32orHIGHER){
        self.moviePlayerOS4 = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        
        [self.view addSubview:self.moviePlayerOS4.view];
        [appDelegate.chatViewController presentMoviePlayerViewControllerAnimated:self.moviePlayerOS4];
    } else {
        self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        [self.moviePlayer play];
    }
}

- (void)downloadPreviewFromURL:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oimageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaimage", urlString]];
    if(oimageData){
        [appDelegate.mediaImages setObject:[UIImage imageWithData:oimageData] forKey:urlString];
    }
    if(![appDelegate.mediaImages objectForKey:urlString]){
        [self performSelectorInBackground:@selector(downloadAndProcessMediaImage:) withObject:urlString];
    } else {
        [self.imgPreview setImage:[appDelegate.mediaImages objectForKey:urlString]];
    }
}

- (void)downloadAndProcessMediaImage:(NSString *)imgURL {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *oimageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7301/getVideoThumbnail/%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"wspl-address"], imgURL]]];
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        UIImage *profImg = [UIImage imageWithData:oimageData];
        
        // Verificar si la imagen se descargó correctamente
        if (profImg) {
            // Guardar la imagen en el cache y en NSUserDefaults
            [appDelegate.mediaImages setObject:profImg forKey:imgURL];
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(profImg) forKey:[NSString stringWithFormat:@"%@-mediaimage", imgURL]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.imgPreview setImage:[appDelegate.mediaImages objectForKey:imgURL]];
            
        }
    }
}

- (void)updatePreview:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oimageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaimage", urlString]];
    if(oimageData){
        [appDelegate.mediaImages setObject:[UIImage imageWithData:oimageData] forKey:urlString];
        [self.imgPreview setImage:[appDelegate.mediaImages objectForKey:urlString]];
    } else {
        [self downloadPreviewFromURL:self.msgId];
    }
}

@end
