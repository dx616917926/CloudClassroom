//
//  DTCoreTextToolsHeader.h
//  CloudClassroom
//
//  Created by mac on 2022/11/16.
//

#ifndef DTCoreTextToolsHeader_h
#define DTCoreTextToolsHeader_h

#import "DTCoreText.h"
#import "DTAnimatedGIF.h"
#import "UIImage+DTFoundation.h"

#define   ExamChoiceImageViewTag       1111111

#define   ExamChoiceTapViewTag         2222222

//答题选择背景颜色
#define   ExamSelectColor              COLOR_WITH_ALPHA(0x2E5BFD, 0.2)
//答题未选择背景颜色
#define   ExamUnSelectColor            COLOR_WITH_ALPHA(0x000000, 0.04)
//答题错误选择背景颜色
#define   ExamErrorSelectColor         COLOR_WITH_ALPHA(0xF05151, 0.04)
//解析文本颜色
#define   ExamJieXiColor               COLOR_WITH_ALPHA(0xA4A4A4, 1)

#define   ExamSplitViewHeight          44
#define   ExamBottomViewHeight         (72+kScreenBottomMargin)
#define   ExamSubChoiceCellHeight      (kScreenHeight-kNavigationBarHeight-ExamSplitViewHeight-ExamBottomViewHeight)

#endif /* DTCoreTextToolsHeader_h */
