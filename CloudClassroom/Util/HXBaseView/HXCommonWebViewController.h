//
//  HXCommonWebViewController.h
//  HXMinedu
//
//  Created by 邓雄 on 2021/4/11.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXCommonWebViewController : HXBaseViewController
//外部url
@property (nonatomic,strong)NSString *urlString;
//自定义标题文字
@property (nonatomic,strong)NSString *cuntomTitle;

@end

NS_ASSUME_NONNULL_END
