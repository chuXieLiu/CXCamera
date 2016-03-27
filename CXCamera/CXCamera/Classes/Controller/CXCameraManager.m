//
//  CXCameraManager.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraManager.h"
#import <AVFoundation/AVFoundation.h>

@interface CXCameraManager ()

/** 会话 */
@property (nonatomic,strong) AVCaptureSession *session;
/** 视频捕捉 */
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
/** 音频捕捉 */
@property (nonatomic,strong) AVCaptureDeviceInput *audioInput;
/** 捕捉静态图片 */
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;
/** 将电影写入到文件系统 */
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieOutput;

@end


@implementation CXCameraManager


/**
 *  创建会话，捕捉场景活动
 */
- (BOOL)setupSession:(NSError **)error
{
    // 创建会话，会话是捕捉场景活动的中心枢纽
    _session = [[AVCaptureSession alloc] init];
    // 为会话配置预设值
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 创建视频捕捉对象
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (_videoInput) {
        if ([_session canAddInput:_videoInput]) {
            // 将视频捕捉对象添加到会话中
            [_session addInput:_videoInput];
        }
    } else {
        return NO;
    }
    
    // 创建音频捕捉对象
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (_audioInput) {
        if ([_session canAddInput:_audioInput]) {
            [_session addInput:_audioInput];
        }
    } else {
        return NO;
    }
    
    // 创建图片捕捉对象，从摄像头捕捉静态图片
    _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    // 设置捕捉jpeg图片
    _imageOutput.outputSettings = @{
                                   AVVideoCodecKey : AVVideoCodecJPEG
                                   };
    if ([_session canAddOutput:_imageOutput]) {
        [_session addOutput:_imageOutput];
    }
    
    // 创建可将电影写入文件系统对象
    _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([_session canAddOutput:_movieOutput]) {
        [_session addOutput:_movieOutput];
    }

    return YES;
}


/**
 *  启动会话
 */
- (void)startSession
{
    if (![_session isRunning]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_session startRunning];
        });
    }
}

/**
 *  停止会话
 */
- (void)stopSession
{
    if ([_session isRunning]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_session stopRunning];
        });
    }
}


/**
 *  是否支持切换摄像头
 */
- (BOOL)canSwitchCamera
{
    return [self cameraCount] > 1;
}

/**
 *  切换摄像头
 *  切换摄像头需要重新配置会话
 */
- (BOOL)switchCamera
{
    if (![self canSwitchCamera]) return NO;
    
    // 获取未激活摄像头
    AVCaptureDevice *device = [self inactiveCamera];
    // 生成新的视频捕捉对象
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (videoInput) {
        // 标注原子配置变化开始
        [_session beginConfiguration];
    
        // 移除旧的视频捕捉对象
        [_session removeInput:_videoInput];
    
        // 添加新的视频捕捉对象
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
            _videoInput = videoInput;
        } else {
            [_session addInput:_videoInput];
        }
    
    // 配置完成，系统会分批整合所有变更
        [_session commitConfiguration];
    } else {
        if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
            [_delegate cameraConfigurateFailed:error];
        }
        return NO;
    }
    
    return YES;
}

/**
 *  对焦
 */
- (void)focusAtPoint:(CGPoint)point
{
    // 是否支持对焦与自动对焦
    AVCaptureDevice *device = _videoInput.device;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            // 为设备设置对焦点
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                [_delegate cameraConfigurateFailed:error];
            }
        }
    }
    // 锁定设备进行配置
    
    // 释放锁定
}


#pragma mark - private method

- (NSUInteger)cameraCount
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

- (AVCaptureDevice *)inactiveCamera
{
    if ([self cameraCount] > 1) {
        if (_videoInput.device.position == AVCaptureDevicePositionBack) {
            return  [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            return [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return nil;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}








@end
