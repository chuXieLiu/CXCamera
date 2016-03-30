//
//  CXCameraManager.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CXCameraManagerDelegate <NSObject>

// 初始化session错误
- (void)captureSessionConfigurateError:(NSError *)error;
// 相机操作配置
- (void)cameraManagerConfigurateFailed:(NSError *)error;

@optional

// 获取静态图片
- (void)cameraManagerDidSuccessedCapturedStillImage:(UIImage *)image;
- (void)cameraManagerDidFailedCapturedStillImage:(NSError *)error;

// 录制视频
- (void)cameraManagerDidSuccessedReocrdedVideo:(NSURL *)fileURL recordedDuration:(NSTimeInterval)duration;
- (void)cameraManagerDidFailedReocrdedVideo:(NSError *)error;

// 写入系统库，media可能是UIImage对象，也可能是video的路径
- (void)cameraManagerToSavedPhotosAlbumSuccessed:(id)media;
- (void)cameraManagerToSavedPhotosAlbumFailed:(id)media error:(NSError *)error;



@end


@interface CXCameraManager : NSObject

@property (nonatomic,weak) id<CXCameraManagerDelegate> delegate;

// 会话
@property (nonatomic,strong,readonly) AVCaptureSession *session;
// 自动写入资源
@property (nonatomic,assign) BOOL automaticWriteToLibary;

/**
 *  开启会话
 */
- (void)startSession;
/**
 *  结束会话
 */
- (void)stopSession;


/**
 *  是否支持切换摄像头
 */
- (BOOL)canSwitchCamera;
- (BOOL)switchCamera;


/**
 *  对焦
 */
- (void)focusAtPoint:(CGPoint)point;

/**
 *  点击锁定焦点和曝光区域
 */
- (void)exposeAtPoint:(CGPoint)point;

/**
 *  重置连续对焦和曝光模式
 */
- (void)resetFocusAndExposure;


/**
 *  是否已设置闪光灯
 */
- (BOOL)cameraHasflash;
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;

/**
 *  是否已开启了手电筒模式
 */
- (BOOL)cameraHasTorch;
- (AVCaptureTorchMode)torchMode;
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;


/**
 *  捕捉静态图片
 */
- (void)captureStillImage;

- (BOOL)isRecording;
- (void)startRecording;
- (void)stopRecording;
- (NSTimeInterval)recordedDuration;


/**
 *  是否允许访问相册
 */
- (BOOL)authorizeAssetsLibrary;



@end
