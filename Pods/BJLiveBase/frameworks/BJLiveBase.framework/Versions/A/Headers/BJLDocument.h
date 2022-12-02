//
//  BJLDocument.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-07.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 课件显示模式 */
typedef NS_ENUM(NSInteger, BJLContentMode) {
    /** 完整 */
    BJLContentMode_scaleAspectFit,
    /** 铺满 */
    BJLContentMode_scaleAspectFill
};

FOUNDATION_EXPORT NSString *const BJLBlackboardID;
FOUNDATION_EXPORT NSInteger const BJLWritingboardPageIndex;
FOUNDATION_EXPORT NSString *const BJLWritingboardUserNumberForTeacher;

#pragma mark - page info

@interface BJLDocumentPageInfo: NSObject

@property (nonatomic, readonly) BOOL isAlbum;
@property (nonatomic, readonly) BOOL isWebDoc;
@property (nonatomic, readonly) NSInteger pageCount; // will change if isWebDoc
@property (nonatomic, readonly) NSArray<NSNumber *> *pageIDs;
/**
 if isAlbum, file urls format: {pageURLPrefix}_{pageIndex+1}.png
 if !isAlbum, file url: {pageURLString} */
@property (nonatomic, readonly, copy) NSString *pageURLString;
@property (nonatomic, readonly, copy, nullable) NSString *pageURLPrefix; // nil if NOT isAlbum

@property (nonatomic, readonly) NSInteger width, height;

- (BOOL)containsPageIndex:(NSInteger)pageIndex;

/** original pageURLString with pageIndex */
- (nullable NSString *)pageURLStringWithPageIndex:(NSInteger)pageIndex;

@end

#pragma mark - display info

@interface BJLDocumentDisplayInfo: NSObject

@property (nonatomic) CGFloat topOffset; // 文档区域当前滑动位置的 contentOffset.y
@property (nonatomic) CGFloat leftOffset; // 文档区域当前滑动位置的 contentOffset.x
@property (nonatomic) BJLContentMode contentMode;
@property (nonatomic) CGFloat scale;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger stepIndex;

@end

#pragma mark - document

@interface BJLDocumentUploader: NSObject

@property (nonatomic, readonly, copy) NSString *number;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) NSInteger role; //BJLUserRole 类型
@end

@interface BJLDocument: NSObject

@property (nonatomic, readonly, copy, nullable) NSString *documentID;
@property (nonatomic, readonly, copy) NSString *fileID, *fileExtension;
@property (nonatomic) NSString *fileName;
@property (nonatomic, readonly) NSString *animatedPPTURL;
@property (nonatomic, readonly) BOOL isAnimate;
@property (nonatomic, readonly) BOOL isRelatedDocument;
@property (nonatomic, readonly) BJLDocumentPageInfo *pageInfo;
@property (nonatomic, readonly) BJLDocumentDisplayInfo *displayInfo;
@property (nonatomic, readonly, copy) NSDictionary *remarkInfo;
@property (nonatomic, readonly) CGFloat byteSize;
@property (nonatomic, readonly) NSString *finderPath;
@property (nonatomic, readonly) NSTimeInterval lastTimeInterval;
@property (nonatomic, readonly) BJLDocumentUploader *fromUser;

/** 是否是h5链接形式的课件 */
@property (nonatomic, readonly) BOOL isH5LinkCourseware;

- (BOOL)isSyncedWithServer;
- (BOOL)isWhiteBoard;

+ (instancetype)documentWithUploadResponseData:(NSDictionary *)responseData;
+ (instancetype)documentWithTranscodeResponseData:(NSDictionary *)responseData;

- (void)updateDocumentName:(NSString *)name pageInfo:(BJLDocumentPageInfo *)pageInfo;
- (void)updateDocumentName:(NSString *)name documentFromTranscode:(BJLDocument *)document;

#pragma mark - homework

@property (nonatomic, readonly) BOOL isHomework;
@property (nonatomic, readonly, nullable) NSString *homeworkID;

// 解析上传作业返回的数据为document
+ (instancetype)documentWithUploadHomeworkResponseData:(NSDictionary *)responseData;

// 作业model数据转化为document
+ (instancetype)documentWithHomeworkResponseData:(NSDictionary *)homeworkData;

#pragma mark - cloud

@property (nonatomic, readonly) BOOL isCloudFile;

// 解析上传云盘返回的数据为一个document
+ (instancetype)documentWithUploadCloudResponseData:(NSDictionary *)responseData;

@end

@interface BJLDocumentTranscodeModel: NSObject

@property (nonatomic, readonly) NSString *fileID;
@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, readonly) NSInteger errorCode;

@end

#pragma mark - whiteboard

@interface BJLWhiteboard: NSObject

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, nullable) NSString *urlString;
@property (nonatomic, nullable) NSString *name;

@end

NS_ASSUME_NONNULL_END
