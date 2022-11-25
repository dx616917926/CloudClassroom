//
//  HXMessageAttachmentModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXMessageAttachmentModel : NSObject
///附件名称
@property(nonatomic, copy) NSString *fileName;
///附件url
@property(nonatomic, copy) NSString *directory;
///附件大小
@property(nonatomic, assign) CGFloat fileSize;
@end

NS_ASSUME_NONNULL_END
