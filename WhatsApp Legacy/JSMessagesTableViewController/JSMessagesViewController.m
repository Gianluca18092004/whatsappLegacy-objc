//
//  JSMessagesViewController.m
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

#import "JSMessagesViewController.h"
#import "NSString+JSMessagesView.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "UIColor+JSMessagesView.h"
#import "JSDismissiveTextView.h"
#import "VoiceNoteAPI.h"
#import "CocoaFetch.h"
#import "AppDelegate.h"
#import "WhatsAppAPI.h"

#define INPUT_HEIGHT 40.0f
#define ATTACH_HEIGHT 80.0f
#define IS_IOS32orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)
@interface JSMessagesViewController () <JSDismissiveTextViewDelegate>

- (void)setup;

@end



@implementation JSMessagesViewController
@synthesize delegate, dataSource, isGroup, isReadOnly, inputToolBarView, attachToolBarView, tableView, chatContacts, previousTextViewContentHeight, keyboardIsShowing;

#pragma mark - Initialization
- (void)setup
{
    if([self.view isKindOfClass:[UIScrollView class]]) {
        // fix for ipad modal form presentations
        ((UIScrollView *)self.view).scrollEnabled = NO;
    }
    
    CGSize size = self.view.frame.size;
	
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, size.width, size.height - INPUT_HEIGHT);
	self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	
    [self setBackgroundColor:[UIColor messagesBackgroundColor]];
    
    CGRect inputFrame = CGRectMake(0.0f, size.height - INPUT_HEIGHT, size.width, INPUT_HEIGHT);
    CGRect attachFrame = CGRectMake(0.0f, inputFrame.origin.y - ATTACH_HEIGHT, size.width, ATTACH_HEIGHT);
    self.inputToolBarView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
    self.attachToolBarView = [[JSMessageAttachView alloc] initWithFrame:attachFrame delegate:self];
    self.attachToolBarView.hidden = YES;
    [self.attachToolBarView.closeAttachView addTarget:self
                             action:@selector(closeAttachPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    // TODO: refactor
    self.inputToolBarView.textView.delegate = self;
    
    UIButton *sendButton = [self sendButton];
    sendButton.hidden = YES;
    sendButton.frame = CGRectMake(self.inputToolBarView.frame.size.width - 65.0f, 8.0f, 59.0f, 26.0f);
    [sendButton addTarget:self
                   action:@selector(sendPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.inputToolBarView setSendButton:sendButton];
    
    UIButton *attachButton = [self attachButton];
    attachButton.frame = CGRectMake(2.0f, 0.0f, 33.0f, 40.0f);
    [attachButton addTarget:self
                     action:@selector(attachPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.inputToolBarView setAttachButton:attachButton];
    
    UIButton *voiceNoteButton = [self voiceNoteButton];
    voiceNoteButton.hidden = NO;
    voiceNoteButton.frame = CGRectMake(self.inputToolBarView.frame.size.width - 65.0f, 8.0f, 59.0f, 26.0f);
    [voiceNoteButton addTarget:self
                        action:@selector(voiceNoteDown:)
              forControlEvents:UIControlEventTouchDown];
    [voiceNoteButton addTarget:self
                        action:@selector(voiceNoteUpIn:)
              forControlEvents:UIControlEventTouchUpInside];
    [voiceNoteButton addTarget:self
                        action:@selector(voiceNoteUpOut:)
              forControlEvents:UIControlEventTouchUpOutside];
    [self.inputToolBarView setVoiceNoteButton:voiceNoteButton];
    [self.view addSubview:self.inputToolBarView];
    [self.view addSubview:self.attachToolBarView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(![self.inputToolBarView.textView resignFirstResponder])
    {
        [self.inputToolBarView.textView resignFirstResponder];
        [self.delegate voiceNoteClear];
    }
    [super touchesBegan:touches withEvent:event];
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (UIButton *)attachButton
{
    return [UIButton defaultAttachButton];
}

- (UIButton *)voiceNoteButton
{
    return [UIButton defaultVoiceNoteButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self scrollToBottomAnimated:NO];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboard:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboard:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.inputToolBarView resignFirstResponder];
    [self.delegate voiceNoteClear];
    [self setEditing:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"*** %@: didReceiveMemoryWarning ***", self.class);
}

#pragma mark - View rotation
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
}

#pragma mark - Actions
- (void)sendPressed:(UIButton *)sender
{
    [self.delegate sendPressed:sender
                      withText:[self.inputToolBarView.textView.text trimWhitespace]];
}

- (void)attachPressed:(UIButton*)sender
{
    [self.delegate attachPressed:sender];
}

- (void)voiceNoteDown:(UIButton *)sender
{
    [JSMessageSoundEffect playMessageVoiceNoteStartSound];
    self.inputToolBarView.timeLabel.text = @"0:00";
    double delayInSeconds = 0.4;
    [NSTimer scheduledTimerWithTimeInterval:delayInSeconds
                                     target:self
                                   selector:@selector(startRecordingAfterDelay)
                                   userInfo:nil
                                    repeats:NO];
    self.inputToolBarView.attachButton.hidden = YES;
    self.inputToolBarView.textView.hidden = true;
    self.inputToolBarView.inputFieldBack.hidden = true;
}

- (void)startRecordingAfterDelay {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(self.inputToolBarView.textView.hidden == true){
        self.inputToolBarView.redMic.hidden = NO;
        self.inputToolBarView.timeLabel.hidden = NO;
        self.inputToolBarView.slideLabel.hidden = NO;
        [appDelegate.voiceNoteManager startRecording];
        self.inputToolBarView.startTime = CFAbsoluteTimeGetCurrent();
        self.inputToolBarView.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 // Actualiza cada 100 ms
                                                                       target:self
                                                                     selector:@selector(updateTimer)
                                                                     userInfo:nil
                                                                      repeats:YES];
    }
}

- (void)voiceNoteUpIn:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.inputToolBarView.attachButton.hidden = false;
    self.inputToolBarView.textView.hidden = false;
    self.inputToolBarView.inputFieldBack.hidden = false;
    [self.inputToolBarView.timer invalidate];
    self.inputToolBarView.timer = nil;
    if([appDelegate.voiceNoteManager stopRecordingNormally:YES]){
        [self.delegate finishSendVoiceNote];
    }
    self.inputToolBarView.redMic.hidden = YES;
    self.inputToolBarView.timeLabel.hidden = YES;
    self.inputToolBarView.slideLabel.hidden = YES;
    [self.delegate voiceNoteClear];
}

- (void)voiceNoteUpOut:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationTransition:UIModalTransitionStylePartialCurl forView:self.inputToolBarView cache:NO];
    self.inputToolBarView.attachButton.hidden = false;
    self.inputToolBarView.textView.hidden = false;
    self.inputToolBarView.inputFieldBack.hidden = false;
    [self.inputToolBarView.timer invalidate];
    self.inputToolBarView.timer = nil;
    [appDelegate.voiceNoteManager stopRecordingNormally:NO];
    self.inputToolBarView.redMic.hidden = YES;
    self.inputToolBarView.timeLabel.hidden = YES;
    self.inputToolBarView.slideLabel.hidden = YES;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    [self.delegate voiceNoteClear];
}

