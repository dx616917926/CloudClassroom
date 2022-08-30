//
//  HXCalendarContentView.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <UIKit/UIKit.h>
#import "HXCalendarAppearance.h"
#import "HXCalendarCollectionViewFlowLayout.h"
#import "HXCalendarEventSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXCalendarContentView : UIView
@property (nonatomic,strong) HXCalendarCollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong) UICollectionView *collectionView;
//遮罩
@property (nonatomic,strong)UIView *maskView;
//事件代理
@property (weak, nonatomic) id<HXCalendarEventSource> eventSource;

@property (nonatomic,strong) NSDate *currentDate;
///滚动到单周需要的offset
@property (nonatomic,assign)CGFloat singleWeekOffsetY;
- (void)setSingleWeek:(BOOL)singleWeek;
///下一页
- (void)getDateDatas;
- (void)loadNextPage;
- (void)loadPreviousPage;
- (void)reloadAppearance;
///更新遮罩镂空的位置
- (void)setUpVisualRegion;
@end

NS_ASSUME_NONNULL_END
