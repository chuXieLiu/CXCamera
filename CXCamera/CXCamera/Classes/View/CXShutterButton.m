//
//  CXShutterButton.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXShutterButton.h"
#import "UIView+Extension.h"

static const CGFloat kCXShutterButtonWidth = 68.0f;
static const CGFloat kCXShutterButtonHeight = 68.0f;

static const CGFloat kCXShutterButtonLineWidth = 6.0f;

static const CGFloat kCXShuterButtonAnimationDuration = 0.2f;


@interface CXShutterButton ()

@property (nonatomic,weak) CALayer *circleLayer;

@end

@implementation CXShutterButton

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.width = kCXShutterButtonWidth;
    frame.size.height = kCXShutterButtonHeight;
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    _shutterButtonMode = CXShutterButtonModeVideo;
    [self setup];
}

- (void)drawRect:(CGRect)rect
{
    // 获取上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    // 设置颜色
    CGContextSetStrokeColorWithColor(ref, [UIColor whiteColor].CGColor);
    // 设置线宽
    CGContextSetLineWidth(ref, kCXShutterButtonLineWidth);
    // 绘制
    CGFloat dx = kCXShutterButtonLineWidth * 0.5;
    CGFloat dy = dx;
    CGRect insetRect = CGRectInset(rect, dx, dy);
    CGContextStrokeEllipseInRect(ref, insetRect);
}


- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    // 点击快门
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = kCXShuterButtonAnimationDuration;
    if (highlighted) {
        animation.toValue = @0.0f;
    } else {
        animation.toValue = @1.0f;
    }
    _circleLayer.opacity = [animation.toValue floatValue];
    [_circleLayer addAnimation:animation forKey:nil];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (_shutterButtonMode == CXShutterButtonModeVideo) {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        CABasicAnimation *radiuAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        
        CGFloat width = _circleLayer.bounds.size.width;
        
        if (selected) {
            scaleAnimation.toValue = @0.6f;
            radiuAnimation.toValue = @(width / 4);
        } else {
            scaleAnimation.toValue = @1.0f;
            radiuAnimation.toValue = @(width * 0.5);
        }
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[
                                 scaleAnimation,
                                 radiuAnimation
                             ];
        group.beginTime = CACurrentMediaTime() + kCXShuterButtonAnimationDuration;
        group.duration = 0.35f;
        [_circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
        [_circleLayer setValue:radiuAnimation.toValue forKeyPath:@"cornerRadius"];
        [_circleLayer addAnimation:group forKey:nil];
    }
}



- (void)setShutterButtonMode:(CXShutterButtonMode)shutterButtonMode
{
    if (_shutterButtonMode != shutterButtonMode) {
        _shutterButtonMode = shutterButtonMode;
        UIColor *circleColor = _shutterButtonMode == CXShutterButtonModeVideo ? [UIColor redColor] : [UIColor whiteColor];
        _circleLayer.backgroundColor = circleColor.CGColor;
    }
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    UIColor *circleColor = _shutterButtonMode == CXShutterButtonModeVideo ? [UIColor redColor] : [UIColor whiteColor];
    // 画圆
    CALayer *circleLayer = [CALayer layer];
    circleLayer.backgroundColor = circleColor.CGColor;
    CGFloat dx  = kCXShutterButtonLineWidth + 2.0f;
    CGFloat dy = dx;
    circleLayer.bounds = CGRectInset(self.bounds, dx, dy);
    circleLayer.position = self.cx_center;
    circleLayer.cornerRadius = circleLayer.bounds.size.width * 0.5;
    [self.layer addSublayer:circleLayer];
    _circleLayer = circleLayer;
    
}



















@end
