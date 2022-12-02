//
//  BJLCloudFile.h
//  BJLiveCore
//
//  Created by 凡义 on 2020/9/9.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLMediaFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLCloudFile: NSObject

@property (nonatomic, readonly, copy, nullable) NSString *fileID;
@property (nonatomic, readonly, copy) NSString *fileExtension;
@property (nonatomic, readonly, copy) NSString *fileName;
@property (nonatomic, readonly) CGFloat byteSize;
@property (nonatomic, readonly) NSUInteger format; // 0：原始课件 1：h5 课件 2:动态ppt
@property (nonatomic, readonly) BOOL isPublicFile; // 是否是公共资源文件, YES 表示不允许老自行师删除

@property (nonatomic, readonly, copy) NSString *fromUserMobile, *fromUserName;
@property (nonatomic, readonly) NSTimeInterval lastTimeInterval;

// 音视频类型的文件的信息
@property (nonatomic, readonly, nullable) BJLMediaFile *mediaFile;

// 文件夹的信息
@property (nonatomic, readonly) BOOL isDirectory;
@property (nonatomic, readonly, copy, nullable) NSString *finderID; //isDirectory = YES时, 当前字段有效

@end

NS_ASSUME_NONNULL_END
