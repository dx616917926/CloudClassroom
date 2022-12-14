//
//  HXFaceRecognitionTool.m
//  CloudClassroom
//
//  Created by mac on 2022/10/27.
//

#import "HXFaceRecognitionTool.h"

@interface HXFaceRecognitionTool ()

@property(nonatomic, strong) UIViewController *parentViewController;

@end

@implementation HXFaceRecognitionTool

//弹出
- (void)showInViewController:(UIViewController *)viewController
{
    self.parentViewController = viewController;
    
    //判断是否需要弹框
    BOOL isShow = self.faceConfig.isFaceMatch;
    
    if (self.faceConfig && isShow) {
        //是否需要弹考试须知
        [self showExamPromiseView];
    }else{
        [self complete];
    }
}


/// 弹出考试须知页面
- (void)showExamPromiseView {
        
    if (self.faceConfig.altertKJ && self.faceConfig.altertKJ.count != 0) {
        HXExamPromiseView *promiseView = [[HXExamPromiseView alloc] init];
        promiseView.alterUrl = self.faceConfig.altertKJ;
        promiseView.showCancelButton = NO;
        promiseView.sureSelectBlock = ^{
            [self showFaceRecognitionView];
        };
        [promiseView showInViewController:self.parentViewController];
    }else{
        //再判断是否需要人脸识别
        [self showFaceRecognitionView];
    }
}


/// 弹出人脸识别页面
- (void)showFaceRecognitionView{
    
    HXFaceRecognitionView *faceView = [[HXFaceRecognitionView alloc] init];
    faceView.faceConfig = self.faceConfig;
    faceView.status = HXFaceRecognitionStatusStart;
    faceView.successBlack = ^{
        [self complete];
    };
    
    faceView.uploadPhotoBlack = ^{
        //打开个人信息页面 上传证件照
        [self.parentViewController.tabBarController setSelectedIndex:2];
        [self.parentViewController.navigationController popToRootViewControllerAnimated:NO];
    };
    
    [faceView showInViewController:self.parentViewController];
}


/// 结束
- (void)complete {
    if (self.successBlack) {
        self.successBlack();
    }
}

@end

