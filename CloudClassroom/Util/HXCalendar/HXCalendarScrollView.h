//
//  HXCalendarScrollView.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <UIKit/UIKit.h>
#import "HXCalendarContentView.h"
#import "HXCalendarWeekDayView.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXCalendarScrollView : UIScrollView
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)HXCalendarContentView *calendarView;
@property (nonatomic,strong)UIColor *bgColor;

- (void)scrollToSingleWeek;

- (void)scrollToAllWeek;
///点击日期，刷新数据
-(void)reloadData:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END
