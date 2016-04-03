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
- (void)previewView:(CXPreviewView *)preivewView doubleTapAtPoint:(CGPoint)point;

/**
 *  value：相对于上次pinch的scale的差值
 */
- (void)previewView:(CXPreviewView *)preivewView pinchScaleChangeValue:(CGFloat)value;

@end


@interface CXPreviewView : UIView

// 是否允许对焦
@property (nonatomic,assign) BOOL enableFoucs;
// 是否允许曝光
@property (nonatomic,assign) BOOL enableExpose;

@property (nonatomic,weak) id<CXPreviewViewDelegate> delegate;

/**
 *  为预览层添加会话
 */
- (void)setSession:(AVCaptureSession *)session;

@end
