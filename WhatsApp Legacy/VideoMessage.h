//
//  VideoMessage.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 12/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JSBubbleView.h"

@interface VideoMessage : UIView

- (id)initWithSize:(CGSize)size withId:(NSString *)messageId withDuration:(NSInteger)duration;
- (void)setup;
@property (retain, nonatomic) IBOutlet UIView* view;
@property (retain, nonatomic) IBOutlet UIImageView *imgPreview;
@property (retain, nonatomic) IBOutlet UILabel *durationLabel;
@property (copy, nonatomic) NSString *msgId;
@property (assign, nonatomic) NSInteger msgDuration;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayerOS4;
- (void)updatePreview:(NSString *)urlString;
- (IBAction)downloadPlayTap:(id)sender;
- (void)downloadVideoFromURL:(NSString *)urlString;
- (void)saveVideoToGalleryWithData:(NSData *)videoData;

@end
