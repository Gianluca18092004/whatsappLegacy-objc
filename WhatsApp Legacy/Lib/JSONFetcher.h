//
//  JSONFetcher.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 15/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONFetcherDelegate <NSObject>
- (void)fetcherDidFinishWithJSON:(NSDictionary *)json error:(NSError *)error;
@end

@interface JSONFetcher : NSObject
@property (nonatomic, assign) id<JSONFetcherDelegate> delegate;

+ (void)fetchJSON:(NSString *)urlString withMethod:(NSString *)method delegate:(id<JSONFetcherDelegate>)delegate;
+ (void)fetchJSON:(NSString *)urlString withMethod:(NSString *)method jsonBody:(NSDictionary *)jsonBody delegate:(id<JSONFetcherDelegate>)delegate;

@end
