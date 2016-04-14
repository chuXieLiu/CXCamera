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
    [CXCameraViewController presentPhotoCameraWithDelegate:self
                                    automaticWriteToLibary:YES
                                        autoFocusAndExpose:YES];
    
}

- (IBAction)showVideoCamera:(id)sender {
    
//    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
//    cameraVC.cameraMode = CXCameraModeVideo;
//    cameraVC.automaticWriteToLibary = YES;
//    cameraVC.maxRecordedDuration = 5;
//    [self presentViewController:cameraVC animated:YES completion:nil];
    
    [CXCameraViewController presentVideoCameraWithDelegate:self
                                       maxRecordedDuration:10
                                    automaticWriteToLibary:YES
                                        autoFocusAndExpose:YES];

}





#pragma mark - CXCameraViewControllerDelegate

/**
 *  没有权限访问涉嫌头
 */
- (void)cameraNoAccessForMedia
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请前往系统设置->隐私->相机打开app访问权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

/**
 *  没有权限访问相册
 */
- (void)cameraNoAccessForPhotosAlbum
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请前往系统设置->隐私->照片打开app访问权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

/**
 *  相机配置错误
 */
- (void)cameraDidConfigurateError:(NSError *)error
{
    NSLog(@"cameraDidConfigurateError=%@",error);
}

/**
 *  结束图片捕捉，当捕捉出错是image为空
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC didEndCaptureImage:(UIImage *)image error:(NSError *)error
{
    NSLog(@"didEndCaptureImage:%@,%@",image,error);
}

/**
 *  捕捉视频，当捕捉出错时video为空
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC didEndCaptureVideo:(NSURL *)videoURL error:(NSError *)error
{
    NSLog(@"didEndCaptureVideo:%@,%@",videoURL,error);
}



/**
 *  自动保存图片回调
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC automaticWriteImageToPhotosAlbum:(UIImage *)image error:(NSError *)error
{
    NSLog(@"automaticWriteImageToPhotosAlbum:%@,%@",image,error);
}

/**
 *  自动保存视频回调
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC automaticWriteVideoToPhotosAlbumAtPath:(NSURL *)videoURL error:(NSError *)error
{
    NSLog(@"automaticWriteVideoToPhotosAlbumAtPath:%@,%@",videoURL,error);
}





@end
