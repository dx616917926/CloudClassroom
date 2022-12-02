//
//  BJLLaserPointView.h
//  BJLiveUI
//
//  Created by HuangJie on 2018/11/21.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLLaserPointView: UIView

@property (nonatomic) NSString *documentID;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) BOOL isPreview; // 是否是预览模式下的课件，课件预览模式不触发信令
@property (nonatomic) NSInteger blackboardPages; // 黑板的滑动页码数，默认为 1，目前仅小班课有可滑动黑板
@property (nonatomic) CGFloat blackboardIndex; // 黑板的偏移索引，默认为 0，仅多页滑动黑板才需要处理
@property (nonatomic, nullable) CGPoint (^requirePointCallback)(NSString *documentID, CGPoint point); // 获取文档的点在当前视图的位置，不设置则使用 `updateShapeShowSize:` 的大小

- (instancetype)initWithRoom:(BJLRoom *)room;

- (instancetype)init NS_UNAVAILABLE;

- (void)updateShapeShowSize:(CGSize)size;

- (void)hideLaserPoint;

@end

NS_ASSUME_NONNULL_END
