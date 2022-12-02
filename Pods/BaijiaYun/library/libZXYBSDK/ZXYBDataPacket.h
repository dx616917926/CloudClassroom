//
//  ZXYBDataPacket.h
//  ZXYBSDK
//
//  Created by 朱先生 on 2021/2/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXYBDataPacket : NSObject

    @property(nonatomic,assign)int penStatus;
    //板子坐标
    @property(nonatomic,assign)float x;
    @property(nonatomic,assign)float y;
    //转换后的坐标
    @property(nonatomic,assign)float tx;
    @property(nonatomic,assign)float ty;
    //比例坐标
    @property(nonatomic,assign)float sx;
    @property(nonatomic,assign)float sy;

    @property(nonatomic,assign)float pressure;
    @property(nonatomic,assign)long timestamp;

    @property(nonatomic,assign)int buttonIndex;
    @property(nonatomic,assign)int softKey;

@end

NS_ASSUME_NONNULL_END
