//
//  CXShutterButton.m
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXShutterButton.h"
#import "UIView+CXExtension.h"

static const CGFloat kCXShutterButtonLineWidth = 6.0f;

static const CGFloat kCXShuterButtonAnimationDuration = 0.2f;


@interface CXShutterButton ()

@property (nonatomic,weak) CALayer *circleLayer;

@end

@implementation CXShutterButton

- (instancetype)initWithMode:(CXShutterButtonMode)mode
{
    self = [super init];
    if (self) {
        self.shutterButtonMode = mode;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)drawRect:(CGRect)rect
{
    if (!self.circleLayer) {
        [self drawCircle];
    }
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
    self.circleLayer.opacity = [animation.toValue floatValue];
    [self.circleLayer addAnimation:animation forKey:nil];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (self.shutterButtonMode == CXShutterButtonModeVideo) {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        CABasicAnimation *radiuAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        
        CGFloat width = self.circleLayer.bounds.size.width;
        
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
        [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
        [self.circleLayer setValue:radiuAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer addAnimation:group forKey:nil];
    }
}



- (void)setShutterButtonMode:(CXShutterButtonMode)shutterButtonMode
{
    _shutterButtonMode = shutterButtonMode;
    UIColor *circleColor = self.shutterButtonMode == CXShutterButtonModeVideo ? [UIColor redColor] : [UIColor whiteColor];
    self.circleLayer.backgroundColor = circleColor.CGColor;

}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    
}

- (void)drawCircle
{
    UIColor *circleColor = self.shutterButtonMode == CXShutterButtonModeVideo ? [UIColor redColor] : [UIColor whiteColor];
    // 画圆
    CALayer *circleLayer = [CALayer layer];
    circleLayer.backgroundColor = circleColor.CGColor;
    CGFloat dx  = kCXShutterButtonLineWidth + 2.0f;
    CGFloat dy = dx;
    circleLayer.bounds = CGRectInset(self.bounds, dx, dy);
    circleLayer.position = self.cx_center;
    circleLayer.cornerRadius = circleLayer.bounds.size.width * 0.5;
    [self.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
}



















@end
