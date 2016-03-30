//
//  CXCameraViewController.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CXCameraModePhoto,
    CXCameraModeVideo,
} CXCameraMode;

@interface CXCameraViewController : UIViewController

@property (nonatomic,assign) CXCameraMode cameraMode;


@end
