//
//  PictureMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 17/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "PictureMessage.h"
#import "CocoaFetch.h"
#import "ContactIImgViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface PictureMessage ()

@end

@implementation PictureMessage
@synthesize msgImg, msgSize, msgId, view, viewController;
//Tap to Download (0KB)

- (id)initWithSize:(CGSize)size withId:(NSString *)messageId withFileSize:(NSInteger)fileSize andViewController:(UIViewController *)oViewController
{
    CGSize redSize = [CocoaFetch resizeToWidth:220.0f fromSize:size];
    self = [super initWithFrame:CGRectMake(0, 0, redSize.width, redSize.height)];
    if (self) {
        [self setup];
        self.msgId = messageId;
        self.msgSize = fileSize;
        self.viewController = oViewController;
        [self.msgImg setTitle:[NSString stringWithFormat:@"Tap to Download (%@)",[CocoaFetch stringFromByteCount:fileSize]] forState:UIControlStateNormal];
        self.msgImg.layer.cornerRadius = 4;
        self.msgImg.clipsToBounds = YES;
        [self updateImage:self.msgId];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"PictureMessage" owner:self options:nil];
    self.view.frame = self.frame;
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)downloadImageFromURL:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oimageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaimage", urlString]];
    if(oimageData){
        [appDelegate.mediaImages setObject:[UIImage imageWithData:oimageData] forKey:urlString];
    }
    if(![appDelegate.mediaImages objectForKey:urlString]){
        [self performSelectorInBackground:@selector(downloadAndProcessMediaImage:) withObject:urlString];
    } else {
        [self.msgImg setBackgroundImage:[appDelegate.mediaImages objectForKey:urlString] forState:UIControlStateNormal];
        [self.msgImg setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)downloadAndProcessMediaImage:(NSString *)imgURL {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *oimageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7301/getMediaData/%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"wspl-address"], imgURL]]];
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        UIImage *profImg = [UIImage imageWithData:oimageData];
        
        // Verificar si la imagen se descargó correctamente
        if (profImg) {
            // Guardar la imagen en el cache y en NSUserDefaults
            [appDelegate.mediaImages setObject:profImg forKey:imgURL];
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(profImg) forKey:[NSString stringWithFormat:@"%@-mediaimage", imgURL]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.msgImg setBackgroundImage:[appDelegate.mediaImages objectForKey:imgURL] forState:UIControlStateNormal];
            [self.msgImg setTitle:@"" forState:UIControlStateNormal];
            UIImageWriteToSavedPhotosAlbum([appDelegate.mediaImages objectForKey:imgURL], self, nil, NULL);
        } else {
            [self performSelectorOnMainThread:@selector(showDownloadError) withObject:nil waitUntilDone:NO];
        }
    } else {
        [self performSelectorOnMainThread:@selector(showDownloadError) withObject:nil waitUntilDone:NO];
    }
}

- (void)updateImage:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oimageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaimage", urlString]];
    if(oimageData){
        [appDelegate.mediaImages setObject:[UIImage imageWithData:oimageData] forKey:urlString];
        [self.msgImg setBackgroundImage:[appDelegate.mediaImages objectForKey:urlString] forState:UIControlStateNormal];
        [self.msgImg setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)showDownloadError {
                            UIAlertView *imgerror = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was a problem downloading the image" delegate:viewController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [imgerror show];
    [imgerror release];
}

- (IBAction)imgTap:(id)sender {
    [self downloadImageFromURL:self.msgId];
}

- (IBAction)imgDoubleTap:(id)sender {
    ContactIImgViewController *cimgvc = [[ContactIImgViewController alloc] init];
    cimgvc.hidesBottomBarWhenPushed = true;
    cimgvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.viewController presentModalViewController:cimgvc animated:YES];
    cimgvc.viewNav.title = @"Preview";
    cimgvc.imgView.image = [self.msgImg backgroundImageForState:UIControlStateNormal];
    [cimgvc release];
}

- (void)dealloc {
    [msgImg release];
    [super dealloc];
}
@end
