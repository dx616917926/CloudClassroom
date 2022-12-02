//
//  BJLDrawingVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-08.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "BJLBaseVM.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 画笔管理 */
@interface BJLDrawingVM: BJLBaseVM

/** 画笔操作模式 */
@property (nonatomic, readonly) BJLBrushOperateMode brushOperateMode;

/** 画笔类型 */
@property (nonatomic) BJLDrawingShapeType drawingShapeType;

/** 画笔边框颜色 */
@property (nonatomic, nonnull) NSString *strokeColor;

/** 画笔边框颜色透明度，取值范围 0~1 */
@property (nonatomic) CGFloat strokeAlpha;

/** 画笔填充颜色 */
@property (nonatomic, nullable) NSString *fillColor;

/** 画笔填充颜色透明度，取值范围 0~1, fillColor 不为空时有效 */
@property (nonatomic) CGFloat fillAlpha;

/** doodle 画笔线宽 */
@property (nonatomic) CGFloat doodleStrokeWidth;

/** 图形画笔边框线宽 */
@property (nonatomic) CGFloat shapeStrokeWidth;

/** 文字画笔字体大小 */
@property (nonatomic) CGFloat textFontSize;

/** 文字画笔是否加粗 */
@property (nonatomic) BOOL textBold;

/** 文字画笔是否为斜体 */
@property (nonatomic) BOOL textItalic;

/** 画笔开关状态，参考 `drawingGranted`、`updateDrawingEnabled:` */
@property (nonatomic, readonly) BOOL drawingEnabled;

/** doodle 画笔是否虚线 */
@property (nonatomic) BOOL isDottedLine;

/** 选中画笔时是否显示归属信息 */
@property (nonatomic) BOOL showBrushOwnerNameWhenSelected;

/** 是否有选中的画笔 */
@property (nonatomic) BOOL hasSelectedShape;

/**
 开启、关闭画笔
 #param drawingEnabled YES：开启，NO：关闭
 #return BJLError:
 #discussion BJLErrorCode_invalidCalling    错误调用，当前用户是学生、`drawingGranted` 是 NO
 #discussion 开启画笔时，单文档实例情况下如果本地页数与服务端页数不同步则无法绘制
 #discussion `drawingGranted` 是 YES 时才可以开启，`drawingGranted` 是 NO 时会被自动关闭
 */
- (nullable BJLError *)updateDrawingEnabled:(BOOL)drawingEnabled;

/**
 更新画笔操作模式
 #param operateMode 操作模式
 #return BJLError:
 #discussion BJLErrorCode_invalidCalling drawingEnabled 是 NO
 */
- (nullable BJLError *)updateBrushOperateMode:(BJLBrushOperateMode)operateMode;

/**
 添加图片画笔
 #param imageURL 图片 url
 #param relativeFrame 图片相对于画布的 frame, 各项数值取值范围为 [0.0, 1.0]
 #param documentID 目标文档 ID
 #param pageIndex   目标页
 #param isWritingBoard   是否为小黑板
 #return BJLErrorCode_invalidCalling drawingEnabled 是 NO
 */
- (nullable BJLError *)addImageShapeWithURL:(NSString *)imageURL
                              relativeFrame:(CGRect)relativeFrame
                               toDocumentID:(NSString *)documentID
                                  pageIndex:(NSUInteger)pageIndex
                             isWritingBoard:(BOOL)isWritingBoard;

#pragma mark - 画笔授权

/** 学生是否被授权使用画笔 */
@property (nonatomic, readonly) BOOL drawingGranted;

/** 所有被授权使用画笔的学生 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *drawingGrantedUserNumbers;

/**
 老师、助教: 给学生授权/取消画笔
 #param granted     是否授权
 #param userNumber  要操作的用户
 #param color       分配的画笔颜色
 #return BJLError:
 BJLErrorCode_invalidUserRole   当前用户不是老师或者助教
 BJLErrorCode_invalidArguments  参数错误
 */
