//
//  CXCameraViewController.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraViewController.h"
#import "CXCameraManager.h"
#import "CXPreviewView.h"
#import "CXOverlayView.h"
#import "CXPhotoEditView.h"
#import "CXVideoEditView.h"
#import "UIView+CXExtension.h"
#import "NSTimer+CXExtension.h"

// 隐藏缩放条时间
static const CGFloat kCXCameraHidenZoomSliderTimeInterval = 3.0f;

// 定时器获取录制时间间隔
static const CGFloat kCXCameraRecordingTimeInterval = 0.5f;

@interface CXCameraViewController ()
<
    CXCameraManagerDelegate,
    CXPreviewViewDelegate,
    CXOverLayViewDelegate
>

@property (nonatomic,strong) CXCameraManager *cameraManager;

@property (nonatomic,weak) CXPreviewView *previewView;

@property (nonatomic,weak) CXOverlayView *overlayView;

@property (nonatomic,strong) NSTimer *zoomSliderTimer;

@property (nonatomic,strong) NSTimer *recordingTimer;

@property (nonatomic,weak) CXPhotoEditView *photoEditView;

@property (nonatomic,weak) CXVideoEditView *videoEditView;

@property (nonatomic,assign) BOOL lastAutoFocusAndExpose;

@end


@implementation CXCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPreviewView];
    [self setupOverlayView];
    [self setupSession];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopZoomSliderTimer];
    [self stopRecordingTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.autoFocusAndExpose) {
        [self.cameraManager resetFocusAndExposure];
        [self.previewView autoFocusAndExposure];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark - CXPreviewViewDelegate

- (void)previewView:(CXPreviewView *)preivewView singleTapAtPoint:(CGPoint)point
{
    [self.cameraManager exposeAtPoint:point];
}

- (void)previewViewWillBeginPinch:(CXPreviewView *)previewView
{
    [self stopZoomSliderTimer];
    [self.overlayView setZoomSliderHiden:NO];
}

- (void)previewViewDidEndPinch:(CXPreviewView *)previewView
{
    [self startZoomSliderTimer];
}

- (void)previewView:(CXPreviewView *)preivewView pinchScaleValueDidChange:(CGFloat)value
{
    CGFloat zoomValue = MIN([self.overlayView currentZoomValue] + value, 1.0);
    zoomValue = MAX(zoomValue, 0);
    [self.cameraManager setZoomValue:zoomValue];
}

#pragma mark - CXOverLayViewDelegate

- (void)didSelectedShutter:(CXOverlayView *)overlayView
{
    if (self.cameraMode == CXCameraModePhoto) {
        [self.cameraManager captureStillImage];
    } else {
        if ([self.overlayView prepareToRecording]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.cameraManager startRecording];
            });
            // 录像时关闭自动对焦
            self.lastAutoFocusAndExpose = self.autoFocusAndExpose;
            if (self.autoFocusAndExpose) {
                self.cameraManager.autoFocusAndExpose = NO;
            }
        } else {
            [self.cameraManager stopRecording];
            [overlayView setShutterEnable:NO];
            if (self.lastAutoFocusAndExpose) {
                self.cameraManager.autoFocusAndExpose = self.lastAutoFocusAndExpose;
            }
        }
    }
}

- (void)didSelectedCancel:(CXOverlayView *)overlayView
{
    if ([self.cameraManager isRecording]) {
        [self.cameraManager stopRecording];
    }
    [self stopRecordingTimer];
    [self stopZoomSliderTimer];
    [self.cameraManager stopSession];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissCallback];
}

