//
//  BJVLampConstructor.h
//  BJPlaybackUI
//
//  Created by lwl on 2021/9/6.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJVLamp.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVLampConstructor: NSObject

- (void)updateLampWithLamp:(BJVLamp *)lamp
                  lampView:(UIView *)lampView
               lampContent:(NSString *)lampContent;

@end

NS_ASSUME_NONNULL_END
