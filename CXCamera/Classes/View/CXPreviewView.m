//
//  CXPreviewView.m
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXPreviewView.h"
#import "CALayer+CXExtension.h"
#import "CXCommonConst.h"
#import "UIView+CXExtension.h"

static const CGFloat kCXFoucsBoxWidth = 250.0f;
static const CGFloat kCXFoucsBoxHeight = 250.0f;

static const CGFloat kCXExposeBoxWidth = 150.0f;
static const CGFloat kCXExposeBoxHeight = 150.0f;

static const NSTimeInterval kCXBoxAnimationInterval = 0.2f;

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
    self.pinchGesture.enabled = self.enableZoom;
}

- (void)setEnableExpose:(BOOL)enableExpose
{
    _enableExpose = enableExpose;
    self.singleTapGesture.enabled = self.enableExpose;
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (BOOL)autoFocusAndExposure
{
    return [self showfoucsBox];
}

#pragma mark - target event

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture
{
    if (!self.enableExpose) return;
    CGPoint point = [gesture locationInView:self];
    [self showExposeBoxAtPoint:point];
    if ([self.delegate respondsToSelector:@selector(previewView:singleTapAtPoint:)]) {
        [self.delegate previewView:self singleTapAtPoint:[self captureDevicePoint:point]];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    CGFloat value = 0.f;
    if (gesture.scale > 1) {    // scale递增
        value = gesture.scale - self.lastScale;
    }
    if (gesture.scale < 1) {    // scale递增或递减
        value = gesture.scale - self.lastScale;
    }
    self.lastScale = gesture.scale;
    if ([self.delegate respondsToSelector:@selector(previewView:pinchScaleValueDidChange:)]) {
        [self.delegate previewView:self pinchScaleValueDidChange:value];
    }
    UIGestureRecognizerState state = gesture.state;
    if (state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(previewViewWillBeginPinch:)]) {
            [self.delegate previewViewWillBeginPinch:self];
        }
    } else if (state == UIGestureRecognizerStateEnded  ||
        state == UIGestureRecognizerStateCancelled ||
        state == UIGestureRecognizerStateFailed) {
        self.lastScale = 1;
        if ([self.delegate respondsToSelector:@selector(previewViewDidEndPinch:)]) {
            [self.delegate previewViewDidEndPinch:self];
        }
    }
}

- (void)showExposeBoxAtPoint:(CGPoint)point
{
    self.focusBox.hidden = YES;
    UIView *box = self.exposeBox;
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

- (BOOL)showfoucsBox
{
    if (!self.exposeBox.isHidden) return NO;
    if (!self.focusBox.isHidden) return NO;
    UIView *box = self.focusBox;
    box.hidden = NO;

    CGFloat centerX = self.width * 0.5;
    CGFloat centerY = (self.height - kCXOverlayModeViewHeight) * 0.5;
    CGPoint center = CGPointMake(centerX,centerY);
    box.center = center;

    [UIView animateWithDuration:kCXBoxAnimationInterval
                          delay:0.f
                        options:UIViewAnimationOptionCurveLinear
     animations:^{
         box.layer.transformScale = 0.6f;
     } completion:^(BOOL finished) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             box.hidden = YES;
             box.layer.transformScale = 1.0f;
         });
     }];
    return YES;
}



#pragma mark - private method

- (void)setup
{
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.backgroundColor = [UIColor blackColor];
    
    self.enableExpose = YES;
    self.enableZoom = YES;
    
    self.singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:self.singleTapGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:self.pinchGesture];
    self.lastScale = 1;
    
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
        focusBox.layer.borderColor = [UIColor orangeColor].CGColor;
        focusBox.hidden = YES;
        [self addSubview:focusBox];
        _focusBox = focusBox;
    }
    return _focusBox;
}




@end
