//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "TSMessage.h"
#import "OWSDisappearingMessagesConfiguration.h"
#import "OWSDisappearingMessagesJob.h"
#import "TSAttachment.h"
#import "TSAttachmentStream.h"
#import "TSQuotedMessage.h"
#import "TSThread.h"
#import <SignalServiceKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

static const NSUInteger OWSMessageSchemaVersion = 4;

#pragma mark -

@interface TSMessage ()

/// These are body attachments.
@property (nonatomic) NSArray<NSString *> *attachmentIds;
@property (nonatomic, nullable) NSString *body;
@property (nonatomic, nullable) MessageBodyRanges *bodyRanges;

@property (nonatomic) uint32_t expiresInSeconds;
@property (nonatomic) uint64_t expireStartedAt;
@property (nonatomic, nullable) NSNumber *expireTimerVersion;

/**
 * The version of the model class's schema last used to serialize this model. Use this to manage data migrations during
 * object de/serialization.
 *
 * e.g.
 *
 *    - (id)initWithCoder:(NSCoder *)coder
 *    {
 *      self = [super initWithCoder:coder];
 *      if (!self) { return self; }
 *      if (_schemaVersion < 2) {
 *        _newName = [coder decodeObjectForKey:@"oldName"]
 *      }
 *      ...
 *      _schemaVersion = 2;
 *    }
 */
@property (nonatomic, readonly) NSUInteger schemaVersion;

@property (nonatomic, nullable) TSQuotedMessage *quotedMessage;
@property (nonatomic, nullable) OWSContact *contactShare;
@property (nonatomic, nullable) OWSLinkPreview *linkPreview;
@property (nonatomic, nullable) MessageSticker *messageSticker;

@property (nonatomic) BOOL isViewOnceMessage;
@property (nonatomic) BOOL isViewOnceComplete;
@property (nonatomic) BOOL wasRemotelyDeleted;

@property (nonatomic, nullable) NSString *storyReactionEmoji;

// This property is only intended to be used by GRDB queries.
@property (nonatomic, readonly) BOOL storedShouldStartExpireTimer;

@end

#pragma mark -

@implementation TSMessage

