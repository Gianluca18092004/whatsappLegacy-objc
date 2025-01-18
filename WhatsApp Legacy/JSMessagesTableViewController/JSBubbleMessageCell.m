//
//  JSBubbleMessageCell.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "CocoaFetch.h"
#import "JSBubbleMessageCell.h"
#import "UIColor+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "UnknownMessage.h"
#import "JSBubbleReply.h"
#import "AppDelegate.h"
#import "WhatsAppAPI.h"

#define TIMESTAMP_LABEL_HEIGHT 42.0f
#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)

@interface JSBubbleMessageCell()

@property (retain, nonatomic) oJSBubbleTimestamp *bubbleTimestamp;
@property (retain, nonatomic) JSBubbleView *bubbleView;
@property (retain, nonatomic) JSBubbleReply *replyView;
@property (retain, nonatomic) UIImageView *avatarImageView;
@property (assign, nonatomic) JSAvatarStyle avatarImageStyle;
@property (retain, nonatomic) NSTimer *longPressTimer;
@property (assign, nonatomic) BOOL longPressDetected;

- (void)setup;

- (void)configureWithType:(JSBubbleMessageType)type
                    msgId:(NSString *)msgId
              avatarStyle:(JSAvatarStyle)avatarStyle
                timestamp:(BOOL)hasTimestamp
                 showUser:(BOOL)showUser
                 hasReply:(BOOL)hasReply
                 hasMedia:(BOOL)hasMedia
                mediaView:(UIView *)mediaView;

- (void)handleMenuWillHideNotification:(NSNotification *)notification;
- (void)handleMenuWillShowNotification:(NSNotification *)notification;
@property (assign, nonatomic) BOOL mhasTimestamp;


@end



@implementation JSBubbleMessageCell
@synthesize avatarImageView, avatarImageStyle, bubbleView, replyView, bubbleTimestamp, mhasTimestamp, longPressDetected, longPressTimer;

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
}

- (void)configureWithType:(JSBubbleMessageType)type
                    msgId:(NSString *)msgId
              avatarStyle:(JSAvatarStyle)avatarStyle
                timestamp:(BOOL)hasTimestamp
                 showUser:(BOOL)showUser
                 hasReply:(BOOL)hasReply
                 hasMedia:(BOOL)hasMedia
                mediaView:(UIView *)mediaView
{
    CGFloat bubbleY = 0.0f;
    CGFloat bubbleX = 0.0f;
    
    if(hasTimestamp) {
        self.mhasTimestamp = true;
        //[self configureTimestampLabel];
        bubbleY = TIMESTAMP_LABEL_HEIGHT;
    }
    
    CGFloat offsetX = 0.0f;
    
    if(avatarStyle != JSAvatarStyleNone) {
        offsetX = 4.0f;
        bubbleX = kJSAvatarSize;
        CGFloat avatarX = 0.5f;
        
        if(type == JSBubbleMessageTypeOutgoing) {
            avatarX = (self.contentView.frame.size.width - kJSAvatarSize);
            offsetX = kJSAvatarSize - 4.0f;
        }
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarX,
                                                                             self.contentView.frame.size.height - kJSAvatarSize,
                                                                             kJSAvatarSize,
                                                                             kJSAvatarSize)];
        
        self.avatarImageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                                 | UIViewAutoresizingFlexibleLeftMargin
                                                 | UIViewAutoresizingFlexibleRightMargin);
        [self.contentView addSubview:self.avatarImageView];
    }
    
    CGRect frame = CGRectMake(bubbleX - offsetX,
                              bubbleY,
                              self.contentView.frame.size.width - bubbleX,
                              self.contentView.frame.size.height);
    CGRect frameTS = CGRectMake(0.0f,
                              0.0f,
                              self.contentView.frame.size.width,
                              self.contentView.frame.size.height);
    
    self.bubbleView = [[JSBubbleView alloc] msgId:msgId showUser:showUser withFrame:frame
                                        bubbleType:type hasReply:hasReply hasMedia:hasMedia mediaView:mediaView];
    //self.bubbleView.userShow = ((type != JSBubbleMessageTypeOutgoing));
    
    [self.contentView addSubview:self.bubbleView];
    [self.contentView sendSubviewToBack:self.bubbleView];
    
    if(hasTimestamp) {
        self.bubbleTimestamp = [[oJSBubbleTimestamp alloc] withFrame:frameTS];
        [self.contentView addSubview:self.bubbleTimestamp];
        [self.contentView sendSubviewToBack:self.bubbleTimestamp];
    }
    
    if(hasReply) {
        self.replyView = [[JSBubbleReply alloc] showUser:showUser withFrame:frame bubbleType:type];
        [self.contentView addSubview:self.replyView];
    }
}

