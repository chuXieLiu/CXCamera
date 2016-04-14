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
static NSString *kCXCameraDeviceInputPropertyAdjustingExposure = @"adjustingExposure";

// 缩放值属性
static NSString *KCXCameraDeviceInputPropertyVideoZoomFactor = @"videoZoomFactor";

// 是否正在调整缩放值
static NSString *KCXCameraDeviceInputPropertyRampingVideoZoom = @"rampingVideoZoom";

// 最大缩放值
static const CGFloat kCXCameraMaxZoomValue = 4.0f;

static NSString *kCXCameraAdjustingExposureContext;

static NSString *kCXCameraVideoZoomFactorContext;

static NSString *kCXCameraRampingVideoZoomContext;

@interface CXCameraManager ()
<
    AVCaptureFileOutputRecordingDelegate
>

@property (nonatomic,assign) CXDeviceMode deviceMode;
/** 会话 */
@property (nonatomic,strong) AVCaptureSession *session;
/** 视频捕捉 */
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
/** 音频捕捉 */
@property (nonatomic,strong) AVCaptureDeviceInput *audioInput;
/** 捕捉静态图片 */
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;
/** 将video写入到文件系统 */
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieOutput;
/** video文件路径 */
@property (nonatomic,strong) NSURL *movieOutputURL;
/** session是否配置成功 */
@property (nonatomic,assign) BOOL sessionConfigurateSuccess;

@end


@implementation CXCameraManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSError *error;
        if ([self configurateSessionWithError:&error]) {
            _sessionConfigurateSuccess = YES;
            _deviceMode = CXDeviceModeBack;
        } else {
            if ([_delegate respondsToSelector:@selector(captureSessionConfigurateError:)]) {
                [_delegate captureSessionConfigurateError:error];
            }
            _sessionConfigurateSuccess = NO;
        }
    }
    return self;
}

#pragma mark - 会话

/**
 *  创建会话，捕捉场景活动
 */
- (BOOL)configurateSessionWithError:(NSError **)error
{
    // 创建会话，会话是捕捉场景活动的中心枢纽
    _session = [[AVCaptureSession alloc] init];
    
    // 为会话配置预设值
    _session.sessionPreset = AVCaptureSessionPresetHigh;
//    _session.sessionPreset = AVCaptureSessionPreset640x480;
    
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
    
    [self addZoomFactorObserver];
    
    [self addAreaChangeMonitor];
    
    return YES;
}

/**
 *  启动会话
 */
- (void)startSession
{
    if (!_sessionConfigurateSuccess) return;
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
    if (!_sessionConfigurateSuccess) return;
    if ([_session isRunning]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_session stopRunning];
        });
    }
}

#pragma mark - 摄像头

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
            
            // 切换到前置摄像机的时候移除监听
            if (_videoInput.device.position == AVCaptureDevicePositionBack) {
                [self removeZoomFactorObserver];    // 移除旧的
            }
            
            _videoInput = videoInput;   // 覆盖旧的
            
            if (_videoInput.device.position == AVCaptureDevicePositionBack) {
                [self addZoomFactorObserver];   // 为新的添加
            }

        } else {
            [_session addInput:_videoInput];
        }
    
        // 配置完成，系统会分批整合所有变更
        [_session commitConfiguration];

    } else {
        if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
            [_delegate cameraManagerConfigurateFailed:error];
        }
        return NO;
    }
    
    if ([self cameraHasTorch]) {   // 前置摄像头不支持手电筒模式
        _deviceMode = CXDeviceModeBack;
    } else {
        _deviceMode = CXDeviceModeFront;
        
    }
    
    return YES;
}

#pragma mark - 对焦与曝光

- (BOOL)isCameraFocusSupported
{
    return _videoInput.device.isFocusPointOfInterestSupported;
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
            if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                [_delegate cameraManagerConfigurateFailed:error];
            }
        }
    }
}

