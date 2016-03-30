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

@interface CXPreviewView ()

@property (nonatomic,weak) UIView *focusBox;

@property (nonatomic,weak) UIView *exposeBox;

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

- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event NS_AVAILABLE_IOS(3_0)
{
    NSLog(@"%s",__func__);
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event NS_AVAILABLE_IOS(3_0)
{
    NSLog(@"%s",__func__);
}

- (void)setup
{
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.backgroundColor = [UIColor blackColor];
    _enableExpose = YES;
    _enableFoucs = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UIView *foucsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCXFoucsBoxWidth, kCXFoucsBoxHeight)];
    foucsView.backgroundColor = [UIColor clearColor];
    foucsView.layer.borderWidth = 5.0f;
    foucsView.layer.borderColor = [UIColor yellowColor].CGColor;
    foucsView.hidden = YES;
    [self addSubview:foucsView];
    _focusBox = foucsView;
    
    UIView *exposeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCXExposeBoxWidth, kCXExposeBoxHeight)];
    exposeView.backgroundColor = [UIColor clearColor];
    exposeView.layer.borderWidth = 5.0f;
    exposeView.layer.borderColor = [UIColor orangeColor].CGColor;
    exposeView.hidden = YES;
    [self addSubview:exposeView];
    _exposeBox = exposeView;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture
{
    if (!_enableFoucs) return;
    CGPoint point = [gesture locationInView:self];
    [self showBox:_focusBox atPoint:point];
    if ([_delegate respondsToSelector:@selector(previewView:singleTapAtPoint:)]) {
        [_delegate previewView:self singleTapAtPoint:[self captureDevicePoint:point]];
    }
}



- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture
{
    if (!_enableExpose) return;
    CGPoint point = [gesture locationInView:self];
    [self showBox:_exposeBox atPoint:point];
    if ([_delegate respondsToSelector:@selector(previewView:doubleTapAtPoint:)]) {
        [_delegate previewView:self doubleTapAtPoint:[self captureDevicePoint:point]];
    }
}

- (CGPoint)captureDevicePoint:(CGPoint)point
{
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
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

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}






@end
