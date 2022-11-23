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

#define   ExamChoiceImageViewTag       1111111
#define   ExamChoiceTapViewTag         2222222

#define   ExamSelectColor              COLOR_WITH_ALPHA(0x2E5BFD, 0.2)
#define   ExamUnSelectColor            COLOR_WITH_ALPHA(0x000000, 0.04)
#define   ExamErrorSelectColor         COLOR_WITH_ALPHA(0xF05151, 0.04)

#define   ExamSplitViewHeight          44
#define   ExamBottomViewHeight         72
#define   ExamSubChoiceCellHeight      (kScreenHeight-kNavigationBarHeight-ExamSplitViewHeight-ExamBottomViewHeight)

#endif /* DTCoreTextToolsHeader_h */
