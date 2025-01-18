//
//  CocoaFetch.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaFetch : NSObject

+ (NSDictionary *) fetchJSON:(NSString *)urlString withMethod:(NSString *)method;
+ (BOOL)isDifferentDayWithTimestamp:(NSTimeInterval)timestamp previousTimestamp:(NSTimeInterval)previousTimestamp;
+ (NSString *) formattedDateFromTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)formattedDateHourFromTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)stringWithDate:(NSDate *)date;
+ (NSString *)stringWithTime:(NSDate *)date;
+ (NSInteger)singleDigitFromString:(NSString*)inputString;
+ (void)saveDictionaryToJSON:(NSDictionary *)dictionary withFileName:(NSString *)fileName;
+ (void)deleteJSONWithFileName:(NSString *)fileName;
+ (NSDictionary *)loadDictionaryFromJSONWithFileName:(NSString *)fileName;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString *)formattedTimeFromSeconds:(int)totalSeconds;
+ (CGSize)resizeToWidth:(CGFloat)targetWidth fromSize:(CGSize)originalSize;
+ (NSString *)stringFromByteCount:(NSInteger)byteCount;
+ (NSString *)contentTypeForImageData:(NSData *)data;
+ (BOOL)connectedToServers;
@end