- (void)updateTimer {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval elapsedTime = currentTime - self.inputToolBarView.startTime;
    
    int minutes = (int)(elapsedTime / 60.0);
    int seconds = (int)elapsedTime % 60;
    
    NSString *timeString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    self.inputToolBarView.timeLabel.text = timeString;
    [self.delegate voiceNoteStatus];
}

- (void)closeAttachPressed:(UIButton *)sender
{
    [self.attachToolBarView setHidden:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)oTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSBubbleMessageType type = [self.delegate messageTypeForRowAtIndexPath:indexPath];
    JSAvatarStyle avatarStyle = [self.delegate avatarStyleForRowAtIndexPath:indexPath];
    
    BOOL hasTimestamp = [self shouldHaveTimestampForRowAtIndexPath:indexPath];
    BOOL hasAvatar = [self shouldHaveAvatarForRowAtIndexPath:indexPath];
    BOOL showUser = [self shouldShowUserName:indexPath];
    BOOL hasReply = [self.delegate hasReplyForRowAtIndexPath:indexPath];
    
    NSString *CellID = [NSString stringWithFormat:@"MessageCell_%d_%d_%d", type, hasTimestamp, hasAvatar];
    JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[oTableView dequeueReusableCellWithIdentifier:CellID];
    
    if(!cell)
        sleep(0);
        cell = [[JSBubbleMessageCell alloc] initWithBubbleType:type
                                                         msgId:[self.dataSource msgIdForRowAtIndexPath:indexPath]
                                                   avatarStyle:(hasAvatar) ? avatarStyle : JSAvatarStyleNone
                                                  hasTimestamp:hasTimestamp
                                                      showUser:showUser
                                                       hasReply:hasReply
                                                      hasMedia:[self.delegate hasMediaForRowAtIndexPath:indexPath]
                                                     mediaView:([self.delegate hasMediaForRowAtIndexPath:indexPath] == YES ? [self.dataSource mediaViewForRowAtIndexPath:indexPath] : nil)
                                               reuseIdentifier:CellID
                ];
    
    if(hasTimestamp) {}
    [cell setTimestamp:[self.dataSource timestampForRowAtIndexPath:indexPath]];
    
    if(hasAvatar) {
        switch (type) {
            case JSBubbleMessageTypeIncoming:
                [cell setAvatarImage:[self.dataSource avatarImageForIncomingMessageForRowAtIndexPath:indexPath]];
                break;
                
            case JSBubbleMessageTypeOutgoing:
                [cell setAvatarImage:[self.dataSource avatarImageForOutgoingMessage]];
                break;
        }
    }
    
    if(hasReply) {
        [cell setQuotedMessage:[self.dataSource quotedTextForRowAtIndexPath:indexPath]];
        [cell setQuotedUser:[self.dataSource quotedUserNameForRowAtIndexPath:indexPath]];
    } else {
        [cell setQuotedMessage:@""];
    }
    
    if(type == JSBubbleMessageTypeOutgoing){
        [cell setAck:[self.dataSource ackForRowAtIndexPath:indexPath]];
    }
    
    [cell setUserWrited:[self.dataSource userNameForRowAtIndexPath:indexPath]];
    [cell setMessage:[self.dataSource textForRowAtIndexPath:indexPath]];
    [cell setBackgroundColor:self.tableView.backgroundColor];
    return cell;
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(![self.inputToolBarView.textView resignFirstResponder])
    {
        [self.inputToolBarView.textView resignFirstResponder];
        [self.delegate voiceNoteClear];
    }
    
    if(![self.inputToolBarView.hTextView resignFirstResponder])
    {
        [self.inputToolBarView.hTextView resignFirstResponder];
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSBubbleMessageCell neededHeightForText:[self.dataSource textForRowAtIndexPath:indexPath]
                                          timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]
                                             avatar:[self shouldHaveAvatarForRowAtIndexPath:indexPath]
                                           userName:[self shouldShowUserName:indexPath]
                                              media:[self shouldHasMedia:indexPath]
                                        mediaHeight:[self.dataSource mediaViewForRowAtIndexPath:indexPath].frame.size.height - ([self.dataSource mediaViewForRowAtIndexPath:indexPath].tag == (NSInteger)@"VoiceNoteMessage" ? 17.0f : 0.0f)
            quotedText:[self.dataSource quotedTextForRowAtIndexPath:indexPath]];
}