- (nullable BJLError *)updateDrawingGranted:(BOOL)granted userNumber:(NSString *)userNumber color:(nullable NSString *)color;

#pragma mark - 画笔颜色分配

/** 画笔分配颜色记录 <hex color, user.number> */
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> *drawingGrantedColors;

/** 是否不使用分配的画笔颜色 */
@property (nonatomic) BOOL shouldRejectColorGranted;

/**
 删除 drawingGrantedColors 中某一位学生的画笔颜色分配记录
 #param userNumber 用户 number
 #return BJLError
 */
- (nullable BJLError *)deleteColorRecordWithUserNumber:(NSString *)userNumber;

#pragma mark - 小黑板

/** 小黑板画笔开关状态 */
@property (nonatomic, readonly) BOOL writingBoardEnabled;

/**
 开启/关闭小黑板画笔
 #param writingBoardEnabled 是否开启小黑板画笔
 */
- (void)updateWritingBoardEnabled:(BOOL)writingBoardEnabled;

/**
 清空小黑板上所有作答用户的画笔
 #param boardID          画笔所在文档的ID
 #param pageIndex        画笔所在文档的页码
 */
- (nullable BJLError *)clearStudentShapesOnWritingBoard:(NSString *)boardID pageIndex:(NSUInteger)pageIndex;

#pragma mark - 激光笔

/**
 大班课文档区域是否绘制激光笔
 默认绘制，为圆点样式，将不回调激光笔位置等监听，并且设置画笔模式为激光笔时不会主动触发激光笔；
 如果设置为不绘制，需要自行实现激光笔效果
 专业小班课不支持设置，默认不自动绘制
 已废弃，全部由外部绘制，始终为 NO
 */
@property (nonatomic) BOOL drawsLaserPointer DEPRECATED_MSG_ATTRIBUTE("unable to use");

/**
 激光笔位置移动请求
 #param location         激光笔目标位置
 #param documentID       激光笔所在文档的 ID
 #param pageIndex        激光笔所在文档页码
 */
- (nullable BJLError *)moveLaserPointToLocation:(CGPoint)location
                                     documentID:(nonnull NSString *)documentID
                                      pageIndex:(NSUInteger)pageIndex;

/**
 激光笔位置移动监听
 #param location         激光笔位置
 #param documentID       激光笔所在文档的 ID
 #param pageIndex        激光笔所在文档页码
 */
- (BJLObservable)didLaserPointMoveToLocation:(CGPoint)location
                                  documentID:(NSString *)documentID
                                   pageIndex:(NSUInteger)pageIndex;

#pragma mark - 手写板连接

/** 当前蓝牙是否可用 */
@property (nonatomic, readonly) BOOL isValiableBluetooth DEPRECATED_MSG_ATTRIBUTE("use checkBluetoothAvailable: instead");

/** 当前连接的手写板 */
@property (nonatomic, readonly, nullable) CBPeripheral *connectedHandWritingBoard;

/** 当前所有可用的手写板，需要开启搜索后的结果有效 */
@property (nonatomic, readonly, nullable) NSArray<CBPeripheral *> *availableHandWritingBoards;

/** 是否正在连接手写板 */
@property (nonatomic, readonly) BOOL isConnectingHandWritingBoard;

/** 蓝牙搜索回调了相同设备 */
@property (nonatomic, readonly) BOOL scanfindSameDevice;

/** 当前连接手写板进入休眠 */
@property (nonatomic, readonly) BOOL connectedDeviceSleep;

- (void)checkBluetoothAvailable:(void (^_Nullable)(BOOL available))completion;

/** 搜索手写板 */
- (void)scanHandWritingBoard;

/** 停止手写板搜索 */
- (void)stopScanHandWritingBoard;

/**
 连接手写板
 #param handWritingBoard 手写板
 */
- (void)connectHandWritingBoard:(CBPeripheral *)handWritingBoard;

/** 断开手写板连接 */
- (void)disconnectHandWritingBoard;

