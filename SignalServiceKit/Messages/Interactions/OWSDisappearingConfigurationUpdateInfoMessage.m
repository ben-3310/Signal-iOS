//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSDisappearingConfigurationUpdateInfoMessage.h"
#import "OWSDisappearingMessagesConfiguration.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSDisappearingConfigurationUpdateInfoMessage ()

@property (nonatomic, readonly, nullable) NSString *createdByRemoteName;
@property (nonatomic, readonly) uint32_t configurationDurationSeconds;

/// This property is set for legacy messages, but always set to `false` for new
/// messages.
@property (nonatomic, readonly) BOOL createdInExistingGroup;

@end

#pragma mark -

@implementation OWSDisappearingConfigurationUpdateInfoMessage

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (instancetype)initWithContactThread:(TSContactThread *)contactThread
                            timestamp:(uint64_t)timestamp
               isConfigurationEnabled:(BOOL)isConfigurationEnabled
         configurationDurationSeconds:(uint32_t)configurationDurationSeconds
                  createdByRemoteName:(nullable NSString *)remoteName
{
    self = [super initWithThread:contactThread
                       timestamp:timestamp
                      serverGuid:nil
                     messageType:TSInfoMessageTypeDisappearingMessagesUpdate
             infoMessageUserInfo:nil];
    if (!self) {
        return self;
    }

    _configurationIsEnabled = isConfigurationEnabled;
    _configurationDurationSeconds = configurationDurationSeconds;
    _createdByRemoteName = remoteName;

    _createdInExistingGroup = false;

    return self;
}

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
                   customMessage:(nullable NSString *)customMessage
             infoMessageUserInfo:(nullable NSDictionary<InfoMessageUserInfoKey, id> *)infoMessageUserInfo
                     messageType:(TSInfoMessageType)messageType
                            read:(BOOL)read
                      serverGuid:(nullable NSString *)serverGuid
             unregisteredAddress:(nullable SignalServiceAddress *)unregisteredAddress
    configurationDurationSeconds:(unsigned int)configurationDurationSeconds
          configurationIsEnabled:(BOOL)configurationIsEnabled
             createdByRemoteName:(nullable NSString *)createdByRemoteName
          createdInExistingGroup:(BOOL)createdInExistingGroup
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId
                     attachmentIds:attachmentIds
                              body:body
                        bodyRanges:bodyRanges
                      contactShare:contactShare
                         editState:editState
                   expireStartedAt:expireStartedAt
                expireTimerVersion:expireTimerVersion
                         expiresAt:expiresAt
                  expiresInSeconds:expiresInSeconds
                         giftBadge:giftBadge
                 isGroupStoryReply:isGroupStoryReply
    isSmsMessageRestoredFromBackup:isSmsMessageRestoredFromBackup
                isViewOnceComplete:isViewOnceComplete
                 isViewOnceMessage:isViewOnceMessage
                       linkPreview:linkPreview
                    messageSticker:messageSticker
                     quotedMessage:quotedMessage
      storedShouldStartExpireTimer:storedShouldStartExpireTimer
             storyAuthorUuidString:storyAuthorUuidString
                storyReactionEmoji:storyReactionEmoji
                    storyTimestamp:storyTimestamp
                wasRemotelyDeleted:wasRemotelyDeleted
                     customMessage:customMessage
               infoMessageUserInfo:infoMessageUserInfo
                       messageType:messageType
                              read:read
                        serverGuid:serverGuid
               unregisteredAddress:unregisteredAddress];

    if (!self) {
        return self;
    }

    _configurationDurationSeconds = configurationDurationSeconds;
    _configurationIsEnabled = configurationIsEnabled;
    _createdByRemoteName = createdByRemoteName;
    _createdInExistingGroup = createdInExistingGroup;

    [self sdsFinalizeDisappearingConfigurationUpdateInfoMessage];

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (void)sdsFinalizeDisappearingConfigurationUpdateInfoMessage
{
    // At most one should be set
    OWSAssertDebug(!self.createdByRemoteName || !self.createdInExistingGroup);
}

- (BOOL)shouldUseReceiptDateForSorting
{
    // Use the timestamp, not the "received at" timestamp to sort,
    // since we're creating these interactions after the fact and back-dating them.
    return NO;
}

- (NSString *)infoMessagePreviewTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    DisappearingMessageToken *newToken =
        [[DisappearingMessageToken alloc] initWithIsEnabled:self.configurationIsEnabled
                                            durationSeconds:self.configurationDurationSeconds];
    return [[self class] legacyDisappearingMessageUpdateDescriptionWithToken:newToken
                                                     wasAddedToExistingGroup:self.createdInExistingGroup
                                                                 updaterName:self.createdByRemoteName];
}

@end

NS_ASSUME_NONNULL_END