#pragma mark - Messages view controller
- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    switch ([self.delegate timestampPolicy]) {
        case JSMessagesViewTimestampPolicyAll:
            return YES;
            
        case JSMessagesViewTimestampPolicyAlternating:
            return indexPath.row % 2 == 0;
            
        case JSMessagesViewTimestampPolicyEveryThree:
            return indexPath.row % 3 == 0;
            
        case JSMessagesViewTimestampPolicyEveryFive:
            return indexPath.row % 5 == 0;
            
        case JSMessagesViewTimestampPolicyCustom:
            if([self.delegate respondsToSelector:@selector(hasTimestampForRowAtIndexPath:)]){
                return [self.delegate hasTimestampForRowAtIndexPath:indexPath];
            }
            
        default:
            return NO;
    }
}

- (BOOL)shouldHaveAvatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.delegate avatarPolicy]) {
        case JSMessagesViewAvatarPolicyIncomingOnly:
            return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming;
            
        case JSMessagesViewAvatarPolicyBoth:
            return YES;
            
        case JSMessagesViewAvatarPolicyNone:
        default:
            return NO;
    }
}

- (BOOL)shouldShowUserName:(NSIndexPath *)indexPath
{
    return [self.delegate showUserPolicyForRowAtIndexPath:indexPath];
}
            
- (BOOL)shouldHasMedia:(NSIndexPath*)indexPath
{
    return [self.delegate hasMediaForRowAtIndexPath:indexPath];
}

