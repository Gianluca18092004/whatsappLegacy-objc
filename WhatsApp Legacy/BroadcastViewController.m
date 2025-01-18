//
//  BroadcastViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "BroadcastViewController.h"
#import "AppDelegate.h"
#import "CocoaFetch.h"

#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)

@interface BroadcastViewController ()

@end

@implementation BroadcastViewController
@synthesize picImage;
@synthesize msgList, lblBroadcastBody, lblBroadcastCaption, titleBar, contactNumber, totalCount, unreadCount, startLocation, progressBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self.view setFrame: [[UIScreen mainScreen] applicationFrame]];
    progressBar = [[BroadcastProgressView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 4) withDelegate:self];
    progressBar.totalBlocks = self.totalCount;
    progressBar.completedBlocks = self.unreadCount;
    progressBar.completedColor = [UIColor whiteColor];
    progressBar.remainingColor = [UIColor colorWithWhite:0.5f alpha:0.7f];
    [self didUpdateBroadcastIndex:(progressBar.completedBlocks == progressBar.totalBlocks ? 0 : progressBar.completedBlocks)];
    [self.view addSubview:progressBar];
    lblBroadcastCaption.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    
    // Iniciar la animación de progreso
    [progressBar startProgressAnimation];
    
    lblBroadcastBody.font = [self fontForText:lblBroadcastBody.text withMaxFontSize:24 inLabelSize:lblBroadcastBody.frame.size];
    [lblBroadcastBody setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.startLocation = [touch locationInView:self.view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint endLocation = [touch locationInView:self.view];
    
    // Detectar si es un tap (el toque no se ha movido mucho)
    CGFloat deltaX = endLocation.x - startLocation.x;
    
    if (deltaX > 100.0f) {
        if (progressBar.currentBlock < progressBar.totalBlocks - 1){
            [progressBar.progressTimer invalidate];
            [progressBar.progressCompletition invalidate];
            progressBar.progressTimer = nil;
            progressBar.progressCompletition = nil;
            progressBar.completedBlocks++;
            [progressBar setNeedsDisplay];
            [progressBar startProgressAnimation];
            [self didUpdateBroadcastIndex:progressBar.currentBlock];
        }
    } else if (deltaX < -100.0f) {
        if (progressBar.currentBlock > 0){
            [progressBar.progressTimer invalidate];
            [progressBar.progressCompletition invalidate];
            progressBar.progressTimer = nil;
            progressBar.progressCompletition = nil;
            progressBar.completedBlocks--;
            [progressBar setNeedsDisplay];
            [progressBar startProgressAnimation];
            [self didUpdateBroadcastIndex:progressBar.currentBlock];
        }
    }
}

- (UIFont *)fontForText:(NSString *)text withMaxFontSize:(CGFloat)maxFontSize inLabelSize:(CGSize)labelSize {
    UIFont *font = [UIFont systemFontOfSize:maxFontSize];
    CGSize textSize = [text sizeWithFont:font constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    while ((textSize.width > labelSize.width || textSize.height > labelSize.height) && font.pointSize > 0) {
        font = [UIFont systemFontOfSize:font.pointSize - 1];
        textSize = [text sizeWithFont:font constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return font;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (IBAction)closeModal:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didUpdateBroadcastIndex:(NSInteger)newIndex
{
    if (newIndex == self.totalCount){
        [self dismissModalViewControllerAnimated:YES];
    } else {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 208, 44)];
         titleView.backgroundColor = [UIColor clearColor];
         
         UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 208, 24)];
         nameLabel.text = self.title;
         nameLabel.font = [UIFont boldSystemFontOfSize:19];
         nameLabel.textAlignment = UITextAlignmentCenter;
         nameLabel.textColor = [UIColor whiteColor];
         nameLabel.backgroundColor = [UIColor clearColor];
         nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Color de la sombra
         nameLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
         // Configura la fuente y el tamaño del texto según sea necesario
         
         UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 208, 20)];
        NSInteger timestamp = [[[self.msgList objectAtIndex:newIndex] objectForKey:@"timestamp"] intValue];
        statusLabel.text = [CocoaFetch formattedDateHourFromTimestamp:(NSTimeInterval)timestamp];
         statusLabel.textAlignment = UITextAlignmentCenter;
         statusLabel.font = [UIFont systemFontOfSize:13];
         statusLabel.textColor = [UIColor whiteColor];
         statusLabel.backgroundColor = [UIColor clearColor];
         statusLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Color de la sombra
         statusLabel.shadowOffset = CGSizeMake(0, -1); // Desplazamiento de la sombra
         
         
         [titleView addSubview:nameLabel];
         [titleView addSubview:statusLabel];
         
         self.titleBar.titleView = titleView;
        NSString *msgType = [[self.msgList objectAtIndex:newIndex] objectForKey:@"type"];
        
        if ([msgType isEqualToString:@"chat"]){
            self.picImage.hidden = YES;
            self.lblBroadcastBody.hidden = NO;
            self.lblBroadcastCaption.hidden = YES;
            NSString *hexString = [NSString stringWithFormat:@"#%lX", (long)[[[[self.msgList objectAtIndex:newIndex] objectForKey:@"_data"] objectForKey:@"backgroundColor"] intValue]];
            self.view.backgroundColor = [CocoaFetch colorFromHexString:[hexString substringFromIndex:2]];
            self.lblBroadcastBody.text = [[self.msgList objectAtIndex:newIndex] objectForKey:@"body"];
        }
        if ([msgType isEqualToString:@"image"]){
            NSString *captionText = [[self.msgList objectAtIndex:newIndex] objectForKey:@"body"];
            self.picImage.hidden = NO;
            self.lblBroadcastBody.hidden = YES;
            self.lblBroadcastCaption.hidden = ([captionText length] == 0);
            self.view.backgroundColor = [UIColor blackColor];
            self.lblBroadcastCaption.text = captionText;
            [self downloadImageFromURL:[[[self.msgList objectAtIndex:newIndex] objectForKey:@"id"] objectForKey:@"_serialized"]];
        }
        if ([msgType isEqualToString:@"video"]){
            NSString *captionText = [[self.msgList objectAtIndex:newIndex] objectForKey:@"body"];
            self.picImage.hidden = YES;
            self.lblBroadcastBody.hidden = YES;
            self.lblBroadcastCaption.hidden = ([captionText length] == 0);
            self.view.backgroundColor = [UIColor blackColor];
            self.lblBroadcastCaption.text = captionText;
        }
    }
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
        [self.picImage setImage:[UIImage imageWithData:oimageData]];
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
            [self.picImage setImage:profImg];
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
        [self.picImage setImage:[UIImage imageWithData:oimageData]];
    }
}

- (void)dealloc {
    [titleBar release];
    [lblBroadcastBody release];
    [lblBroadcastCaption release];
    [picImage release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleBar:nil];
    [self setLblBroadcastBody:nil];
    [self setLblBroadcastCaption:nil];
    [self setPicImage:nil];
    [super viewDidUnload];
}
@end
