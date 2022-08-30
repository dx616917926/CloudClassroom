//
//  HXCalendarManager.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "HXCalendarScrollView.h"
#import "HXCalendarEventSource.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXCalendarManager : NSObject
@property (nonatomic,strong)HXCalendarScrollView *calenderScrollView;

@property (nonatomic,strong) HXCalendarWeekDayView *weekDayView;

@property (weak, nonatomic) id<HXCalendarEventSource> eventSource;

@property (nonatomic,strong , readonly) NSDate *currentSelectedDate;


///回到今天
- (void)goBackToday;

/// 重新加载外观
- (void)reloadAppearanceAndData;

///  前一页。上个月
- (void)loadPreviousPage;
///   下一页 下一个月

- (void)loadNextPage;
- (void)showSingleWeek;
- (void)showAllWeek;
@end

NS_ASSUME_NONNULL_END
