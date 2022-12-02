//
//  BJLDocumentFileView.h
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/26.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

typedef NS_ENUM(NSInteger, BJLDocumentFileLayoutType) {
    BJLDocumentFileLayoutTypeDocument,
    BJLDocumentFileLayoutTypeCloud,
    BJLDocumentFileLayoutTypeHomework,
};

NS_ASSUME_NONNULL_BEGIN

@protocol BJLDocumentFileCloudDirectoryDelegate <NSObject>

- (nullable NSAttributedString *)currentCloudDirectoryString;

@end

@interface BJLDocumentFileView: UIView

- (instancetype)initWithRoom:(BJLRoom *)room;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic) void (^willshowFilelistCallback)(void);
@property (nonatomic) void (^allowStudentUploadFileCallback)(BOOL allow);
@property (nonatomic) void (^refreshCallback)(void);
@property (nonatomic) void (^uploadFileCallback)(void);
@property (nonatomic) void (^uploadImageCallback)(UIButton *button);
@property (nonatomic) void (^switchToHomeworkCallback)(void);

@property (nonatomic, readonly) BJLDocumentFileLayoutType documentFileLayoutType;

@property (nonatomic, weak) id<BJLDocumentFileCloudDirectoryDelegate> delegate;

// 是否展示的搜索结果
@property (nonatomic, readwrite) BOOL shouldShowSearchResult;

/**
 关闭课件管理视图
 */
@property (nonatomic, readonly) UIButton *closeButton;

@property (nonatomic, readonly) UITextField *searchTextField;

/**
搜索框的清空按钮
*/
@property (nonatomic, readonly) UIButton *clearSearchButton;

/**
 文档集合视图
 */
@property (nonatomic, readonly) UITableView *tableView;

@property (nonatomic, readonly) UIView *progressHUDLayer;

/**
 更新文档视图显示

 #param hidden NO --> 不存在文档时隐藏, YES --> 存在文档时显示
 */
- (void)updateDocumentFileViewHidden:(BOOL)hidden;

@property (nonatomic, readonly) BJLButton *uploadFileButton, *uploadImageButton;
;

/**
 更新云盘面包屑

 #param hidden NO --> 非根目录时展示路径, YES --> 在根目录时,隐藏面包屑
 */
- (void)updateCloudDirectoryHidden:(BOOL)hidden;

@property (nonatomic, readonly) UITextView *cloudDirectoryTextView;

@end

NS_ASSUME_NONNULL_END