#pragma mark - Initialization
- (id)initWithBubbleType:(JSBubbleMessageType)type
                   msgId:(NSString *)msgId
             avatarStyle:(JSAvatarStyle)avatarStyle
            hasTimestamp:(BOOL)hasTimestamp
                showUser:(BOOL)showUser
                hasReply:(BOOL)hasReply
                hasMedia:(BOOL)hasMedia
               mediaView:(UIView *)mediaView
         reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setup];
        self.avatarImageStyle = avatarStyle;
        [self configureWithType:type
                          msgId:msgId
                    avatarStyle:avatarStyle
                      timestamp:hasTimestamp
                       showUser:showUser
                       hasReply:hasReply
                       hasMedia:hasMedia
                      mediaView:mediaView];
    }
    return self;
}

- (void)dealloc
{
    self.bubbleView = nil;
    self.bubbleTimestamp = nil;
    self.avatarImageView = nil;
    self.longPressTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - Setters
- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
    [self.bubbleView setBackgroundColor:color];
}

#pragma mark - Message Cell
- (void)setMessage:(NSString *)msg
{
    self.bubbleView.text = msg;
    self.replyView.parentText = msg;
}

- (void)setQuotedMessage:(NSString *)msg
{
    self.bubbleView.quotedText = msg;
    self.replyView.text = msg;
}

- (void)setQuotedUser:(NSString *)user
{
    self.replyView.userName = user;
}

- (void)setTimestamp:(NSDate *)date
{
    self.bubbleView.timestamp = date;
    self.bubbleTimestamp.timestamp = date;
    if(self.mhasTimestamp){
        /*self.timestampLabel.text = [NSDateFormatter localizedStringFromDate:date
                                                                  dateStyle:NSDateFormatterLongStyle
                                                                  timeStyle:NSDateFormatterNoStyle];*/
    }
}

- (void)setHasMedia:(BOOL)hasMedia {
    self.bubbleView.hasMedia = hasMedia;
}

- (void)setAck:(NSInteger *)ack
{
    self.bubbleView.ack = (int)ack;
}

- (void)setUserWrited:(NSString *)user
{
    self.bubbleView.userName = user;
}

- (void)setAvatarImage:(UIImage *)image
{
    UIImage *styledImg = nil;
    switch (self.avatarImageStyle) {
        case JSAvatarStyleCircle:
            styledImg = [image circleImageWithSize:kJSAvatarSize];
            break;
            
        case JSAvatarStyleSquare:
            styledImg = [image squareImageWithSize:kJSAvatarSize];
            break;
            
        case JSAvatarStyleNone:
        default:
            break;
    }
    
    self.avatarImageView.image = styledImg;
}

- (void)setIsAudioNextMessage:(BOOL)isAudio
{
    
}

+ (CGFloat)neededHeightForText:(NSString *)bubbleViewText timestamp:(BOOL)hasTimestamp avatar:(BOOL)hasAvatar userName:(BOOL)showUserName media:(BOOL)hasMedia mediaHeight:(CGFloat)oMediaHeight quotedText:(NSString *)quotedText
{
    CGFloat timestampHeight = (hasTimestamp) ? TIMESTAMP_LABEL_HEIGHT : 0.0f;
    CGFloat avatarHeight = (hasAvatar) ? kJSAvatarSize : 0.0f;
    CGFloat userNameHeight = (showUserName) ? kJSUserNameSize : 0.0f;
    CGFloat mediaHeight = (hasMedia) ? oMediaHeight : 0.0f;
    return MAX(avatarHeight, [JSBubbleView cellHeightForText:bubbleViewText andQuotedText:quotedText] + userNameHeight + mediaHeight) + timestampHeight;
}

