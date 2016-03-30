//
//  CXOverlayView.m
//  CXCamera
//
//  Created by c_xie on 16/3/29.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXOverlayView.h"
#import "UIView+CXExtension.h"
#import "CXCameraStatusView.h"
#import "CXFlashPopView.h"

static const CGFloat kCXOverlayStatusViewheight = 44.0f;
static const CGFloat kCXOverlayModeViewHeight = 110.0f;

static const CGFloat kCXShutterButtonWidth = 68.0f;
static const CGFloat kCXShutterButtonHeight = 68.0f;

static const CGFloat kCXCancelButtonWidth = 44.0f;
static const CGFloat kCXCancelButtonHeight = 44.0f;

@interface CXOverlayView ()

@property (nonatomic,weak) UIView *cameraModeView;

@property (nonatomic,weak) CXCameraStatusView *cameraStatusView;

@property (nonatomic,strong) CXFlashPopView *flashPopView;

@property (nonatomic,weak) UIButton *cancelButton;

@end

@implementation CXOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *cameraModeView = [[UIView alloc] initWithFrame:CGRectZero];
    cameraModeView.backgroundColor = [UIColor blackColor];
    [self addSubview:cameraModeView];
    _cameraModeView = cameraModeView;
    
    CXCameraStatusView *cameraStatusView = [[CXCameraStatusView alloc] initWithFrame:CGRectZero];
    cameraStatusView.backgroundColor = [UIColor blackColor];
    [self addSubview:cameraStatusView];
    _cameraStatusView = cameraStatusView;
    
    [_cameraStatusView.flashButton addTarget:self action:@selector(flashChange:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraStatusView.switchButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CXShutterButton *shutterButton = [[CXShutterButton alloc] initWithMode:CXShutterButtonModeVideo];
    [shutterButton addTarget:self action:@selector(shutter:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraModeView addSubview:shutterButton];
    _shutterButton = shutterButton;
    
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [cancelButton setImage:[UIImage imageNamed:@"icon_cancel_white"]
                  forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraModeView addSubview:cancelButton];
    _cancelButton = cancelButton;

}

- (void)flashChange:(UIButton *)sender
{
    if (self.flashPopView.isShowing) {
        [self.flashPopView dismiss];
    } else {
        [self.flashPopView showFromView:self toView:_cameraStatusView.flashButton];
    }
    
}

- (void)switchCamera:(UIButton *)sender
{
    
}

- (void)shutter:(CXShutterButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didSelectedShutter:)]) {
        [_delegate didSelectedShutter:self];
    }
}

- (void)cancel:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didSelectedCancel:)]) {
        [_delegate didSelectedCancel:self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _cameraModeView.left = 0.f;
    _cameraModeView.bottom = self.height;
    _cameraModeView.size = CGSizeMake(self.width,kCXOverlayModeViewHeight);
    
    _cameraStatusView.left = 0.f;
    _cameraStatusView.top = 0.f;
    _cameraStatusView.size = CGSizeMake(self.width, kCXOverlayStatusViewheight);
    
    _shutterButton.centerX = _cameraModeView.width *0.5;
    _shutterButton.bottom = _cameraModeView.height - 15;
    _shutterButton.size = CGSizeMake(kCXShutterButtonWidth, kCXShutterButtonHeight);
    
    _cancelButton.left = 5.0f;
    _cancelButton.centerY = _shutterButton.centerY;
    _cancelButton.size = CGSizeMake(kCXCancelButtonWidth, kCXCancelButtonHeight);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([_cameraModeView pointInside:[self convertPoint:point toView:_cameraModeView] withEvent:event]
        || [_cameraStatusView pointInside:[self convertPoint:point toView:_cameraStatusView] withEvent:event]) {
        return YES;
    }
    return NO;
}

- (CXFlashPopView *)flashPopView
{
    if (_flashPopView == nil) {
        _flashPopView = [[CXFlashPopView alloc] init];
    }
    return _flashPopView;
}

@end
