//
//  CXCameraViewController.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCommonConst.h"

@class CXCameraViewController;

@protocol CXCameraViewControllerDelegate <NSObject>

@optional

/// 没有权限访问
- (void)cameraNoAccessForMedia;

/// 相机配置错误
- (void)cameraDidConfigurateError:(NSError *)error;

/// 捕捉图片，image可能为空
- (void)cameraViewController:(CXCameraViewController *)cameraVC didCaptureImage:(UIImage *)image;

/// 捕捉图片，video可能为空
- (void)cameraViewController:(CXCameraViewController *)cameraVC didCaptureVideo:(NSURL *)videoURL;

/// 自动保存图片结果
- (void)cameraViewController:(CXCameraViewController *)cameraVC saveImage:(UIImage *)image isSuccessed:(BOOL)isSuccessed;

/// 自动保存视频结果
- (void)cameraViewController:(CXCameraViewController *)cameraVC saveVideo:(NSURL *)videoURL isSuccessed:(BOOL)isSuccessed;

@end


@interface CXCameraViewController : UIViewController

/// 相机类型 CXCameraModePhoto  / CXCameraModeVideo
@property (nonatomic,assign) CXCameraMode cameraMode;

/// 是否自动写入相册 , 默认为NO
@property (nonatomic,assign) BOOL automaticWriteToLibary;

/// 相机代理
@property (nonatomic,weak) id<CXCameraViewControllerDelegate> delegate;



/// present一个相机控制器
+ (instancetype)showCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                            cameraMode:(CXCameraMode)cameraMode
                automaticWriteToLibary:(BOOL)automaticWriteToLibary;












@end