- (BOOL)isCameraExposureSupported
{
    return _videoInput.device.isExposurePointOfInterestSupported;
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
                         forKeyPath:kCXCameraDeviceInputPropertyAdjustingExposure
                            options:NSKeyValueObservingOptionNew
                            context:&kCXCameraAdjustingExposureContext];
                
                [device unlockForConfiguration];
            } else {
                if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                    [_delegate cameraManagerConfigurateFailed:error];
                }
            }
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if (context == &kCXCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        // 设备是否不再调整曝光等级
        if (!device.isAdjustingExposure &&
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:kCXCameraDeviceInputPropertyAdjustingExposure
                           context:&kCXCameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{    // 将exposureMode的更改添加到下一个事件循环，让移除监听得以执行
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    // 曝光锁定
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                        [_delegate cameraManagerConfigurateFailed:error];
                    }
                }
            });
        }
    } else if (context == &kCXCameraVideoZoomFactorContext) {
        [self updateZoomValue];
    } else if (context == &kCXCameraRampingVideoZoomContext) {
        if (_videoInput.device.isRampingVideoZoom) {
            [self updateZoomValue];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)updateZoomValue
{
    CGFloat currentZoomFactor = _videoInput.device.videoZoomFactor;
    CGFloat maxZoomFactor = [self maxZoomFactor];
    CGFloat value = log(currentZoomFactor) / log(maxZoomFactor);
    if ([_delegate respondsToSelector:@selector(cameraRampZoomToValue:)]) {
        [_delegate cameraRampZoomToValue:value];
    }
}

/**
 *  连续对焦和曝光模式
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
        if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
            [_delegate cameraManagerConfigurateFailed:error];
        }
    }
}

/**
 *  是否能设置闪光灯
 */
- (BOOL)cameraHasFlash
{
    return [_videoInput.device hasFlash];
}

/**
 *  设置闪光灯
 */
- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    // 如果已开启手电筒模式要先关闭
    if ([self torchMode] == AVCaptureTorchModeOn) {
        if ([self cameraHasTorch]) {
            [self setTorchMode:AVCaptureTorchModeOff];
        }
    }
    
    AVCaptureDevice *device = _videoInput.device;
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                [_delegate cameraManagerConfigurateFailed:error];
            }
        }
    }
}

/**
 *  是否可以开启手电筒模式
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
            if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                [_delegate cameraManagerConfigurateFailed:error];
            }
        }
    }
}

- (void)setAutoFocusAndExpose:(BOOL)autoFocusAndExpose
{
    _autoFocusAndExpose = autoFocusAndExpose;
    AVCaptureDevice *videoDevice = self.videoInput.device;
    if ([videoDevice lockForConfiguration:NULL]) {
        videoDevice.subjectAreaChangeMonitoringEnabled = autoFocusAndExpose;
        [videoDevice unlockForConfiguration];
    }
}

#pragma mark - 缩放

- (BOOL)isCameraZoomSupported
{
    // 大于1值表示支持缩放
    return _videoInput.device.activeFormat.videoMaxZoomFactor > 1.0f;
}

- (CGFloat)maxZoomFactor
{
    // 如果太大的缩放值会抛出异常
    return MIN(_videoInput.device.activeFormat.videoMaxZoomFactor, kCXCameraMaxZoomValue);
}

- (void)setZoomValue:(CGFloat)zoomValue
{
    AVCaptureDevice *device = _videoInput.device;
    if (!device.isRampingVideoZoom) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            // 缩放系数zoomValue为0-1
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
            device.videoZoomFactor = zoomFactor;
            [device unlockForConfiguration];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                [_delegate cameraManagerConfigurateFailed:error];
            }
        }
    }
}

- (void)rampZoomToValue:(CGFloat)zoomValue
{
    AVCaptureDevice *device = _videoInput.device;
    CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        // rate: zoom factor is continuously scaled by pow(2,rate * time),double every second,每秒增加缩放因子一倍
        [device rampToVideoZoomFactor:zoomFactor withRate:1.0f];
        [device unlockForConfiguration];
    } else {
        if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
            [_delegate cameraManagerConfigurateFailed:error];
        }
    }
}

- (void)cancelZoom
{
    NSError *error;
    AVCaptureDevice *device = _videoInput.device;
    if ([device lockForConfiguration:&error]) {
        /*
         This method is equivalent to calling rampToVideoZoomFactor:withRate: using the current zoom factor
         target and a rate of 0.  This allows a smooth stop to any changes in zoom which were in progress.
         */
        // 平稳的用当前的缩放值设置
        [device cancelVideoZoomRamp];
        [device unlockForConfiguration];
    } else {
        if ([_delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
            [_delegate cameraManagerConfigurateFailed:error];
        }
    }
}

#pragma mark - 缩放监听

- (void)addZoomFactorObserver
{
    // 监听缩放值
    [_videoInput.device addObserver:self
                         forKeyPath:KCXCameraDeviceInputPropertyVideoZoomFactor
                            options:NSKeyValueObservingOptionNew
                            context:&kCXCameraVideoZoomFactorContext];
    [_videoInput.device addObserver:self
                         forKeyPath:KCXCameraDeviceInputPropertyRampingVideoZoom
                            options:NSKeyValueObservingOptionNew
                            context:&kCXCameraRampingVideoZoomContext];
}

