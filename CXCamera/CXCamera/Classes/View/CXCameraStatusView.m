//
//  CXCameraStatusView.m
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraStatusView.h"
#import "UIView+CXExtension.h"

static const CGFloat kCXCameraStatusTimeLabelWidth = 100.0f;

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
    
    self.flashButton.left = 10.f;
    self.flashButton.top = 0.f;
    self.flashButton.size = CGSizeMake(self.height, self.height);
    
    self.switchButton.right = self.width - self.flashButton.left;
    self.switchButton.top = 0.f;
    self.switchButton.size = self.flashButton.size;
    
    self.timeLabel.centerX = self.width * 0.5;
    self.timeLabel.centerY = self.height * 0.5;
    self.timeLabel.size = CGSizeMake(kCXCameraStatusTimeLabelWidth, self.height);
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    
    UIButton *flashButton = [[UIButton alloc] init];
    [flashButton setImage:[UIImage imageNamed:@"camera_flash_on_a"]
                 forState:UIControlStateNormal];
    [self addSubview:flashButton];
    self.flashButton = flashButton;
    
    UIButton *switchButton = [[UIButton alloc] init];
    [switchButton setImage:[UIImage imageNamed:@"icon_camera_flip_a"]
                  forState:UIControlStateNormal];
    [self addSubview:switchButton];
    self.switchButton = switchButton;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:17.0f];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = @"00:00:00";
    [timeLabel sizeToFit];
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
}

@end