- (void)didSelectedFlashMode:(CXCaptureFlashMode)flashMode
{
    if ([self.cameraManager cameraHasFlash]) {
        switch (flashMode) {
            case CXCaptureFlashModeOn:
                [self.cameraManager setFlashMode:AVCaptureFlashModeOn];
                break;
            case CXCaptureFlashModeOff:
                [self.cameraManager setFlashMode:AVCaptureFlashModeOff];
                break;
            case CXCaptureFlashModeAuto:
                [self.cameraManager setFlashMode:AVCaptureFlashModeAuto];
                break;
            case CXCaptureFlashModeTorch:
                if ([self.cameraManager cameraHasTorch]) {
                    if ([self.cameraManager torchMode] == AVCaptureTorchModeOff) {
                        [self.cameraManager setTorchMode:AVCaptureTorchModeOn];
                    } else {
                        [self.cameraManager setTorchMode:AVCaptureTorchModeOff];
                    }
                }
                break;
            default:
                break;
        }
    }
}

- (void)didSwitchCamera
{
    if ([self.cameraManager switchCamera]) {
        [self.overlayView switchDeviceMode:[self.cameraManager deviceMode]];
        self.previewView.enableExpose = [self.cameraManager isCameraExposureSupported];
        if (self.cameraManager.deviceMode == CXDeviceModeFront) {
            self.previewView.enableZoom = NO;
        } else {
            self.previewView.enableZoom = YES;
        }
    }
}

- (void)didtouchDownToCameraZoomType:(CXCameraZoomType)zoomType
{
    if ([self.cameraManager isCameraZoomSupported]) {
        CGFloat zoom = 0.f;
        if (zoomType == CXCameraZoomTypePlus) {
            zoom = 1.0f;
        }
        [self.cameraManager rampZoomToValue:zoom];
    }
    [self stopZoomSliderTimer];
}

- (void)didTouchUpInsideToCameraZoomType:(CXCameraZoomType)zoomType
{
    if ([self.cameraManager isCameraZoomSupported]) {
        [self.cameraManager cancelZoom];
    }
    [self startZoomSliderTimer];
}

- (void)didTouchDownZoomSliderView:(CXOverlayView *)overlayView
{
    [self stopZoomSliderTimer];
}
- (void)didTouchUpInsideZoomSliderView:(CXOverlayView *)overlayView
{
    [self startZoomSliderTimer];
}

- (void)sliderChangeToValue:(CGFloat)zoomValue
{
    if ([self.cameraManager isCameraZoomSupported]) {
        [self.cameraManager setZoomValue:zoomValue];
    }
}

#pragma mark - CXCameraManagerDelegate

- (void)captureSessionConfigurateError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(cameraDidConfigurateError:)]) {
        [self.delegate cameraDidConfigurateError:error];
    }
}

- (void)cameraManagerConfigurateFailed:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(cameraDidConfigurateError:)]) {
        [self.delegate cameraDidConfigurateError:error];
    }
}

- (void)cameraRampZoomToValue:(CGFloat)zoomValue
{
    [self.overlayView updateZoomValue:zoomValue];
}

- (void)captureDeviceSubjectAreaDidChange
{
    if (self.autoFocusAndExpose) {
        [self.previewView autoFocusAndExposure];
        [self.cameraManager resetFocusAndExposure];
    }
}


#pragma mark - 捕捉图片

- (void)cameraManagerDidEndCaptureStillImage:(UIImage *)image error:(NSError *)error
{
    if (!error) {
        __weak typeof(self) weakSelf = self;
        CXPhotoEditView *photoEditView = [CXPhotoEditView photoEditViewWithPhoto:image rephotographBlock:^{
            [weakSelf.photoEditView removeFromSuperview];
        } employPhotoBlock:^{
            [weakSelf callBackCaptureStillImage:image error:nil];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            [weakSelf dismissCallback];
        }];
        [self.view addSubview:photoEditView];
        self.photoEditView = photoEditView;
        self.photoEditView.frame = self.view.bounds;
        [self writeToLibaryWithImage:image];
    } else {
        [self callBackCaptureStillImage:nil error:error];
    }
}

