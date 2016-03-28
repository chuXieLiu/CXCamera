//
//  CXCameraViewController.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraViewController.h"
#import "CXShutterButton.h"
#import "CXCameraManager.h"
#import "CXPreviewView.h"
#import "CXCameraView.h"

@interface CXCameraViewController ()
<
    CXCameraManagerDelegate
>

@property (weak, nonatomic) IBOutlet CXShutterButton *shutterButton;

@property (weak, nonatomic) IBOutlet CXPreviewView *previewView;

@property (nonatomic,strong) CXCameraManager *cameraManager;



@property (nonatomic,weak) CXPreviewView *preview;

@property (nonatomic,weak) CXOverlayView *overlay;

@end

@implementation CXCameraViewController

- (void)loadView
{
    CXCameraView *cameraView = [[CXCameraView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = cameraView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}



- (IBAction)shutter:(CXShutterButton *)sender {
    if (_shutterButton.shutterButtonMode == CXShutterButtonModePhoto) {
        [_cameraManager captureStillImage];
    } else {
        sender.selected = !sender.isSelected;
        if (sender.isSelected) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_cameraManager startRecording];
            });
        } else {
            [_cameraManager stopRecording];
        }
    }
    
    
}





#pragma mark - CXCameraManagerDelegate

- (void)cameraConfigurateFailed:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}






@end
