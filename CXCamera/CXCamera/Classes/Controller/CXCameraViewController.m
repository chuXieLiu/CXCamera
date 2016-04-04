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

@end



@implementation CXCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPreviewView];
    [self setupOverlayView];
    
    _cameraManager = [[CXCameraManager alloc] init];
    _cameraManager.automaticWriteToLibary = _automaticWriteToLibary;
    _cameraManager.delegate = self;
    
    [_previewView setSession:_cameraManager.session];
    [_cameraManager startSession];

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
    /*
    UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    UIDeviceOrientationFaceUp,              // Device oriented flat, face up
    UIDeviceOrientationFaceDown

//    NSLog(@"%zd",[UIDevice currentDevice].orientation);*/
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
}






#pragma mark - CXPreviewViewDelegate

- (void)previewView:(CXPreviewView *)preivewView singleTapAtPoint:(CGPoint)point
{
    [_cameraManager focusAtPoint:point];
}

- (void)previewView:(CXPreviewView *)preivewView doubleTapAtPoint:(CGPoint)point
{
    [_cameraManager exposeAtPoint:point];
}

- (void)previewView:(CXPreviewView *)preivewView pinchScaleChangeValue:(CGFloat)value
{
    
    CGFloat zoomValue = MIN([_overlayView currentZoomValue] + value, 1.0);
    zoomValue = MAX(zoomValue, 0);
    [_cameraManager setZoomValue:zoomValue];
}

#pragma mark - CXOverLayViewDelegate

- (void)didSelectedShutter:(CXOverlayView *)overlayView
{
    if (_cameraMode == CXCameraModePhoto) {
        [_cameraManager captureStillImage];
    } else {
        if ([_overlayView prepareToRecording]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_cameraManager startRecording];
                [self startRecordingTimer];
            });
            
        } else {
            [_cameraManager stopRecording];
            [self endRecordingTimer];
        }
    }
}

- (void)didSelectedCancel:(CXOverlayView *)overlayView
{
    [_cameraManager stopSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectedFlashMode:(CXCaptureFlashMode)flashMode
{
    if ([_cameraManager cameraHasFlash]) {
        switch (flashMode) {
            case CXCaptureFlashModeOn:
                [_cameraManager setFlashMode:AVCaptureFlashModeOn];
                break;
            case CXCaptureFlashModeOff:
                [_cameraManager setFlashMode:AVCaptureFlashModeOff];
                break;
                
            case CXCaptureFlashModeAuto:
                [_cameraManager setFlashMode:AVCaptureFlashModeAuto];
                break;
                
            case CXCaptureFlashModeTorch:
                if ([_cameraManager cameraHasTorch]) {
                    if ([_cameraManager torchMode] == AVCaptureTorchModeOff) {
                        [_cameraManager setTorchMode:AVCaptureTorchModeOn];
                    } else {
                        [_cameraManager setTorchMode:AVCaptureTorchModeOff];
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
    if ([_cameraManager switchCamera]) {
        [_overlayView switchDeviceMode:[_cameraManager deviceMode]];
        _previewView.enableExpose = [_cameraManager isCameraExposureSupported];
        if (_cameraManager.deviceMode == CXDeviceModeFront) {
            _previewView.enableZoom = NO;
        } else {
            _previewView.enableZoom = YES;
        }
        
    }
}

- (void)didtouchDownToCameraZoomType:(CXCameraZoomType)zoomType
{
    if ([_cameraManager isCameraZoomSupported]) {
        CGFloat zoom = 0.f;
        if (zoomType == CXCameraZoomTypePlus) {
            zoom = 1.0f;
        }
        [_cameraManager rampZoomToValue:zoom];
    }
    [self endZoomSliderTimer];
}

- (void)didTouchUpInsideToCameraZoomType:(CXCameraZoomType)zoomType
{
    if ([_cameraManager isCameraZoomSupported]) {
        [_cameraManager cancelZoom];
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
    if ([_cameraManager isCameraZoomSupported]) {
        [_cameraManager setZoomValue:zoomValue];
    }
}

#pragma mark - private method

- (void)setupPreviewView
{
    CXPreviewView *previewView = [[CXPreviewView alloc] initWithFrame:self.view.bounds];
    previewView.delegate = self;
    [self.view addSubview:previewView];
    _previewView = previewView;
}

- (void)setupOverlayView
{
    CXOverlayView *overlayView = [[CXOverlayView alloc] initWithFrame:self.view.bounds];
    overlayView.cameraMode = _cameraMode;
    overlayView.delegate = self;
    [self.view addSubview:overlayView];
    _overlayView = overlayView;
}

- (void)startZoomSliderTimer
{
    [self endZoomSliderTimer];
    __weak typeof(self) weakSelf = self;
    _zoomSliderTimer = [NSTimer cx_scheduledTimerWithTimeInterval:kCXCameraHidenZoomSliderTimeInterval
    fireBlock:^{
        [weakSelf.overlayView setZoomSliderHiden:YES];
    }];
    [[NSRunLoop mainRunLoop] addTimer:_zoomSliderTimer forMode:NSRunLoopCommonModes];
}

- (void)endZoomSliderTimer
{
    [_zoomSliderTimer invalidate];
    _zoomSliderTimer = nil;
}

- (void)startRecordingTimer
{
    [self endRecordingTimer];
    __weak typeof(self) weakSelf = self;
    _recordingTimer = [NSTimer cx_timerWithTimeInterval:kCXCameraRecordingTimeInterval
                                                         repeats:YES
    fireBlock:^{
        NSString *formattedTime = [weakSelf formatRecordedTime:[weakSelf.cameraManager recordedDuration]];
        [weakSelf.overlayView setRecordingFormattedTime:formattedTime];
    }];
    [[NSRunLoop mainRunLoop] addTimer:_recordingTimer forMode:NSRunLoopCommonModes];

}


- (void)endRecordingTimer
{
    [_recordingTimer invalidate];
    _recordingTimer = nil;
}

- (NSString *)formatRecordedTime:(NSTimeInterval)interval
{
    NSInteger hours = interval / 3600;
    NSInteger minutes = (int)(interval / 60) % 60;
    NSInteger seconds = (int)interval % 60;
    return [NSString stringWithFormat:@"%02zd:%02zd:%02zd",hours,minutes,seconds];
}


#pragma mark - CXCameraManagerDelegate

- (void)cameraRampZoomToValue:(CGFloat)zoomValue
{
    [_overlayView updateZoomValue:zoomValue];
}

- (void)previewViewWillBeginPinch:(CXPreviewView *)previewView
{
    [self endZoomSliderTimer];
    [_overlayView setZoomSliderHiden:NO];
}

- (void)previewViewDidEndPinch:(CXPreviewView *)previewView
{
    [self startZoomSliderTimer];
}

- (void)captureSessionConfigurateError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"相机初始化失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)cameraManagerConfigurateFailed:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"相机初始化失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)cameraManagerToSavedPhotosAlbumFailed:(id)media error:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"保存失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)dealloc
{
    [self endZoomSliderTimer];
    [self endRecordingTimer];
}


@end
