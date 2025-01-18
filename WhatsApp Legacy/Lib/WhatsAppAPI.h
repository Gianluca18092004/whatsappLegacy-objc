//
//  WhatsAppAPI.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhatsAppAPI : NSObject

+ (NSDictionary *)getChatList;
+ (NSDictionary *)getContactList;
+ (void)getChatListAsync;
+ (void)getContactListAsync;
+ (void)getBroadcastListAsync;
+ (void)downloadAndProcessImage:(NSString *)contactNumber andIsGroup:(BOOL)isGroup;
+ (NSDictionary *)getContactInfo:(NSString *)contactNumber;
+ (NSDictionary *)getChatInfo:(NSString *)contactNumber;
+ (void)fetchMessagesfromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup light:(BOOL)light;
+ (void)fetchMessagesfromNumberAsync:(NSString *)contactNumber isGroup:(BOOL)isGroup light:(BOOL)light;
+ (void)setTypingStatusfromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup isVoiceNote:(BOOL)isVoiceNote;
+ (void)clearStatefromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup;
+ (void)sendMessageFromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup bodyMsg:(NSDictionary *)bodyMsg;
+ (void)setStatusMsg:(NSString *)statusMsg;
+ (void)setMutefromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup muteState:(NSInteger)muteState;
+ (void)setBlockfromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup;
+ (void)sendSeenfromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup;
+ (void)deleteMessageFromId:(NSString *)messageId everyone:(int)everyone;
+ (void)sendSeenfromBroadcast:(NSString *)message;
+ (void)deleteChatfromNumber:(NSString *)contactNumber isGroup:(BOOL)isGroup;
+ (void)leaveGroupfromNumber:(NSString *)contactNumber;
+ (NSDictionary *)getMessagesfromNumber:(NSString *)contactNumber;
+ (NSDictionary *)getMyContact;
+ (NSDictionary *)getGroupInfo:(NSString *)groupNumber;

typedef enum WSPContactType {
    REGULARUSER = 0,
    BUSINESSUSER,
    ENTERPRISEUSER,
    YOUUSER
} WSPContactType;
extern NSString * const WSPContactType_toString[];

typedef enum WSPInfoType {
    DEFAULT = 0,
    AVAILABLE,
    BUSY,
    INSCHOOL,
    INCINEMA,
    INWORK,
    INGYM,
    INREUNION,
    LOWBATTERY,
    ONLYWSP,
    ONLYEMERGENCY,
    SLEEPING
} WSPInfoType;
extern NSString * const WSPInfoType_toString[];

typedef enum WSPMsgMediaType {
    STICKER,
    PICTURE,
    VIDEO,
    PTT,
    AUDIO,
    REVOKED,
    LOCATION,
    UNKNOWN
} WSPMsgMediaType;
extern NSString * const WSPMsgMediaType_toString[];

@end
