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

@optional

- (void)cameraConfigurateFailed:(NSError *)error;
- (void)mediaCaptureFailed:(NSError *)error;

@end


@interface CXCameraManager : NSObject

/** 会话 */
@property (nonatomic,strong,readonly) AVCaptureSession *session;

@property (nonatomic,weak) id<CXCameraManagerDelegate> delegate;

/**
 *  创建会话，捕捉场景活动
 */
- (BOOL)setupSession:(NSError **)error;

/**
 *  启动会话
 */
- (void)startSession;

/**
 *  停止会话
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
 *  对焦
 */
- (void)focusAtPoint:(CGPoint)point;


/**
 *  点击锁定焦点和曝光区域
 */
- (void)exposeAtPoint:(CGPoint)point;



/**
 *  切换连续对焦和曝光模式
 */
- (void)resetFocusAndExposure;


/**
 *  是否已设置闪光灯
 */
- (BOOL)cameraHasflash;

/**
 *  设置闪光灯
 */
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;

/**
 *  是否已开启了手电筒
 */
- (BOOL)cameraHasTorch;

/**
 *  当前的手电筒模式
 */
- (AVCaptureTorchMode)torchMode;

/**
 *  设置手电筒模式
 */
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

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








@end
