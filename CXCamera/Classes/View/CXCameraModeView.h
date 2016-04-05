//
//  CXCameraModeView.h
//  CXCamera
//
//  Created by c_xie on 16/4/2.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXShutterButton.h"

@interface CXCameraModeView : UIView

@property (nonatomic,weak) UIButton *cancelButton;

@property (nonatomic,weak) CXShutterButton *shutterButton;

@end
