//
//  HXNoDataTipView.h
//  HXMinedu
//
//  Created by mac on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    NoType,
    NoType2,
    NoType3,
} NoDataType;

@interface HXNoDataTipView : UIView
@property(nonatomic,assign) NoDataType type;
@property(nonatomic,strong) UIImage *tipImage;
@property(nonatomic,strong) NSString *tipTitle;
@property(nonatomic,assign) NSInteger tipImageViewOffset;
@property(nonatomic,assign) NSInteger tipLabelOffset;

@end

NS_ASSUME_NONNULL_END
