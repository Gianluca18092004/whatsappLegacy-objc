//
//  ChatViewController.h
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
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
#import "JSONFetcher.h"

@interface ChatViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource, UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, JSONFetcherDelegate>

@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (retain, nonatomic) NSMutableArray* chatMessages;
@property (retain, nonatomic) IBOutlet UIButton *profileButton;
@property (retain, nonatomic) UIImage *smallImage;
@property (retain, nonatomic) UIImage *largeImage;
@property (retain, nonatomic) UIView *titleView;
@property (retain, nonatomic) UILabel *statusLabel;
@property (retain, nonatomic) UILabel *nameLabel;
@property (copy, nonatomic) NSString *contactNumber;
@property (assign, nonatomic) NSInteger timestamp;

@property NSInteger levelNav;

- (void)loadStatusText:(BOOL)fromContact withDic:(NSDictionary *)dic andStatus:(NSString *)statusText;
- (void)reloadChat;
- (void)profileButtonTapped;
- (void)freeResourcesForNonVisibleCells;

@end
