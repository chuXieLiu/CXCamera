//
//  CXPreviewView.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CXPreviewView;

@protocol CXPreviewViewDelegate <NSObject>

- (void)previewView:(CXPreviewView *)preivewView singleTapAtPoint:(CGPoint)point;
- (void)previewView:(CXPreviewView *)preivewView pinchScaleValueDidChange:(CGFloat)value;
- (void)previewViewWillBeginPinch:(CXPreviewView *)previewView;
- (void)previewViewDidEndPinch:(CXPreviewView *)previewView;

@end


@interface CXPreviewView : UIView

// 是否允许曝光
@property (nonatomic,assign) BOOL enableExpose;
// 是否允许缩放
@property (nonatomic,assign) BOOL enableZoom;

@property (nonatomic,weak) id<CXPreviewViewDelegate> delegate;

/**
 *  为预览层添加会话
 */
- (void)setSession:(AVCaptureSession *)session;

- (BOOL)autoFocusAndExposure;




@end
