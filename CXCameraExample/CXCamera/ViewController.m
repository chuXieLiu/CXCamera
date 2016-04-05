//
//  ViewController.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import "CXCamera.h"

@interface ViewController () <CXCameraViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (IBAction)showPhotoCamera:(id)sender {
    
//    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
//    cameraVC.cameraMode = CXCameraModePhoto;
//    cameraVC.automaticWriteToLibary = YES;
//    [self presentViewController:cameraVC animated:YES completion:nil];
    
    [CXCameraViewController showCameraWithDelegate:self
                                        cameraMode:CXCameraModePhoto
                            automaticWriteToLibary:NO];
    
}

- (IBAction)showVideoCamera:(id)sender {
    
//    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
//    cameraVC.cameraMode = CXCameraModeVideo;
//    cameraVC.automaticWriteToLibary = YES;
//    [self presentViewController:cameraVC animated:YES completion:nil];
    
    [CXCameraViewController showCameraWithDelegate:self
                                        cameraMode:CXCameraModeVideo
                            automaticWriteToLibary:NO];
}





#pragma mark - CXCameraViewControllerDelegate

/// 没有权限访问
- (void)cameraNoAccessForMedia
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请前往系统设置->隐私->相机代开app访问权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

/// 相机配置错误
- (void)cameraDidConfigurateError:(NSError *)error
{
    NSLog(@"%@",error);
}

/// 捕捉图片，image可能为空
- (void)cameraViewController:(CXCameraViewController *)cameraVC didCaptureImage:(UIImage *)image
{
    NSLog(@"%@",image);
}

/// 捕捉图片，video可能为空
- (void)cameraViewController:(CXCameraViewController *)cameraVC didCaptureVideo:(NSURL *)videoURL
{
    NSLog(@"%@",videoURL);
}

/// 自动保存图片结果
- (void)cameraViewController:(CXCameraViewController *)cameraVC saveImage:(UIImage *)image isSuccessed:(BOOL)isSuccessed
{
    NSLog(@"%d",isSuccessed);
}

/// 自动保存视频结果
- (void)cameraViewController:(CXCameraViewController *)cameraVC saveVideo:(NSURL *)videoURL isSuccessed:(BOOL)isSuccessed
{
    NSLog(@"%d",isSuccessed);
}



@end