- (void)finishSend
{
    [self.inputToolBarView.textView setText:nil];
    [self textViewDidChange:self.inputToolBarView.textView];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"wallpaper_61.png"];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.clipsToBounds = YES;
    
    backgroundImageView.frame = self.tableView.bounds;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [backgroundView addSubview:backgroundImageView];
    
    if(IS_IOS32orHIGHER){
        self.tableView.backgroundView = backgroundView;
    } else {
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:backgroundView];
        [self.view sendSubviewToBack:backgroundView];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
	
    if(!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollToBottomAnimated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    [self.delegate voiceNoteClear];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];
    CGFloat textViewContentHeight = textView.contentSize.height;
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    if(changeInHeight == 6.0f){
        changeInHeight = 0.0f;
    }
    if(changeInHeight == -6.0f){
        changeInHeight = 0.0f;
    }
    if(changeInHeight == 26.0f){
        changeInHeight = 20.0f;
    }
    if(changeInHeight == -26.0f){
        changeInHeight = -20.0f;
    }
    if(changeInHeight != 0.0f) {
        if(!isShrinking)
            [self.inputToolBarView adjustTextViewHeightBy:changeInHeight];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        
        // Animación
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.tableView.contentInset.bottom + changeInHeight, 0.0f);
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
        [self scrollToBottomAnimated:NO];
        
        // Ajustar el frame de la barra de herramientas de entrada
        CGRect inputViewFrame = self.inputToolBarView.frame;
        self.inputToolBarView.frame = CGRectMake(0.0f,
                                                 inputViewFrame.origin.y - changeInHeight,
                                                 inputViewFrame.size.width,
                                                 inputViewFrame.size.height + changeInHeight);
        
        // Finalización de la animación
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
        [UIView commitAnimations];
        
        if (isShrinking) {
            [self.inputToolBarView adjustTextViewHeightBy:changeInHeight];
        }
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
    
    self.inputToolBarView.sendButton.hidden = ([textView.text trimWhitespace].length == 0);
    self.inputToolBarView.voiceNoteButton.hidden = ([textView.text trimWhitespace].length > 0);
}

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    keyboardIsShowing = true;
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    keyboardIsShowing = false;
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    // Obtener el rectángulo del teclado
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Comenzar las animaciones
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    
    // Obtener la posición del teclado
    CGFloat keyboardY = self.view.frame.size.height - (keyboardIsShowing ? keyboardRect.size.height : 0);
    
    CGRect inputViewFrame = self.inputToolBarView.frame;
    CGRect attachViewFrame = self.attachToolBarView.frame;
    CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
    CGFloat attachViewFrameY = inputViewFrameY - attachViewFrame.size.height;
    
    // Ajuste para presentaciones modales en iPad (si es necesario)
    CGFloat messageViewFrameBottom = self.view.frame.size.height - INPUT_HEIGHT;
    if (inputViewFrameY > messageViewFrameBottom) {
        inputViewFrameY = messageViewFrameBottom;
    }
    
    // Ajustar el frame de la barra de herramientas de entrada
    self.inputToolBarView.frame = CGRectMake(inputViewFrame.origin.x,
                                             inputViewFrameY,
                                             inputViewFrame.size.width,
                                             inputViewFrame.size.height);
    self.attachToolBarView.frame = CGRectMake(attachViewFrame.origin.x,
                                              attachViewFrameY,
                                              attachViewFrame.size.width,
                                              attachViewFrame.size.height);
    
    // Ajustar los insets del tableView
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.view.frame.size.height - (self.attachToolBarView.hidden == YES ? self.inputToolBarView.frame.origin.y : self.attachToolBarView.frame.origin.y) - INPUT_HEIGHT, 0.0f);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    // Terminar las animaciones
    [UIView commitAnimations];
}


#pragma mark - Dismissive text view delegate
- (void)keyboardDidScrollToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = self.inputToolBarView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.inputToolBarView.frame = inputViewFrame;
}

- (void)keyboardWillBeDismissed
{
    CGRect inputViewFrame = self.inputToolBarView.frame;
    inputViewFrame.origin.y = self.view.bounds.size.height - inputViewFrame.size.height;
    self.inputToolBarView.frame = inputViewFrame;
}

- (void)keyboardWillSnapBackToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = self.inputToolBarView.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    self.inputToolBarView.frame = inputViewFrame;
}

@end