- (void)writeToLibaryWithImage:(UIImage *)image
{
    if (self.automaticWriteToLibary) {
        if ([self checkAccessForPhotosAlbum]) {
            [self.cameraManager writeImageToPhotosAlbum:image
            completionBlock:^(NSURL *assetURL, NSError *error) {
                if ([self.delegate respondsToSelector:@selector(cameraViewController:automaticWriteImageToPhotosAlbum:error:)]) {
                    [self.delegate cameraViewController:self automaticWriteImageToPhotosAlbum:image error:error];
                }
            }];
        }
    }
}

- (void)callBackCaptureStillImage:(UIImage *)image error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(cameraViewController:didEndCaptureImage:error:)]) {
        [self.delegate cameraViewController:self didEndCaptureImage:image error:error];
    }
}


#pragma mark - 捕捉视频

- (void)cameraManagerDidStartReocrdingVideo:(NSURL *)fileURL
{
    [self startRecordingTimer];
}

- (void)cameraManagerDidReachMaxReocrdedDuration:(NSURL *)fileURL
{
    [self cameraManagerDidEndReocrdedVideo:fileURL error:nil];
}

- (void)cameraManagerDidEndReocrdedVideo:(NSURL *)fileURL error:(NSError *)error
{
    [self stopRecordingTimer];
    [self.overlayView endRedording];
    if (!error) {
        __weak typeof(self) weakSelf = self;
        CXVideoEditView *videoEditView = [CXVideoEditView videoEditViewWithVideoURL:fileURL recordAgainBlock:^{
            [weakSelf.overlayView setShutterEnable:YES];
            [weakSelf.videoEditView removeFromSuperview];
        } employVideoBlock:^{
            [weakSelf.overlayView setShutterEnable:YES];
            [weakSelf callBackEndRecordedVideo:fileURL error:error];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            [weakSelf dismissCallback];
        }];
        [self.view addSubview:videoEditView];
        self.videoEditView = videoEditView;
        self.videoEditView.frame = self.view.bounds;
        [self writeToLibaryWithVideoURL:fileURL];
    } else {
        [self callBackEndRecordedVideo:fileURL error:error];
    }
}

- (void)writeToLibaryWithVideoURL:(NSURL *)videoURL
{
    if (self.automaticWriteToLibary) {
        if ([self checkAccessForPhotosAlbum]) {
            [self.cameraManager writeVideoToPhotosAlbumAtPath:videoURL
              completionBlock:^(NSURL *assetURL, NSError *error) {
                  if ([self.delegate respondsToSelector:@selector(cameraViewController:automaticWriteVideoToPhotosAlbumAtPath:error:)]) {
                      [self.delegate cameraViewController:self automaticWriteVideoToPhotosAlbumAtPath:videoURL error:error];
                  }
              }];
        }
    }
}

- (BOOL)checkAccessForPhotosAlbum
{
    if ([self.cameraManager authorizeAssetsLibrary]) {
        return YES;
    } else {
        if ([self.delegate respondsToSelector:@selector(cameraNoAccessForPhotosAlbum)]) {
            [self.delegate cameraNoAccessForPhotosAlbum];
        }
        return NO;
    }
}

- (void)callBackEndRecordedVideo:(NSURL *)videoURL error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(cameraViewController:didEndCaptureVideo:error:)]) {
        [self.delegate cameraViewController:self didEndCaptureVideo:videoURL error:error];
    }
}


#pragma mark - private method

- (void)setupPreviewView
{
    CXPreviewView *previewView = [[CXPreviewView alloc] initWithFrame:self.view.bounds];
    previewView.delegate = self;
    [self.view addSubview:previewView];
    self.previewView = previewView;
}

- (void)setupOverlayView
{
    CXOverlayView *overlayView = [[CXOverlayView alloc] initWithFrame:self.view.bounds];
    overlayView.cameraMode = self.cameraMode;
    overlayView.delegate = self;
    [self.view addSubview:overlayView];
    self.overlayView = overlayView;
}