- (instancetype)initMessageWithBuilder:(TSMessageBuilder *)messageBuilder
{
    self = [super initWithTimestamp:messageBuilder.timestamp
                receivedAtTimestamp:messageBuilder.receivedAtTimestamp
                             thread:messageBuilder.thread];
    if (!self) {
        return self;
    }

    _schemaVersion = OWSMessageSchemaVersion;

    if (messageBuilder.messageBody.length > 0) {
        _body = messageBuilder.messageBody;
        _bodyRanges = messageBuilder.bodyRanges;
    } else if (messageBuilder.messageBody != nil) {
        OWSFailDebug(@"Empty message body.");
    }
    _attachmentIds = @[];
    _editState = messageBuilder.editState;
    _expiresInSeconds = messageBuilder.expiresInSeconds;
    _expireStartedAt = messageBuilder.expireStartedAt;
    _expireTimerVersion = messageBuilder.expireTimerVersion;
    [self updateExpiresAt];
    _isSmsMessageRestoredFromBackup = messageBuilder.isSmsMessageRestoredFromBackup;
    _isViewOnceMessage = messageBuilder.isViewOnceMessage;
    _isViewOnceComplete = messageBuilder.isViewOnceComplete;
    _wasRemotelyDeleted = messageBuilder.wasRemotelyDeleted;

    _storyTimestamp = messageBuilder.storyTimestamp;
    _storyAuthorUuidString = messageBuilder.storyAuthorAci.serviceIdUppercaseString;
    _storyReactionEmoji = messageBuilder.storyReactionEmoji;
    _isGroupStoryReply = messageBuilder.isGroupStoryReply;

    _quotedMessage = messageBuilder.quotedMessage;
    _contactShare = messageBuilder.contactShare;
    _linkPreview = messageBuilder.linkPreview;
    _messageSticker = messageBuilder.messageSticker;
    _giftBadge = messageBuilder.giftBadge;

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
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId];

    if (!self) {
        return self;
    }

    _attachmentIds = attachmentIds;
    _body = body;
    _bodyRanges = bodyRanges;
    _contactShare = contactShare;
    _editState = editState;
    _expireStartedAt = expireStartedAt;
    _expireTimerVersion = expireTimerVersion;
    _expiresAt = expiresAt;
    _expiresInSeconds = expiresInSeconds;
    _giftBadge = giftBadge;
    _isGroupStoryReply = isGroupStoryReply;
    _isSmsMessageRestoredFromBackup = isSmsMessageRestoredFromBackup;
    _isViewOnceComplete = isViewOnceComplete;
    _isViewOnceMessage = isViewOnceMessage;
    _linkPreview = linkPreview;
    _messageSticker = messageSticker;
    _quotedMessage = quotedMessage;
    _storedShouldStartExpireTimer = storedShouldStartExpireTimer;
    _storyAuthorUuidString = storyAuthorUuidString;
    _storyReactionEmoji = storyReactionEmoji;
    _storyTimestamp = storyTimestamp;
    _wasRemotelyDeleted = wasRemotelyDeleted;

    [self sdsFinalizeMessage];

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (void)sdsFinalizeMessage
{
    [self updateExpiresAt];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

    if (_schemaVersion < 2) {
        // renamed _attachments to _attachmentIds
        if (!_attachmentIds) {
            _attachmentIds = [coder decodeObjectForKey:@"attachments"];
        }
    }

    if (_schemaVersion < 3) {
        _expiresInSeconds = 0;
        _expireStartedAt = 0;
        _expiresAt = 0;
    }

    if (_schemaVersion < 4) {
        // Wipe out the body field on these legacy attachment messages.
        //
        // Explanation: Historically, a message sent from iOS could be an attachment XOR a text message,
        // but now we support sending an attachment+caption as a single message.
        //
        // Other clients have supported sending attachment+caption in a single message for a long time.
        // So the way we used to handle receiving them was to make it look like they'd sent two messages:
        // first the attachment+caption (we'd ignore this caption when rendering), followed by a separate
        // message with just the caption (which we'd render as a simple independent text message), for
        // which we'd offset the timestamp by a little bit to get the desired ordering.
        //
        // Now that we can properly render an attachment+caption message together, these legacy "dummy" text
        // messages are not only unnecessary, but worse, would be rendered redundantly. For safety, rather
        // than building the logic to try to find and delete the redundant "dummy" text messages which users
        // have been seeing and interacting with, we delete the body field from the attachment message,
        // which iOS users have never seen directly.
        if (_attachmentIds.count > 0) {
            _body = nil;
        }
    }

    if (!_attachmentIds) {
        _attachmentIds = @[];
    }

    _schemaVersion = OWSMessageSchemaVersion;

    // Upgrades legacy messages.
    //
    // TODO: We can eventually remove this migration since
    //       per-message expiration was never released to
    //       production.
    NSNumber *_Nullable perMessageExpirationDurationSeconds =
        [coder decodeObjectForKey:@"perMessageExpirationDurationSeconds"];
    if (perMessageExpirationDurationSeconds.unsignedIntegerValue > 0) {
        _isViewOnceMessage = YES;
    }
    NSNumber *_Nullable perMessageExpirationHasExpired = [coder decodeObjectForKey:@"perMessageExpirationHasExpired"];
    if (perMessageExpirationHasExpired.boolValue > 0) {
        _isViewOnceComplete = YES;
    }

    return self;
}

- (void)setExpireStartedAt:(uint64_t)expireStartedAt
{
    if (_expireStartedAt != 0 && _expireStartedAt < expireStartedAt) {
        return;
    }

    uint64_t now = [NSDate ows_millisecondTimeStamp];
    if (expireStartedAt > now) {
        OWSLogWarn(@"using `now` instead of future time");
    }

    _expireStartedAt = MIN(now, expireStartedAt);

    [self updateExpiresAt];
}

// This method will be called after every insert and update, so it needs
// to be cheap.
- (BOOL)shouldStartExpireTimer
{
    if (self.hasPerConversationExpirationStarted) {
        // Expiration already started.
        return YES;
    }

    return self.hasPerConversationExpiration;
}

- (void)updateExpiresAt
{
    if (self.hasPerConversationExpirationStarted) {
        _expiresAt = _expireStartedAt + (uint64_t)_expiresInSeconds * 1000;
    } else {
        _expiresAt = 0;
    }
}

