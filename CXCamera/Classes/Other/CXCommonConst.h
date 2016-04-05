//
//  CXCommonConst.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

// 设备
typedef enum : NSUInteger {
    CXDeviceModeFront,  // 前置摄像头
    CXDeviceModeBack,   // 默认使用后置摄像头
} CXDeviceMode;


// 相机
typedef enum : NSUInteger {
    CXCameraModePhoto,
    CXCameraModeVideo,
} CXCameraMode;



// 快门
typedef enum : NSUInteger {
    CXShutterButtonModePhoto,
    CXShutterButtonModeVideo,
} CXShutterButtonMode;



// 闪光灯
typedef enum : NSUInteger {
    CXCaptureFlashModeOff,
    CXCaptureFlashModeOn,
    CXCaptureFlashModeAuto,
    CXCaptureFlashModeTorch // 手电筒
} CXCaptureFlashMode;





UIKIT_EXTERN CGFloat const kCXOverlayStatusViewheight;

UIKIT_EXTERN CGFloat const kCXOverlayModeViewHeight;





#define CXCameraSrcName(file) [@"CXCamera.bundle" stringByAppendingPathComponent:file]











