//
//  CXCameraViewController.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCommonConst.h"


@interface CXCameraViewController : UIViewController

/// 相机类型 CXCameraModePhoto  / CXCameraModeVideo
@property (nonatomic,assign) CXCameraMode cameraMode;
/// 是否自动写入相册 , 默认为NO
@property (nonatomic,assign) BOOL automaticWriteToLibary;

@end