#pragma mark - Story Context

- (nullable AciObjC *)storyAuthorAci
{
    return [[AciObjC alloc] initWithAciString:self.storyAuthorUuidString];
}

- (nullable SignalServiceAddress *)storyAuthorAddress
{
    AciObjC *storyAuthorAci = self.storyAuthorAci;
    if (storyAuthorAci == nil) {
        return nil;
    }
    return [[SignalServiceAddress alloc] initWithServiceIdObjC:storyAuthorAci];
}

- (BOOL)isStoryReply
{
    return self.storyAuthorUuidString != nil && self.storyTimestamp != nil;
}

#pragma mark - Attachments

- (NSArray<NSString *> *)attachmentIds
{
    return _attachmentIds;
}

- (void)setLegacyBodyAttachmentIds:(NSArray<NSString *> *)attachmentIds
{
    _attachmentIds = attachmentIds;
}

- (NSString *)debugDescription
{
    BOOL hasAttachments = _attachmentIds && _attachmentIds.count;
    if (hasAttachments > 0 && self.body.length > 0) {
        NSString *attachmentId = self.attachmentIds[0];
        return [NSString
            stringWithFormat:@"Media Message with attachmentId: %@ and caption: '%@'", attachmentId, self.body];
    } else if (hasAttachments) {
        NSString *attachmentId = self.attachmentIds[0];
        return [NSString stringWithFormat:@"Media Message with attachmentId: %@", attachmentId];
    } else {
        return [NSString stringWithFormat:@"%@ with body: %@ has mentions: %@",
            [self class],
            self.body,
            self.bodyRanges.hasMentions ? @"YES" : @"NO"];
    }
}


- (void)anyWillInsertWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyWillInsertWithTransaction:transaction];

    // StickerManager does reference counting of "known" sticker packs.
    if (self.messageSticker != nil) {
        BOOL willInsert = (self.uniqueId.length < 1
            || nil == [TSMessage anyFetchWithUniqueId:self.uniqueId transaction:transaction]);

        if (willInsert) {
            [StickerManager addKnownStickerInfo:self.messageSticker.info transaction:transaction];
        }
    }

    [self insertMentionsInDatabaseWithTx:transaction];

    [self updateStoredShouldStartExpireTimer];
}

- (void)anyDidInsertWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidInsertWithTransaction:transaction];

    [self _anyDidInsertWithTx:transaction];

    [self ensurePerConversationExpirationWithTransaction:transaction];

    [self touchStoryMessageIfNecessaryWithReplyCountIncrement:ReplyCountIncrementNewReplyAdded transaction:transaction];
}

- (void)anyWillUpdateWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyWillUpdateWithTransaction:transaction];

    [self updateStoredShouldStartExpireTimer];
}

- (void)anyDidUpdateWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidUpdateWithTransaction:transaction];

    [self _anyDidUpdateWithTx:transaction];

    [self ensurePerConversationExpirationWithTransaction:transaction];

    [self touchStoryMessageIfNecessaryWithReplyCountIncrement:ReplyCountIncrementNoIncrement transaction:transaction];
}

- (void)ensurePerConversationExpirationWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    if (self.hasPerConversationExpirationStarted) {
        // Expiration already started.
        return;
    }
    if (![self shouldStartExpireTimer]) {
        return;
    }
    uint64_t nowMs = [NSDate ows_millisecondTimeStamp];
    [[OWSDisappearingMessagesJob shared] startAnyExpirationForMessage:self
                                                  expirationStartedAt:nowMs
                                                          transaction:transaction];
}

- (void)updateStoredShouldStartExpireTimer
{
    _storedShouldStartExpireTimer = [self shouldStartExpireTimer];
}

- (BOOL)hasPerConversationExpiration
{
    return self.expiresInSeconds > 0;
}

- (BOOL)hasPerConversationExpirationStarted
{
    return _expireStartedAt > 0 && _expiresInSeconds > 0;
}

- (BOOL)shouldUseReceiptDateForSorting
{
    return YES;
}

- (nullable NSString *)body
{
    return _body.filterStringForDisplay;
}

#pragma mark - Update With... Methods

