//
//  BJLDrawingVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLDrawingVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLDrawingVM (swift)
- (id<BJLObservation>)sw_didLaserPointMoveToLocationDocumentIDPageIndex:(BJLControlObserving (^)(CGPoint location, NSString *documentID, NSUInteger pageIndex))block NS_SWIFT_NAME(sw_didLaserPointMoveToLocationDocumentIDPageIndex(_:));
- (id<BJLObservation>)sw_handWritingBoardDidConnectFailed:(BJLControlObserving (^)(CBPeripheral *handWritingBoard))block NS_SWIFT_NAME(sw_handWritingBoardDidConnectFailed(_:));
- (id<BJLObservation>)sw_didHandWritingBoardPointMoveToLocationDocumentIDPageIndex:(BJLControlObserving (^)(CGPoint location, NSString *documentID, NSUInteger pageIndex))block NS_SWIFT_NAME(sw_didHandWritingBoardPointMoveToLocationDocumentIDPageIndex(_:));
- (id<BJLObservation>)sw_didPaintPointMoveToLocationDocumentIDPageIndexColor:(BJLControlObserving (^)(CGPoint location, NSString *documentID, NSUInteger pageIndex, UIColor *_Nullable color))block NS_SWIFT_NAME(sw_didPaintPointMoveToLocationDocumentIDPageIndexColor(_:));
- (id<BJLObservation>)sw_didPaintPointMoveToLocationDocumentIDPageIndexColorFromCurrentUser:(BJLControlObserving (^)(CGPoint location, NSString *documentID, NSUInteger pageIndex, UIColor *_Nullable color, BOOL fromCurrentUser))block NS_SWIFT_NAME(sw_didPaintPointMoveToLocationDocumentIDPageIndexColorFromCurrentUser(_:));
- (id<BJLObservation>)sw_didMousePointMoveToLocationDocumentIDPageIndex:(BJLControlObserving (^)(CGPoint location, NSString *documentID, NSUInteger pageIndex))block NS_SWIFT_NAME(sw_didMousePointMoveToLocationDocumentIDPageIndex(_:));
- (id<BJLObservation>)sw_didMousePointMoveToLocationDocumentIDPageIndexColor:(BJLControlObserving (^)(CGPoint location, NSString *documentID, NSUInteger pageIndex, UIColor *_Nullable color))block NS_SWIFT_NAME(sw_didMousePointMoveToLocationDocumentIDPageIndexColor(_:));
- (id<BJLObservation>)sw_didFilePaintOnBlackboard:(BJLControlObserving (^)(BJLError *_Nullable error))block NS_SWIFT_NAME(sw_didFilePaintOnBlackboard(_:));
@end

NS_ASSUME_NONNULL_END
