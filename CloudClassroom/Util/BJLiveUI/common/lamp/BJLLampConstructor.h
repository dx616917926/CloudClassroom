//
//  BJLLampUpdate.h
//  BJLiveUIBigClass
//
//  Created by lwl on 2021/9/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLLampConstructor: NSObject

- (void)updateLampWithLamp:(nullable BJLLamp *)lamp
                  lampView:(UIView *)lampView
               lampContent:(NSString *)lampContent
        containerViewWidth:(CGFloat)containerViewWidth
       containerViewHeight:(CGFloat)containerViewHeight;

- (void)destoryLampLabel;

@end

NS_ASSUME_NONNULL_END
