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



static const CGFloat kCXCameraHidenZoomSliderTimeInterval = 3.0f;

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

@end



@implementation CXCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPreviewView];
    [self setupOverlayView];
    [self setupSession];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    [self.cameraManager focusAtPoint:point];
}

- (void)previewView:(CXPreviewView *)preivewView doubleTapAtPoint:(CGPoint)point
{
    [self.cameraManager exposeAtPoint:point];
}

- (void)previewViewWillBeginPinch:(CXPreviewView *)previewView
{
    [self endZoomSliderTimer];
    [self.overlayView setZoomSliderHiden:NO];
}

- (void)previewViewDidEndPinch:(CXPreviewView *)previewView
{
    [self startZoomSliderTimer];
}


- (void)previewView:(CXPreviewView *)preivewView pinchScaleChangeValue:(CGFloat)value
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
                [self startRecordingTimer];
            });
        } else {
            [self.cameraManager stopRecording];
            [self endRecordingTimer];
        }
        
    }
}

- (void)didSelectedCancel:(CXOverlayView *)overlayView
{
    [self.cameraManager stopSession];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self endZoomSliderTimer];
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
    [self endZoomSliderTimer];
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

#pragma mark - 缩放

- (void)cameraRampZoomToValue:(CGFloat)zoomValue
{
    [self.overlayView updateZoomValue:zoomValue];
}


#pragma mark - 捕捉图片

- (void)cameraManagerDidSuccessedCapturedStillImage:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    CXPhotoEditView *photoEditView = [CXPhotoEditView showPhotoEditViewWithPhoto:image rephotographBlock:^{
        
        [weakSelf.photoEditView removeFromSuperview];
        
    } employPhotoBlock:^{
        
        if ([self.delegate respondsToSelector:@selector(cameraViewController:didCaptureImage:)]) {
            [self.delegate cameraViewController:self didCaptureImage:image];
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
        
    }];
    [self.view addSubview:photoEditView];
    self.photoEditView = photoEditView;
    self.photoEditView.frame = self.view.bounds;
}

- (void)cameraManagerDidFailedCapturedStillImage:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(cameraViewController:didCaptureImage:)]) {
        [self.delegate cameraViewController:self didCaptureImage:nil];
    }
}

#pragma mark - 捕捉视频

- (void)cameraManagerDidSuccessedReocrdedVideo:(NSURL *)fileURL recordedDuration:(NSTimeInterval)duration
{
    [self.overlayView setRecordingFormattedTime:@"00:00:00"];
    __weak typeof(self) weakSelf = self;
    CXVideoEditView *videoEditView = [CXVideoEditView showVideoEditViewWithVideoURL:fileURL recordAgainBlock:^{
        [weakSelf.videoEditView removeFromSuperview];
    } employVideoBlock:^{
        
        if ([self.delegate respondsToSelector:@selector(cameraViewController:didCaptureVideo:)]) {
            [self.delegate cameraViewController:self didCaptureVideo:fileURL];
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [self.view addSubview:videoEditView];
    self.videoEditView = videoEditView;
    self.videoEditView.frame = self.view.bounds;
}

- (void)cameraManagerDidFailedReocrdedVideo:(NSError *)error
{
    [self.overlayView setRecordingFormattedTime:@"00:00:00"];
    
    if ([self.delegate respondsToSelector:@selector(cameraViewController:didCaptureVideo:)]) {
        [self.delegate cameraViewController:self didCaptureVideo:nil];
    }
}

#pragma mark - 保存资源

- (void)cameraManagerToSavedPhotosAlbumSuccessed:(id)media
{
    if ([media isKindOfClass:[UIImage class]]) {
        if ([self.delegate respondsToSelector:@selector(cameraViewController:saveImage:isSuccessed:)]) {
            [self.delegate cameraViewController:self saveImage:media isSuccessed:YES];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(cameraViewController:saveVideo:isSuccessed:)]) {
            [self.delegate cameraViewController:self saveVideo:media isSuccessed:YES];
        }
    }
    
}
- (void)cameraManagerToSavedPhotosAlbumFailed:(id)media error:(NSError *)error
{
    if ([media isKindOfClass:[UIImage class]]) {
        if ([self.delegate respondsToSelector:@selector(cameraViewController:saveImage:isSuccessed:)]) {
            [self.delegate cameraViewController:self saveImage:media isSuccessed:NO];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(cameraViewController:saveVideo:isSuccessed:)]) {
            [self.delegate cameraViewController:self saveVideo:media isSuccessed:NO];
        }
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
    self.cameraManager.automaticWriteToLibary = self.automaticWriteToLibary;
    self.cameraManager.delegate = self;
    
    [self.previewView setSession:self.cameraManager.session];
    [self.cameraManager startSession];
}

- (void)startZoomSliderTimer
{
    [self endZoomSliderTimer];
    __weak typeof(self) weakSelf = self;
    self.zoomSliderTimer = [NSTimer cx_scheduledTimerWithTimeInterval:kCXCameraHidenZoomSliderTimeInterval
                                                            fireBlock:^{
                                                                [weakSelf.overlayView setZoomSliderHiden:YES];
                                                            }];
    [[NSRunLoop mainRunLoop] addTimer:self.zoomSliderTimer forMode:NSRunLoopCommonModes];
}

- (void)endZoomSliderTimer
{
    [self.zoomSliderTimer invalidate];
    self.zoomSliderTimer = nil;
}

- (void)startRecordingTimer
{
    [self endRecordingTimer];
    __weak typeof(self) weakSelf = self;
    self.recordingTimer = [NSTimer cx_timerWithTimeInterval:kCXCameraRecordingTimeInterval
                                                    repeats:YES
                                                  fireBlock:^{
                                                      NSString *formattedTime = [weakSelf formatRecordedTime:[weakSelf.cameraManager recordedDuration]];
                                                      [weakSelf.overlayView setRecordingFormattedTime:formattedTime];
                                                  }];
    [[NSRunLoop mainRunLoop] addTimer:self.recordingTimer forMode:NSRunLoopCommonModes];
    
}


- (void)endRecordingTimer
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


- (void)dealloc
{
    [self endZoomSliderTimer];
    [self endRecordingTimer];
}

+ (instancetype)showCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate cameraMode:(CXCameraMode)cameraMode automaticWriteToLibary:(BOOL)automaticWriteToLibary
{
    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
    cameraVC.cameraMode = cameraMode;
    cameraVC.automaticWriteToLibary = automaticWriteToLibary;
    cameraVC.delegate = delegate;
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:cameraVC animated:YES completion:nil];
    return cameraVC;
}


@end
