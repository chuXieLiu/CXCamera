//
//  CXCameraStatusView.m
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraStatusView.h"
#import "UIView+CXExtension.h"

@implementation CXCameraStatusView

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
    
    _flashButton.left = 10.f;
    _flashButton.top = 0.f;
    _flashButton.size = CGSizeMake(self.height, self.height);
    
    _switchButton.right = self.width - _flashButton.left;
    _switchButton.top = 0.f;
    _switchButton.size = _flashButton.size;
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    
    UIButton *flashButton = [[UIButton alloc] init];
    [flashButton setImage:[UIImage imageNamed:@"camera_flash_on_a"]
                 forState:UIControlStateNormal];
    [self addSubview:flashButton];
    _flashButton = flashButton;
    
    UIButton *switchButton = [[UIButton alloc] init];
    [switchButton setImage:[UIImage imageNamed:@"icon_camera_flip_a"]
                  forState:UIControlStateNormal];
    [self addSubview:switchButton];
    _switchButton = switchButton;
}

@end
