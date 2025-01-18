//
//  StickerMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 11/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "StickerMessage.h"
#import "CocoaFetch.h"
#import "AppDelegate.h"
#import "UIImage+WebP.h"

@implementation StickerMessage
@synthesize stickerView, view, msgId, downloadButton;

- (id)initWithId:(NSString *)messageId
{
    self = [super init];
    if (self) {
        [self setup];
        self.msgId = messageId;
        [self updateImage:self.msgId];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"StickerMessage" owner:self options:nil];
    self.frame = self.view.frame;
    self.tag = (NSInteger)@"StickerMessage";
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)downloadStickerFromURL:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oimageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaimage", urlString]];
    if(oimageData){
        [appDelegate.mediaImages setObject:[UIImage imageWithData:oimageData] forKey:urlString];
    }
    if(![appDelegate.mediaImages objectForKey:urlString]){
        [self performSelectorInBackground:@selector(downloadAndProcessMediaImage:) withObject:urlString];
    } else {
        [self.stickerView setImage:[appDelegate.mediaImages objectForKey:urlString]];
        [self.downloadButton setHidden:YES];
    }
}

- (void)downloadAndProcessMediaImage:(NSString *)imgURL {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *oimageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7301/getMediaData/%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"wspl-address"], imgURL]]];
    if (appDelegate.chatSocket.isConnected == YES && [CocoaFetch connectedToServers]){
        UIImage *profImg = [UIImage imageWithWebPData:oimageData];
        
        // Verificar si la imagen se descargó correctamente
        if (profImg) {
            // Guardar la imagen en el cache y en NSUserDefaults
            [appDelegate.mediaImages setObject:profImg forKey:imgURL];
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(profImg) forKey:[NSString stringWithFormat:@"%@-mediaimage", imgURL]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.stickerView setImage:[appDelegate.mediaImages objectForKey:imgURL]];
            [self.downloadButton setHidden:YES];
            
        } else {
            [self performSelectorOnMainThread:@selector(showDownloadError) withObject:nil waitUntilDone:NO];
        }
    } else {
        [self performSelectorOnMainThread:@selector(showDownloadError) withObject:nil waitUntilDone:NO];
    }
}

- (void)showDownloadError {
    UIAlertView *imgerror = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was a problem downloading the sticker" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [imgerror show];
    [imgerror release];
}

- (void)updateImage:(NSString *)urlString {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData* oimageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-mediaimage", urlString]];
    if(oimageData){
        [appDelegate.mediaImages setObject:[UIImage imageWithData:oimageData] forKey:urlString];
        [self.stickerView setImage:[appDelegate.mediaImages objectForKey:urlString]];
        [self.downloadButton setHidden:YES];
    }
}

- (IBAction)downloadTap:(id)sender {
    [self downloadStickerFromURL:self.msgId];
}

- (void)dealloc {
    [stickerView release];
    [downloadButton release];
    [msgId release];
    [super dealloc];
}

@end
