//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/OWSArchivedPaymentMessage.h>
#import <SignalServiceKit/TSIncomingMessage.h>
#import <SignalServiceKit/TSPaymentModels.h>

NS_ASSUME_NONNULL_BEGIN

@class TSArchivedPaymentInfo;

@interface OWSIncomingArchivedPaymentMessage : TSIncomingMessage <OWSArchivedPaymentMessage>

@property (nonatomic, readonly) TSArchivedPaymentInfo *archivedPaymentInfo;

- (instancetype)initIncomingMessageWithBuilder:(TSIncomingMessageBuilder *)messageBuilder
                                        amount:(nullable NSString *)amount
                                           fee:(nullable NSString *)fee
                                          note:(nullable NSString *)note NS_DESIGNATED_INITIALIZER;

- (instancetype)initIncomingMessageWithBuilder:(TSIncomingMessageBuilder *)messageBuilder NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)initWithGrdbId:(int64_t)grdbId
                          uniqueId:(NSString *)uniqueId
               receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                            sortId:(uint64_t)sortId
                         timestamp:(uint64_t)timestamp
                    uniqueThreadId:(NSString *)uniqueThreadId
                     attachmentIds:(NSArray<NSString *> *)attachmentIds
                              body:(nullable NSString *)body
                        bodyRanges:(nullable MessageBodyRanges *)bodyRanges
                      contactShare:(nullable OWSContact *)contactShare
                         editState:(TSEditState)editState
                   expireStartedAt:(uint64_t)expireStartedAt
                expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                         expiresAt:(uint64_t)expiresAt
                  expiresInSeconds:(unsigned int)expiresInSeconds
                         giftBadge:(nullable OWSGiftBadge *)giftBadge
                 isGroupStoryReply:(BOOL)isGroupStoryReply
    isSmsMessageRestoredFromBackup:(BOOL)isSmsMessageRestoredFromBackup
                isViewOnceComplete:(BOOL)isViewOnceComplete
                 isViewOnceMessage:(BOOL)isViewOnceMessage
                       linkPreview:(nullable OWSLinkPreview *)linkPreview
                    messageSticker:(nullable MessageSticker *)messageSticker
                     quotedMessage:(nullable TSQuotedMessage *)quotedMessage
      storedShouldStartExpireTimer:(BOOL)storedShouldStartExpireTimer
             storyAuthorUuidString:(nullable NSString *)storyAuthorUuidString
                storyReactionEmoji:(nullable NSString *)storyReactionEmoji
                    storyTimestamp:(nullable NSNumber *)storyTimestamp
                wasRemotelyDeleted:(BOOL)wasRemotelyDeleted
                 authorPhoneNumber:(nullable NSString *)authorPhoneNumber
                        authorUUID:(nullable NSString *)authorUUID
         deprecated_sourceDeviceId:(unsigned int)deprecated_sourceDeviceId
                              read:(BOOL)read
           serverDeliveryTimestamp:(uint64_t)serverDeliveryTimestamp
                        serverGuid:(nullable NSString *)serverGuid
                   serverTimestamp:(nullable NSNumber *)serverTimestamp
                            viewed:(BOOL)viewed
                   wasReceivedByUD:(BOOL)wasReceivedByUD NS_UNAVAILABLE;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                   attachmentIds:(NSArray<NSString *> *)attachmentIds
                            body:(nullable NSString *)body
                      bodyRanges:(nullable MessageBodyRanges *)bodyRanges
                    contactShare:(nullable OWSContact *)contactShare
                       editState:(TSEditState)editState
                 expireStartedAt:(uint64_t)expireStartedAt
              expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                       expiresAt:(uint64_t)expiresAt
                expiresInSeconds:(unsigned int)expiresInSeconds
                       giftBadge:(nullable OWSGiftBadge *)giftBadge
               isGroupStoryReply:(BOOL)isGroupStoryReply
  isSmsMessageRestoredFromBackup:(BOOL)isSmsMessageRestoredFromBackup
              isViewOnceComplete:(BOOL)isViewOnceComplete
               isViewOnceMessage:(BOOL)isViewOnceMessage
                     linkPreview:(nullable OWSLinkPreview *)linkPreview
                  messageSticker:(nullable MessageSticker *)messageSticker
                   quotedMessage:(nullable TSQuotedMessage *)quotedMessage
    storedShouldStartExpireTimer:(BOOL)storedShouldStartExpireTimer
           storyAuthorUuidString:(nullable NSString *)storyAuthorUuidString
              storyReactionEmoji:(nullable NSString *)storyReactionEmoji
                  storyTimestamp:(nullable NSNumber *)storyTimestamp
              wasRemotelyDeleted:(BOOL)wasRemotelyDeleted
               authorPhoneNumber:(nullable NSString *)authorPhoneNumber
                      authorUUID:(nullable NSString *)authorUUID
       deprecated_sourceDeviceId:(unsigned int)deprecated_sourceDeviceId
                            read:(BOOL)read
         serverDeliveryTimestamp:(uint64_t)serverDeliveryTimestamp
                      serverGuid:(nullable NSString *)serverGuid
                 serverTimestamp:(nullable NSNumber *)serverTimestamp
                          viewed:(BOOL)viewed
                 wasReceivedByUD:(BOOL)wasReceivedByUD
             archivedPaymentInfo:(TSArchivedPaymentInfo *)archivedPaymentInfo
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:receivedAtTimestamp:sortId:timestamp:uniqueThreadId:attachmentIds:body:bodyRanges:contactShare:editState:expireStartedAt:expireTimerVersion:expiresAt:expiresInSeconds:giftBadge:isGroupStoryReply:isSmsMessageRestoredFromBackup:isViewOnceComplete:isViewOnceMessage:linkPreview:messageSticker:quotedMessage:storedShouldStartExpireTimer:storyAuthorUuidString:storyReactionEmoji:storyTimestamp:wasRemotelyDeleted:authorPhoneNumber:authorUUID:deprecated_sourceDeviceId:read:serverDeliveryTimestamp:serverGuid:serverTimestamp:viewed:wasReceivedByUD:archivedPaymentInfo:));

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END
