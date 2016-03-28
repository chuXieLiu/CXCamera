//
//  CXCameraManager.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+CXExtension.h"

// 是否正在调整曝光属性
static NSString *kCXCameraAdjustingExposureKey = @"adjustingExposure";

static NSString *kCXCAmeraAdjustingExposureContext;

@interface CXCameraManager ()
<
    AVCaptureFileOutputRecordingDelegate
>

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

@property (nonatomic,strong) NSURL *movieOutputURL;


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
        // 锁定设备进行配置
        if ([device lockForConfiguration:&error]) {
            // 为设备设置对焦点
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            // 释放锁定
            [device unlockForConfiguration];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                [_delegate cameraConfigurateFailed:error];
            }
        }
    }
}

/**
 *  点击锁定焦点和曝光区域
 */
- (void)exposeAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = _videoInput.device;
    // 设备是否只对对焦与自动对焦
    if (device.isExposurePointOfInterestSupported &&
        [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            // 曝光点
            device.exposurePointOfInterest = point;
            // 设置为自动曝光模式
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            // 设备是否支持锁定曝光
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                // 观察是否正在调整曝光属性的变化
                [device addObserver:self
                         forKeyPath:kCXCameraAdjustingExposureKey
                            options:NSKeyValueObservingOptionNew
                            context:&kCXCAmeraAdjustingExposureContext];
                [device unlockForConfiguration];
            } else {
                if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                    [_delegate cameraConfigurateFailed:error];
                }
            }
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == &kCXCAmeraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        // 设备是否不再调整曝光等级
        if (!device.isAdjustingExposure &&
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [device removeObserver:self
                        forKeyPath:kCXCameraAdjustingExposureKey
                           context:&kCXCAmeraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{    // 将exposureMode的更改添加到下一个事件循环，让移除监听得以执行
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    // 曝光锁定
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                        [_delegate cameraConfigurateFailed:error];
                    }
                }
            });
        } else {
            [super observeValueForKeyPath:keyPath
                                 ofObject:object
                                   change:change
                                  context:context];
        }
    }
}

/**
 *  切换连续对焦和曝光模式
 */
- (void)resetFocusAndExposure
{
    AVCaptureDevice *device = _videoInput.device;
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        
        // 中心点，相机以左上角（0，0）为原点，右下角（1，1）为终点
        CGPoint center = CGPointMake(0.5f, 0.5f);
        
        // 是否支持连续自动对焦
        BOOL canFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
        if (canFocus) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            device.focusPointOfInterest = center;
        }
        
        // 是否支持连续自动曝光
        BOOL canExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
        if (canExposure) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            device.exposurePointOfInterest = center;
        }
        
        [device unlockForConfiguration];
    } else {
        if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
            [_delegate cameraConfigurateFailed:error];
        }
    }
}

/**
 *  是否已设置闪光灯
 */
- (BOOL)cameraHasflash
{
    return [_videoInput.device hasFlash];
}

/**
 *  设置闪光灯
 */
- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = _videoInput.device;
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                [_delegate cameraConfigurateFailed:error];
            }
        }
    }
}

/**
 *  是否已开启了手电筒
 */
- (BOOL)cameraHasTorch
{
    return [_videoInput.device hasTorch];
}

/**
 *  当前的手电筒模式
 */
- (AVCaptureTorchMode)torchMode
{
    return _videoInput.device.torchMode;
}

/**
 *  设置手电筒模式
 */
- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = _videoInput.device;
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                [_delegate cameraConfigurateFailed:error];
            }
        }
    }
}



/**
 *  捕捉静态图片
 */