/** 手写板设备连接失败 */
- (BJLObservable)handWritingBoardDidConnectFailed:(CBPeripheral *)handWritingBoard;

#pragma mark - 手写板数据设置以及回调

/**
 手写板操作回调翻页
 #discussion nextPage YES 为下页，NO 为上页
 */
@property (nonatomic, nullable) void (^requestChangeFocusPageCallback)(BOOL nextPage);

/**
 设置顶部的绘制视图，仅小班课需要设置，未设置时为 `BJLDocumentVM` 的 `blackboardViewController`
 #param 顶部视图，作为手写板的数据的基准视图
 */
- (void)updateTopDrawingController:(UIViewController *)topDrawingController;

/**
 设置手写板画笔落笔前位置的第一响应文档，仅小班课需要处理，大班课始终是直播间当前文档和页码才能响应
 #discussion point 在设置的 topDrawingController 的位置
 #discussion 返回的控制器必须是满足 BJLSlideshowUI 或者 BJLBlackboardUI 协议的文档控制器
 */
@property (nonatomic, nullable) UIViewController * (^requestFirstRespondDocumentCallback)(CGPoint point);

/**
 手写板画笔位置移动回调
 #discussion 使用选择、画笔、橡皮工具时回调，基于调用 `updateTopDrawingController:` 方法设置的顶部视图
 #discussion 以及绘制时的点请求回调 `requestFirstRespondDocumentCallback` 获取到的画笔将绘制到的视图
 #discussion 对于黑板，回调的位置是基于黑板视图的尺寸计算
 #discussion 对于文档，回调的位置基于文档的 `imageFrameInPPTView` 的数值
 @param location [0,1] 区间内的坐标
 @param documentID 作为所在课件 ID
 @param pageIndex 课件页码
 */
- (BJLObservable)didHandWritingBoardPointMoveToLocation:(CGPoint)location
                                             documentID:(NSString *)documentID
                                              pageIndex:(NSUInteger)pageIndex;

#pragma mark - 画笔位置

/**
 BJLDrawingShapeType_doodle 类型的画笔移动位置回调
 #param location         画笔位置，[0, 1] 区间内的坐标
 #param documentID       画笔所在文档的 ID
 #param pageIndex        画笔所在文档页码
 #param color            画笔颜色
 */
- (BJLObservable)didPaintPointMoveToLocation:(CGPoint)location
                                  documentID:(NSString *)documentID
                                   pageIndex:(NSUInteger)pageIndex
                                       color:(nullable UIColor *)color;
- (BJLObservable)didPaintPointMoveToLocation:(CGPoint)location
                                  documentID:(NSString *)documentID
                                   pageIndex:(NSUInteger)pageIndex
                                       color:(nullable UIColor *)color
                             fromCurrentUser:(BOOL)fromCurrentUser;

/**
 落笔位置点同步
 #param location         画笔位置，[0, 1] 区间内的坐标
 #param documentID       画笔所在文档的 ID
 #param pageIndex        画笔所在文档页码
 */
- (BJLObservable)didMousePointMoveToLocation:(CGPoint)location
                                  documentID:(NSString *)documentID
                                   pageIndex:(NSUInteger)pageIndex;
- (BJLObservable)didMousePointMoveToLocation:(CGPoint)location
                                  documentID:(NSString *)documentID
                                   pageIndex:(NSUInteger)pageIndex
                                       color:(nullable UIColor *)color;

#pragma mark - 画笔文件

/**
 请求绘制画笔文件
 #param fileID 文件 ID
 #param ratio 黑板比例
 #return BJLError 仅老师或者助教能打开，仅支持专业小班课
 */
- (nullable BJLError *)requestPaintOnBlackboardWithFileID:(NSString *)fileID blackboardRatio:(CGFloat)ratio;

/**
 画笔文件绘制
 #param error 打开文件失败时返回错误
 */
- (BJLObservable)didFilePaintOnBlackboard:(nullable BJLError *)error;

@end

NS_ASSUME_NONNULL_END
