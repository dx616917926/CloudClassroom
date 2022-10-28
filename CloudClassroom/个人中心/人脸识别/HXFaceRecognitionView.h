//
//  HXFaceRecognitionView.h
//  CloudClassroom
//
//  Created by mac on 2022/9/14.
//

#import <UIKit/UIKit.h>
#import "HXFaceConfigObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HXFaceRecognitionStatusSimulate=1,   //模拟刷脸
    HXFaceRecognitionStatusStart,      //学前刷脸
    HXFaceRecognitionStatusExam,       //考试中刷脸
    HXFaceRecognitionStatusEndExam,    //考试交卷前刷脸
} HXFaceRecognitionStatus;


//识别状态
typedef enum : NSUInteger {
    CommonStatus,//自定义提示文本
    PoseStatus,//请正对摄像头
    OcclusionStatus,//脸部有遮挡
    SuccessStatus,//成功
    FailStatus,//失败
    Timeout//超时
} WarningStatus;

typedef void (^HXFaceRecognitionViewSuccessBlock)(void);
typedef void (^HXFaceRecognitionViewNeedUploadPhotoBlock)(void);

@interface HXFaceRecognitionView : UIView

///当前考试状态
@property(nonatomic, assign) HXFaceRecognitionStatus status;
///人脸识别和采集的相关参数
@property(nonatomic, strong) HXFaceConfigObject *faceConfig;



@property(nonatomic, copy) HXFaceRecognitionViewSuccessBlock successBlack; //采集成功回调
@property(nonatomic, copy) HXFaceRecognitionViewNeedUploadPhotoBlock uploadPhotoBlack; //上传证件照回调

///弹出
- (void)showInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
