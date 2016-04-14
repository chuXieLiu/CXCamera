//
//  CXCameraManager.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CXCommonConst.h"

@protocol CXCameraManagerDelegate <NSObject>

/**
 *  初始化session错误回调
 */
- (void)captureSessionConfigurateError:(NSError *)error;

/**
 *  相机操作配置错误回调
 */
- (void)cameraManagerConfigurateFailed:(NSError *)error;

@optional

/**
 *  即将获取静态图片
 */
- (void)cameraManagerWillCaptureStillImage;

/**
 *  结束获取静态图片
 */
- (void)cameraManagerDidEndCaptureStillImage:(UIImage *)image error:(NSError *)error;

/**
 *  开始录制视频
 */
- (void)cameraManagerDidStartReocrdingVideo:(NSURL *)fileURL;

/**
 *  到达最大录制时间
 */
- (void)cameraManagerDidReachMaxReocrdedDuration:(NSURL *)fileURL;

/**
 *  结束录制视频
 */
- (void)cameraManagerDidEndReocrdedVideo:(NSURL *)fileURL error:(NSError *)error;

/**
 *  缩放值变化回调
 */
- (void)cameraRampZoomToValue:(CGFloat)zoomValue;

/**
 * 相机捕捉范围发送变化
 */
- (void)captureDeviceSubjectAreaDidChange;

@end


@interface CXCameraManager : NSObject

@property (nonatomic,strong,readonly) AVCaptureSession *session;

@property (nonatomic,assign,readonly) CXDeviceMode deviceMode;

@property (nonatomic,assign) CXCameraMode cameraMode;

@property (nonatomic,assign) BOOL autoFocusAndExpose;

@property (nonatomic,assign) NSTimeInterval maxRecordedDuration;

@property (nonatomic,weak) id<CXCameraManagerDelegate> delegate;

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

/**
 *  切换摄像头
 */
- (BOOL)switchCamera;

/**
 *  是否支持对焦
 */
- (BOOL)isCameraFocusSupported;

/**
 *  某个点对焦
 */
- (void)focusAtPoint:(CGPoint)point;

/**
 *  是否支持曝光
 */
- (BOOL)isCameraExposureSupported;

/**
 *  某个点曝光
 */
- (void)exposeAtPoint:(CGPoint)point;

/**
 *  重置对焦和曝光模式
 */
- (void)resetFocusAndExposure;

/**
 *  是否能设置闪光灯
 */
- (BOOL)cameraHasFlash;

/**
 *  设置闪光灯模式
 */
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;

/**
 *  是否可以开启手电筒模式
 */
- (BOOL)cameraHasTorch;

/**
 *  当前手电筒模式
 */
- (AVCaptureTorchMode)torchMode;

/**
 *  设置手电筒模式
 */
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

/**
 *  是否支持缩放
 */
- (BOOL)isCameraZoomSupported;

/**
 *  最大缩放值
 */
- (CGFloat)maxZoomFactor;

/**
 *  设置缩放值
 */
- (void)setZoomValue:(CGFloat)zoomValue;

/**
 *  连续平缓设置一个值
 */
- (void)rampZoomToValue:(CGFloat)zoomValue;

/**
 *  设置缩放值
 */
- (void)cancelZoom;

/**
 *  捕捉静态图片
 */
- (void)captureStillImage;

/**
 *  是否正在录制视频
 */
- (BOOL)isRecording;

/**
 *  开始录制视频
 */
- (void)startRecording;

/**
 *  结束录制视频
 */
- (void)stopRecording;

/**
 *  当前录制时间
 */
- (NSTimeInterval)recordedDuration;

/**
 *  是否允许访问相册
 */
- (BOOL)authorizeAssetsLibrary;

/**
 *  将图片写入相册
 */
- (void)writeImageToPhotosAlbum:(UIImage *)image completionBlock:(void(^)(NSURL *assetURL, NSError *error))completionBlock;

/**
 *  将视频写入相册
 */
- (void)writeVideoToPhotosAlbumAtPath:(NSURL *)movieURL completionBlock:(void (^)(NSURL *assetURL, NSError *error))completionBlock;









@end
