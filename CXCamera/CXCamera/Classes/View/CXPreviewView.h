//
//  CXPreviewView.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CXPreviewView : UIView

/**
 *  为预览层添加会话
 */
- (void)setSession:(AVCaptureSession *)session;

@end
