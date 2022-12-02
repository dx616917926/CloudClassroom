//
//  BJLDocumentVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLDocumentVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLDocumentVM (swift)
- (id<BJLObservation>)sw_allDocumentsDidOverwrite:(BJLControlObserving (^)(NSArray<BJLDocument *> *_Nullable allDocuments))block NS_SWIFT_NAME(sw_allDocumentsDidOverwrite(_:));
- (id<BJLObservation>)sw_didAddDocument:(BJLControlObserving (^)(BJLDocument *document))block NS_SWIFT_NAME(sw_didAddDocument(_:));
- (id<BJLObservation>)sw_didDeleteDocument:(BJLControlObserving (^)(BJLDocument *document))block NS_SWIFT_NAME(sw_didDeleteDocument(_:));
- (id<BJLObservation>)sw_didAddWhiteboardPage:(BJLControlObserving (^)(NSInteger pageIndex))block NS_SWIFT_NAME(sw_didAddWhiteboardPage(_:));
- (id<BJLObservation>)sw_didDeleteWhiteboardPageWithIndex:(BJLControlObserving (^)(NSInteger pageIndex))block NS_SWIFT_NAME(sw_didDeleteWhiteboardPageWithIndex(_:));
- (id<BJLObservation>)sw_didUpdateDocument:(BJLControlObserving (^)(BJLDocument *document))block NS_SWIFT_NAME(sw_didUpdateDocument(_:));
- (id<BJLObservation>)sw_didUpdateDocumentWindowWithModelShouldReset:(BJLControlObserving (^)(BJLWindowUpdateModel *updateModel, BOOL shouldReset))block NS_SWIFT_NAME(sw_didUpdateDocumentWindowWithModelShouldReset(_:));
- (id<BJLObservation>)sw_didPullAllWritingBoard:(BJLControlObserving (^)(NSArray<NSString *> *_Nullable writingBoardIDList))block NS_SWIFT_NAME(sw_didPullAllWritingBoard(_:));
- (id<BJLObservation>)sw_didPublishWritingBoard:(BJLControlObserving (^)(BJLWritingBoard *writingBoard))block NS_SWIFT_NAME(sw_didPublishWritingBoard(_:));
- (id<BJLObservation>)sw_didSubmitWritingBoardFrom:(BJLControlObserving (^)(BJLWritingBoard *writingBoard, BJLUser *user))block NS_SWIFT_NAME(sw_didSubmitWritingBoardFrom(_:));
- (id<BJLObservation>)sw_didParticipateWritingBoardFrom:(BJLControlObserving (^)(BJLWritingBoard *writingBoard, BJLUser *user))block NS_SWIFT_NAME(sw_didParticipateWritingBoardFrom(_:));
- (id<BJLObservation>)sw_didPullWritingBoard:(BJLControlObserving (^)(BJLWritingBoard *_Nullable writingBoard))block NS_SWIFT_NAME(sw_didPullWritingBoard(_:));
- (id<BJLObservation>)sw_didUpdateWritingBoradWindowWithModelShouldReset:(BJLControlObserving (^)(BJLWindowUpdateModel *updateModel, BOOL shouldReset))block NS_SWIFT_NAME(sw_didUpdateWritingBoradWindowWithModelShouldReset(_:));
- (id<BJLObservation>)sw_didLoadMediaFiles:(BJLControlObserving (^)(NSArray<BJLMediaFile *> *mediaFiles))block NS_SWIFT_NAME(sw_didLoadMediaFiles(_:));
@end

NS_ASSUME_NONNULL_END
