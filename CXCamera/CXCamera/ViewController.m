//
//  ViewController.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import "CXCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)showPhotoCamera:(id)sender {
    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
    cameraVC.cameraMode = CXCameraModePhoto;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (IBAction)showVideoCamera:(id)sender {
    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
    cameraVC.cameraMode = CXCameraModeVideo;
    [self presentViewController:cameraVC animated:YES completion:nil];
}



@end
