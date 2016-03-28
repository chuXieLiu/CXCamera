//
//  CXCameraView.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXPreviewView.h"
#import "CXOverlayView.h"

@interface CXCameraView : UIView

@property (nonatomic,weak,readonly) CXPreviewView *preview;
@property (nonatomic,weak,readonly) CXOverlayView *overlay;

@end
