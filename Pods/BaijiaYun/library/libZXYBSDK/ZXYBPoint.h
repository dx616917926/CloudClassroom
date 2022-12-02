//
//  ZXYBPoint.h
//  ZXYBSdkDemo
//
//  Created by 朱先生 on 2021/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXYBPoint : NSObject

@property (nonatomic,assign) int boardX;
@property (nonatomic,assign) int boardY;
@property (nonatomic,assign) float sx;
@property (nonatomic,assign) float tx;
@property (nonatomic,assign) float ty;
@property (nonatomic,assign) float sy;
@property (nonatomic,assign) float pressure;
@property (nonatomic,assign) float relativeT;

@end

NS_ASSUME_NONNULL_END