#pragma mark - Copying
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (void)replyMessage:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.chatViewController.attachToolBarView.bubbleReply.text = self.bubbleView.text;
    appDelegate.chatViewController.attachToolBarView.bubbleReply.msgId = self.bubbleView.msgId;
    if (self.bubbleView.userName.length > 0){
        appDelegate.chatViewController.attachToolBarView.bubbleReply.userName = self.bubbleView.userName;
    } else {
        if (self.bubbleView.type == JSBubbleMessageTypeOutgoing){
            appDelegate.chatViewController.attachToolBarView.bubbleReply.userName = WSPContactType_toString[YOUUSER];
        } else {
            appDelegate.chatViewController.attachToolBarView.bubbleReply.userName = appDelegate.chatViewController.title;
        }
    }
    appDelegate.chatViewController.attachToolBarView.hidden = NO;
}

- (void)forwardMessage:(id)sender {
    NSLog(@"Mensaje reenviado");
    // Aquí puedes agregar la lógica para reenviar el mensaje
}

- (void)reportMessage:(id)sender {
    NSLog(@"Mensaje reportado");
    // Aquí puedes agregar la lógica para reenviar el mensaje
}

- (void)deleteMessage:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Message"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete for me", @"Delete for everyone", nil];
    alert.tag = (NSInteger)@"deleteMessage";
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == (NSInteger)@"deleteMessage" && buttonIndex != [alertView cancelButtonIndex]){
        [WhatsAppAPI deleteMessageFromId:self.bubbleView.msgId everyone:buttonIndex];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(copy:) || action == @selector(forwardMessage:) || action == @selector(deleteMessage:) || action == @selector(forwardMessage:) || action == @selector(replyMessage:))
        return YES;
    if (action == @selector(forwardMessage:) || action == @selector(deleteMessage:) || action == @selector(forwardMessage:) || action == @selector(replyMessage:)) {
        return YES;  // Habilita las opciones Forward y Delete
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.bubbleView.text];
    [self resignFirstResponder];
}

#pragma mark - Touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.bubbleView.selectedToShowCopyMenu = NO;
    
    // Simular un toque prolongado con un temporizador
    longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                      target:self
                                                    selector:@selector(handleLongPress:)
                                                    userInfo:nil
                                                     repeats:NO];
    
    longPressDetected = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!longPressDetected) {
        [longPressTimer invalidate];
        longPressTimer = nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [longPressTimer invalidate];
    longPressTimer = nil;
}

- (void)handleLongPress:(NSTimer *)timer {
    longPressDetected = YES;
    
    [self performSelector:@selector(showCopyMenuAtLocation)];
    
    [longPressTimer invalidate];
    longPressTimer = nil;
}

- (void)showCopyMenuAtLocation {
    if (![self becomeFirstResponder])
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
    
    if (IS_IOS4orHIGHER){
        // Configurar el UIMenuController
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        // Crear ítems personalizados
        UIMenuItem *replyItem = [[UIMenuItem alloc] initWithTitle:@"Reply" action:@selector(replyMessage:)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forwardMessage:)];
        UIMenuItem *reportItem = [[UIMenuItem alloc] initWithTitle:@"Report" action:@selector(reportMessage:)];
        
        // Asignar los ítems personalizados al menu
        if (self.bubbleView.type == JSBubbleMessageTypeOutgoing) {
            [menu setMenuItems:[NSArray arrayWithObjects:replyItem, forwardItem, deleteItem, reportItem, nil]];
        } else {
            [menu setMenuItems:[NSArray arrayWithObjects:replyItem, forwardItem, reportItem, nil]];
        }
        
        // Posicionar el menu
        CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
                                     fromView:self.bubbleView];
        [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
        
        // Mostrar el menu
        [menu setMenuVisible:YES animated:YES];
    }
    
    // Marcar la vista de burbuja como seleccionada para mostrar el menú
    self.bubbleView.selectedToShowCopyMenu = YES;
}

#pragma mark - Notification
- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
    self.bubbleView.selectedToShowCopyMenu = NO;
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
    
    self.bubbleView.selectedToShowCopyMenu = YES;
    self.bubbleView.backgroundColor = [UIColor redColor];
}

@end