- (void)captureStillImage
{
    // 建立输入和输出连接
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    // 确定连接是否支持设备方向
    if ([connection isVideoOrientationSupported]) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection
    completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            [self saveImageToLibrary:image];
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

/**
 *  是否正在录制视频
 */
- (BOOL)isRecording
{
    return _movieOutput.isRecording;
}

/**
 *  开始录制视频
 */
- (void)startRecording
{
    if (![self isRecording]) {

        AVCaptureConnection *videoConnection = [_movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        AVCaptureDevice *device = _videoInput.device;
        
#pragma mark - 第一次调用摄像头会闪动
        
        // 支持视频稳定捕捉
        if ([device.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]) {
            NSString *version = [UIDevice currentDevice].systemVersion;
            if ([version integerValue] >= 8.0) {
                videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
                
            } else {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                
                videoConnection.enablesVideoStabilizationWhenAvailable = YES;
                
#pragma clang diagnostic pop
            }

        }
        
        
        // 支持平滑对焦
        if (device.isSmoothAutoFocusSupported) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                if ([_delegate respondsToSelector:@selector(cameraConfigurateFailed:)]) {
                    [_delegate cameraConfigurateFailed:error];
                }
            }
        }
        
        
        
        _movieOutputURL = [self uniqueMovieOutputURL];
        [_movieOutput startRecordingToOutputFileURL:_movieOutputURL
                                  recordingDelegate:self];

    }
}

- (NSURL *)uniqueMovieOutputURL
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    // 获取唯一临时路径@“XXXXXX”为固定格式
    NSString *mkdTemplate = [@"cxcamera.XXXXXX" appendTempPath];
    // 获取c字符
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    NSString *dirPath = nil;
    // mktemp()用来产生唯一的临时文件名. 参数template 所指的文件名称字符串中最后六个字符必须是XXXXXX. 产生后的文件名会借字符串指针返回
    char *result = mkdtemp(buffer);
    if (result) {
        dirPath = [fileManger stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    free(buffer);
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"camera_movie.mov"];
       return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}



/**
 *  结束录制视频
 */
- (void)stopRecording
{
    if ([self isRecording]) {
        [_movieOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error) {
        if ([_delegate respondsToSelector:@selector(mediaCaptureFailed:)]) {
            [_delegate mediaCaptureFailed:error];
        }
    } else {
        [self saveVideoToLibrary:[_movieOutputURL copy]];
    }
    _movieOutputURL = nil;
}



- (AVCaptureVideoOrientation)currentVideoOrientation
{
    /*
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     
     */
    /*AVCaptureVideoOrientationPortrait           = 1,
     AVCaptureVideoOrientationPortraitUpsideDown = 2,
     AVCaptureVideoOrientationLandscapeRight     = 3, Indicates that video should be oriented horizontally, home button on the right
     AVCaptureVideoOrientationLandscapeLeft      = 4, Indicates that video should be oriented horizontally, home button on the left.
     */
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
    return orientation;
}

- (void)saveImageToLibrary:(UIImage *)image
{
    if ([self authorizeAssetsLibrary]) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                  orientation:(NSInteger)image.imageOrientation
        completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                NSLog(@"%@",image);
            } else {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
    }
}

- (void)saveVideoToLibrary:(NSURL *)movieURL
{
    if ([self authorizeAssetsLibrary]) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // 检查视频是否可以写入
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL]) {
            NSLog(@"%@",movieURL);
//            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                if (error) {
//                    if ([_delegate respondsToSelector:@selector(mediaCaptureFailed:)]) {
//                        [_delegate mediaCaptureFailed:error];
//                    }
//                } else {
//                    
//                }
//            }];
        }
    }
}

- (void)generateThumbImageWithMovieURL:(NSURL *)movieURL
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:movieURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        // 自动调整视频的矩阵变化（如视频方向的变化）
        imageGenerator.appliesPreferredTrackTransform = YES;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",image);
        });
        
    });
}


- (BOOL)authorizeAssetsLibrary
{
    if (NSClassFromString(@"PHAsset")) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            return NO;
        } else {
            return YES;
        }
    } else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
            return NO;
        } else {
            return YES;
        }
    }
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
