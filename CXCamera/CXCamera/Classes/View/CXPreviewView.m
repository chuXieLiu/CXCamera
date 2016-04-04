//
//  CXPreviewView.m
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXPreviewView.h"
#import "CALayer+CXExtension.h"

static const CGFloat kCXFoucsBoxWidth = 150.0f;
static const CGFloat kCXFoucsBoxHeight = 150.0f;

static const CGFloat kCXExposeBoxWidth = 150.0f;
static const CGFloat kCXExposeBoxHeight = 150.0f;

static const NSTimeInterval kCXBoxAnimationInterval = 0.2;

static const CGFloat kCXBoxBorderWidth = 2.0f;

@interface CXPreviewView ()

@property (nonatomic,weak) UIView *focusBox;

@property (nonatomic,weak) UIView *exposeBox;

@property (nonatomic,assign) CGFloat lastScale;

@property (nonatomic,strong) UITapGestureRecognizer *singleTapGesture;

@property (nonatomic,strong) UIPinchGestureRecognizer *pinchGesture;

@end


@implementation CXPreviewView

+ (Class)layerClass
{
    // 预览层
    return [AVCaptureVideoPreviewLayer class];
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

#pragma mark - public method

- (void)setEnableZoom:(BOOL)enableZoom
{
    _enableZoom = enableZoom;
    _pinchGesture.enabled = _enableZoom;
}


- (void)setEnableExpose:(BOOL)enableExpose
{
    _enableExpose = enableExpose;
    _singleTapGesture.enabled = _enableExpose;
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

#pragma mark - target event

/*
 - (void)handleSingleTap:(UITapGestureRecognizer *)gesture
 {
    if (!_enableFoucs) return;
    CGPoint point = [gesture locationInView:self];
    [self showBox:_focusBox atPoint:point];
    if ([_delegate respondsToSelector:@selector(previewView:singleTapAtPoint:)]) {
        [_delegate previewView:self singleTapAtPoint:[self captureDevicePoint:point]];
    }
 }*/


- (void)handleSingleTap:(UITapGestureRecognizer *)gesture
{
    if (!_enableExpose) return;
    CGPoint point = [gesture locationInView:self];
    [self showBox:self.exposeBox atPoint:point];
    if ([_delegate respondsToSelector:@selector(previewView:doubleTapAtPoint:)]) {
        [_delegate previewView:self doubleTapAtPoint:[self captureDevicePoint:point]];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    CGFloat value = 0.f;
    if (gesture.scale > 1) {    // scale递增
        value = gesture.scale - _lastScale;
    }
    if (gesture.scale < 1) {    // scale递增或递减
        value = gesture.scale - _lastScale;
    }
    _lastScale = gesture.scale;
    if ([_delegate respondsToSelector:@selector(previewView:pinchScaleChangeValue:)]) {
        [_delegate previewView:self pinchScaleChangeValue:value];
    }
    UIGestureRecognizerState state = gesture.state;
    if (state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(previewViewWillBeginPinch:)]) {
            [_delegate previewViewWillBeginPinch:self];
        }
    } else if (state == UIGestureRecognizerStateEnded  ||
        state == UIGestureRecognizerStateCancelled ||
        state == UIGestureRecognizerStateFailed) {
        _lastScale = 1;
        if ([_delegate respondsToSelector:@selector(previewViewDidEndPinch:)]) {
            [_delegate previewViewDidEndPinch:self];
        }
    }
}

- (void)showBox:(UIView *)box atPoint:(CGPoint)point
{
    box.hidden = NO;
    box.center = point;
    [UIView animateWithDuration:kCXBoxAnimationInterval
                          delay:0.f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         box.layer.transformScale = 0.5f;
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             box.hidden = YES;
                             box.layer.transformScale = 1.0f;
                         });
                     }];
}

#pragma mark - private method

- (void)setup
{
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.backgroundColor = [UIColor blackColor];
    
    self.enableExpose = YES;
    self.enableZoom = YES;
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:_singleTapGesture];
    
    _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:_pinchGesture];
    _lastScale = 1;
    
}


- (CGPoint)captureDevicePoint:(CGPoint)point
{
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}




#pragma mark - lazy

- (UIView *)exposeBox
{
    if (_exposeBox == nil) {
        UIView *exposeBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCXExposeBoxWidth, kCXExposeBoxHeight)];
        exposeBox.backgroundColor = [UIColor clearColor];
        exposeBox.layer.borderWidth = kCXBoxBorderWidth;
        exposeBox.layer.borderColor = [UIColor orangeColor].CGColor;
        exposeBox.hidden = YES;
        [self addSubview:exposeBox];
        _exposeBox = exposeBox;
    }
    return _exposeBox;
}

- (UIView *)focusBox
{
    if (_focusBox == nil) {
        UIView *focusBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCXFoucsBoxWidth, kCXFoucsBoxHeight)];
        focusBox.backgroundColor = [UIColor clearColor];
        focusBox.layer.borderWidth = kCXBoxBorderWidth;
        focusBox.layer.borderColor = [UIColor yellowColor].CGColor;
        focusBox.hidden = YES;
        [self addSubview:focusBox];
        _focusBox = focusBox;
    }
    return _focusBox;
}




@end
