//
//  BJLScLanguageChooseView.h
//  BJLiveUI
//
//  Created by 辛亚鹏 on 2021/7/23.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLLanguageChooseView: UIView

@property (nonatomic, readonly) BJLMessageLanguageType type;

- (CGSize)expectSize;

@end

NS_ASSUME_NONNULL_END
