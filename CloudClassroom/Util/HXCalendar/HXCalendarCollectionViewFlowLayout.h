//
//  HXCalendarCollectionViewFlowLayout.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCalendarCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic,assign) NSUInteger itemCountPerRow;

//    一页显示多少行
@property (nonatomic,assign) NSUInteger rowCount;
@end

NS_ASSUME_NONNULL_END