- (void)removeZoomFactorObserver
{
    if (_deviceMode == CXDeviceModeBack) {
        [_videoInput.device removeObserver:self
                                forKeyPath:KCXCameraDeviceInputPropertyVideoZoomFactor
                                   context:&kCXCameraVideoZoomFactorContext];
        
        [_videoInput.device removeObserver:self
                                forKeyPath:KCXCameraDeviceInputPropertyRampingVideoZoom
                                   context:&kCXCameraRampingVideoZoomContext];
    }
}

- (void)addAreaChangeMonitor
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceSubjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}

- (void)deviceSubjectAreaDidChange:(NSNotification *)note
{
    if (self.autoFocusAndExpose) {
        if ([self.delegate respondsToSelector:@selector(captureDeviceSubjectAreaDidChange)]) {
            [self.delegate captureDeviceSubjectAreaDidChange];
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
    if ([self.delegate respondsToSelector:@selector(cameraManagerWillCaptureStillImage)]) {
        [self.delegate cameraManagerWillCaptureStillImage];
    }
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection
    completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            [self callBackCaptureStillImage:image error:nil];
        } else {
            [self callBackCaptureStillImage:nil error:error];
        }
    }];
}

- (void)callBackCaptureStillImage:(UIImage *)image error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(cameraManagerDidEndCaptureStillImage:error:)]) {
        [_delegate cameraManagerDidEndCaptureStillImage:image error:error];
    }
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

        AVCaptureConnection *videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        AVCaptureDevice *device = self.videoInput.device;
        
#pragma mark - 设置防抖模式时第一次配置摄像头会闪蓝光
        // 支持视频稳定捕捉
        if ([device.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]) {
            NSString *version = [UIDevice currentDevice].systemVersion;
            if ([version integerValue] >= 8.0) {
                videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeOff;
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
                if ([self.delegate respondsToSelector:@selector(cameraManagerConfigurateFailed:)]) {
                    [self.delegate cameraManagerConfigurateFailed:error];
                }
            }
        }
        
        self.movieOutputURL = [self uniqueMovieOutputURL];
        self.movieOutput.maxRecordedDuration = CMTimeMake(self.maxRecordedDuration, 1);
        [self.movieOutput startRecordingToOutputFileURL:_movieOutputURL
                                  recordingDelegate:self];

    }

}


- (NSURL *)uniqueMovieOutputURL
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    // 获取唯一临时路径@“XXXXXX”为固定格式
    NSString *mkdTemplate = [@"cxcamera.XXXXXX" appendTempPath];
    // 获取字符
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


/**
 * 录制时长
 */
- (NSTimeInterval)recordedDuration
{
    CMTime time = _movieOutput.recordedDuration;
    return time.value / time.timescale;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    if ([self.delegate respondsToSelector:@selector(cameraManagerDidStartReocrdingVideo:)]) {
        [self.delegate cameraManagerDidStartReocrdingVideo:[_movieOutputURL copy]];
    }
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (!error) {
        [self callBackEndRecordedWithError:nil];
    } else {
        BOOL success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
        if (success) {
            if ([self.delegate respondsToSelector:@selector(cameraManagerDidReachMaxReocrdedDuration:)]) {
                [self.delegate cameraManagerDidReachMaxReocrdedDuration:[_movieOutputURL copy]];
            }
        } else {
            [self callBackEndRecordedWithError:error];
        }
    }
    _movieOutputURL = nil;
}


- (void)callBackEndRecordedWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(cameraManagerDidEndReocrdedVideo:error:)]) {
        [_delegate cameraManagerDidEndReocrdedVideo:[_movieOutputURL copy] error:error];
    }
}


- (AVCaptureVideoOrientation)currentVideoOrientation
{
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
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        default:
            break;
    }
    return orientation;
}


#pragma mark - 捕捉

- (void)writeImageToPhotosAlbum:(UIImage *)image completionBlock:(void (^)(NSURL *, NSError *))completionBlock
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage
                              orientation:(NSInteger)image.imageOrientation
      completionBlock:^(NSURL *assetURL, NSError *error) {
          !completionBlock ? : completionBlock(assetURL,error);
      }];
}

- (void)writeVideoToPhotosAlbumAtPath:(NSURL *)movieURL completionBlock:(void (^)(NSURL *, NSError *))completionBlock
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // 检查视频是否可以写入
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
            !completionBlock ? : completionBlock(assetURL,error);
        }];
    } else {
        !completionBlock ? : completionBlock(nil,[[NSError alloc] init]);
    }
}

#pragma mark - private method

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

- (void)dealloc
{
    [self removeZoomFactorObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





@end