- (void)updateWithExpireStartedAt:(uint64_t)expireStartedAt transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(expireStartedAt > 0);
    OWSAssertDebug(self.expiresInSeconds > 0);

    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) { [message setExpireStartedAt:expireStartedAt]; }];
}

- (void)updateWithLinkPreview:(OWSLinkPreview *)linkPreview transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(linkPreview);
    OWSAssertDebug(transaction);

    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) { [message setLinkPreview:linkPreview]; }];
}

- (void)updateWithQuotedMessage:(TSQuotedMessage *)quotedMessage transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(quotedMessage);
    OWSAssertDebug(transaction);

    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) { [message setQuotedMessage:quotedMessage]; }];
}

- (void)updateWithMessageSticker:(MessageSticker *)messageSticker transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(messageSticker);
    OWSAssertDebug(transaction);

    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) { message.messageSticker = messageSticker; }];
}

- (void)updateWithContactShare:(OWSContact *)contactShare transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(contactShare);
    OWSAssertDebug(transaction);

    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) { message.contactShare = contactShare; }];
}

#ifdef TESTABLE_BUILD

// This method is for testing purposes only.
- (void)updateWithMessageBody:(nullable NSString *)messageBody transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(transaction);

    [self anyUpdateMessageWithTransaction:transaction block:^(TSMessage *message) { message.body = messageBody; }];
}

#endif

#pragma mark - View Once

- (void)updateWithViewOnceCompleteAndRemoveRenderableContentWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(transaction);
    OWSAssertDebug(self.isViewOnceMessage);
    OWSAssertDebug(!self.isViewOnceComplete);

    [self removeAllRenderableContentWithTransaction:transaction
                                 messageUpdateBlock:^(TSMessage *message) { message.isViewOnceComplete = YES; }];
}

#pragma mark - Remote Delete

- (void)updateWithRemotelyDeletedAndRemoveRenderableContentWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(transaction);
    OWSAssertDebug(!self.wasRemotelyDeleted);

    [self removeAllReactionsWithTransaction:transaction];

    [self removeAllRenderableContentWithTransaction:transaction
                                 messageUpdateBlock:^(TSMessage *message) { message.wasRemotelyDeleted = YES; }];
}

#pragma mark - Remove Renderable Content

- (void)removeAllRenderableContentWithTransaction:(SDSAnyWriteTransaction *)transaction
                               messageUpdateBlock:(void (^)(TSMessage *message))messageUpdateBlock
{
    // We call removeAllAttachmentsWithTransaction() before
    // anyUpdateWithTransaction, because anyUpdateWithTransaction's
    // block can be called twice, once on this instance and once
    // on the copy from the database.  We only want to remove
    // attachments once.
    [self anyReloadWithTransaction:transaction ignoreMissing:YES];
    [self removeAllAttachmentsWithTx:transaction];
    [self removeAllMentionsWithTransaction:transaction];
    [MessageSendLogObjC deleteAllPayloadsForInteraction:self tx:transaction];

    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) {
                                        // Remove renderable content.
                                        message.body = nil;
                                        message.bodyRanges = nil;
                                        message.contactShare = nil;
                                        message.quotedMessage = nil;
                                        message.linkPreview = nil;
                                        message.messageSticker = nil;
                                        message.storyReactionEmoji = nil;

                                        messageUpdateBlock(message);
                                    }];
}

#pragma mark - Partial Delete

- (void)removeBodyTextWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [self removeOversizeTextAttachmentWithTx:transaction];
    [self removeLinkPreviewAttachmentWithTx:transaction];
    [self removeAllMentionsWithTransaction:transaction];
    // That removed the attachments; now we remove the fields.
    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) {
                                        message.body = nil;
                                        message.bodyRanges = nil;
                                        message.linkPreview = nil;
                                    }];
}

- (void)removeMediaAndShareAttachmentsWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [self removeBodyMediaAttachmentsWithTx:transaction];
    [self removeContactShareAvatarAttachmentWithTx:transaction];
    [self removeStickerAttachmentWithTx:transaction];
    // That removed the attachments; now we remove the whole contact share/sticker objects.
    [self anyUpdateMessageWithTransaction:transaction
                                    block:^(TSMessage *message) {
                                        message.contactShare = nil;
                                        message.messageSticker = nil;
                                    }];
}

@end

NS_ASSUME_NONNULL_END
