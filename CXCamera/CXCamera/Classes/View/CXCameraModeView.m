//
//  CXCameraModeView.m
//  CXCamera
//
//  Created by c_xie on 16/4/2.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraModeView.h"
#import "UIView+CXExtension.h"

static const CGFloat kCXCameraModeViewBottomMargin = 15.0f;

static const CGFloat kCXShutterButtonWidth = 68.0f;
static const CGFloat kCXShutterButtonHeight = 68.0f;

static const CGFloat kCXCancelButtonWidth = 44.0f;
static const CGFloat kCXCancelButtonHeight = 44.0f;

@implementation CXCameraModeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.shutterButton.centerX = self.width *0.5;
    self.shutterButton.bottom = self.height - kCXCameraModeViewBottomMargin;
    self.shutterButton.size = CGSizeMake(kCXShutterButtonWidth, kCXShutterButtonHeight);
    
    self.cancelButton.left = 5.0f;
    self.cancelButton.centerY = self.shutterButton.centerY;
    self.cancelButton.size = CGSizeMake(kCXCancelButtonWidth, kCXCancelButtonHeight);
}


- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [cancelButton setImage:[UIImage imageNamed:@"icon_cancel_white"]
                  forState:UIControlStateNormal];
    [self addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    
    CXShutterButton *shutterButton = [[CXShutterButton alloc] initWithMode:CXShutterButtonModeVideo];
    [self addSubview:shutterButton];
    self.shutterButton = shutterButton;
}

@end
