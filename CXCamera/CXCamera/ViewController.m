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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CXCameraViewController *cameraVC = [[CXCameraViewController alloc] init];
    cameraVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cameraVC animated:NO completion:nil];
}

@end
