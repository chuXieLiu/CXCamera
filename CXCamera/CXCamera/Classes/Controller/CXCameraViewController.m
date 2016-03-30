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


@interface CXCameraViewController ()
<
    CXCameraManagerDelegate,
    CXPreviewViewDelegate,
    CXOverLayViewDelegate
>


@property (nonatomic,strong) CXCameraManager *cameraManager;

@property (nonatomic,strong) CXPreviewView *previewView;

@property (nonatomic,strong) CXOverlayView *overlayView;

@end

@implementation CXCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.overlayView];
    
//    _cameraManager = [[CXCameraManager alloc] init];
////    _cameraManager.automaticWriteToLibary = NO;
//    _cameraManager.delegate = self;
//    
//    [_previewView setSession:_cameraManager.session];
//    [_cameraManager startSession];

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
    UIDeviceOrientationFaceDown*/
    
//    NSLog(@"%zd",[UIDevice currentDevice].orientation);
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

#pragma mark - CXOverLayViewDelegate

- (void)didSelectedShutter:(CXOverlayView *)overlayView
{
    CXShutterButton *shutterButton = overlayView.shutterButton;
    if (shutterButton.shutterButtonMode == CXShutterButtonModePhoto) {
        [_cameraManager captureStillImage];
    } else {
        shutterButton.selected = !shutterButton.isSelected;
        if (overlayView.shutterButton.selected) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_cameraManager startRecording];
            });
        } else {
            [_cameraManager stopRecording];
        }
    }
}

- (void)didSelectedCancel:(CXOverlayView *)overlayView
{
    [_cameraManager stopSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CXCameraManagerDelegate


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



- (CXPreviewView *)previewView
{
    if (_previewView == nil) {
        _previewView = [[CXPreviewView alloc] initWithFrame:self.view.bounds];
        _previewView.delegate = self;
    }
    return _previewView;
}

- (CXOverlayView *)overlayView
{
    if (_overlayView == nil) {
        _overlayView = [[CXOverlayView alloc] initWithFrame:self.view.bounds];
        CXShutterButtonMode buttonMode;
        if (_cameraMode == CXCameraModePhoto) {
            buttonMode = CXShutterButtonModePhoto;
        } else {
            buttonMode = CXShutterButtonModeVideo;
        }
        _overlayView.shutterButton.shutterButtonMode = buttonMode;
        _overlayView.delegate = self;
    }
    return _overlayView;
}




@end
