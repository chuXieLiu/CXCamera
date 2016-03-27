//
//  CXCameraViewController.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraViewController.h"
#import "CXShutterButton.h"

@interface CXCameraViewController ()

@property (weak, nonatomic) IBOutlet CXShutterButton *shutterButton;

@end

@implementation CXCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}

- (IBAction)shutter:(CXShutterButton *)sender {
    if (_shutterButton.shutterButtonMode == CXShutterButtonModePhoto) {
        _shutterButton.shutterButtonMode = CXShutterButtonModeVideo;
    } else {
        _shutterButton.shutterButtonMode = CXShutterButtonModePhoto;
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _shutterButton.selected = !_shutterButton.isSelected;
}

+ (instancetype)cameraViewController
{
    return [UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil].instantiateInitialViewController;
}



@end