- (void)setupSession
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) { // 未授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self configurateSession];
            } 
        }];
    } else if (status == AVAuthorizationStatusAuthorized) { // 已授权
        [self configurateSession];
    } else {                                                // 拒绝或无法访问
        if ([self.delegate respondsToSelector:@selector(cameraNoAccessForMedia)]) {
            [self.delegate cameraNoAccessForMedia];
        }
    }
}

- (void)configurateSession
{
    self.cameraManager = [[CXCameraManager alloc] init];
    self.cameraManager.delegate = self;
    self.cameraManager.maxRecordedDuration = self.maxRecordedDuration;
    self.cameraManager.autoFocusAndExpose = self.autoFocusAndExpose;
    
    [self.previewView setSession:self.cameraManager.session];
    [self.cameraManager startSession];
}

- (void)startZoomSliderTimer
{
    [self stopZoomSliderTimer];
    __weak typeof(self) weakSelf = self;
    self.zoomSliderTimer = [NSTimer cx_scheduledTimerWithTimeInterval:kCXCameraHidenZoomSliderTimeInterval
    fireBlock:^{
        [weakSelf.overlayView setZoomSliderHiden:YES];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.zoomSliderTimer forMode:NSRunLoopCommonModes];
}

- (void)stopZoomSliderTimer
{
    [self.zoomSliderTimer invalidate];
    self.zoomSliderTimer = nil;
}

- (void)startRecordingTimer
{
    [self stopRecordingTimer];
    __weak typeof(self) weakSelf = self;
    self.recordingTimer = [NSTimer cx_timerWithTimeInterval:kCXCameraRecordingTimeInterval
                                                    repeats:YES
    fireBlock:^{
          NSString *formattedTime = [weakSelf formatRecordedTime:[weakSelf.cameraManager recordedDuration]];
          [weakSelf.overlayView setRecordingFormattedTime:formattedTime];
      }];
    [[NSRunLoop mainRunLoop] addTimer:self.recordingTimer forMode:NSRunLoopCommonModes];
    
}

- (void)stopRecordingTimer
{
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
}

- (NSString *)formatRecordedTime:(NSTimeInterval)interval
{
    NSInteger hours = interval / 3600;
    NSInteger minutes = (int)(interval / 60) % 60;
    NSInteger seconds = (int)interval % 60;
    return [NSString stringWithFormat:@"%02zd:%02zd:%02zd",hours,minutes,seconds];
}

- (void)dismissCallback
{
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerDidDismiss:)]) {
        [self.delegate cameraViewControllerDidDismiss:self];
    }
}


#pragma mark - public method

/**
 *  present一个拍照相机控制器
 */
+ (instancetype)presentPhotoCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                        automaticWriteToLibary:(BOOL)automaticWriteToLibary
                            autoFocusAndExpose:(BOOL)autoFocusAndExpose
{
    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
    cameraVC.cameraMode = CXCameraModePhoto;
    cameraVC.automaticWriteToLibary = automaticWriteToLibary;
    cameraVC.delegate = delegate;
    cameraVC.autoFocusAndExpose = autoFocusAndExpose;
    [self presentCameraVC:cameraVC];
    return cameraVC;
}

/**
 *  present一个录像相机控制器
 */
+ (instancetype)presentVideoCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                           maxRecordedDuration:(NSTimeInterval)maxRecordedDuration
                        automaticWriteToLibary:(BOOL)automaticWriteToLibary
                            autoFocusAndExpose:(BOOL)autoFocusAndExpose
{
    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
    cameraVC.cameraMode = CXCameraModeVideo;
    cameraVC.maxRecordedDuration = maxRecordedDuration;
    cameraVC.automaticWriteToLibary = automaticWriteToLibary;
    cameraVC.delegate = delegate;
    cameraVC.autoFocusAndExpose = autoFocusAndExpose;
    [self presentCameraVC:cameraVC];
    return cameraVC;
}

+ (void)presentCameraVC:(CXCameraViewController *)cameraVC
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:cameraVC animated:YES completion:nil];
}




@end
