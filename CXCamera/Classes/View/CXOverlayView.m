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
#import "CXCameraModeView.h"
#import "CXShutterButton.h"
#import "CXCameraZoomSlider.h"

static const CGFloat kCXCameraZoomSliderHeight = 40.0f;


@interface CXOverlayView ()
<
    CXFlashPopViewDelegate
>

@property (nonatomic,weak) CXCameraModeView *cameraModeView;

@property (nonatomic,weak) CXCameraStatusView *cameraStatusView;

@property (nonatomic,strong) CXFlashPopView *flashPopView;

@property (nonatomic,weak) CXCameraZoomSlider *zoomSlider;

@property (nonatomic,strong) NSArray *popItems;


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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cameraModeView.left = 0.f;
    self.cameraModeView.bottom = self.height;
    self.cameraModeView.size = CGSizeMake(self.width,kCXOverlayModeViewHeight);
    
    self.cameraStatusView.left = 0.f;
    self.cameraStatusView.top = 0.f;
    self.cameraStatusView.size = CGSizeMake(self.width, kCXOverlayStatusViewheight);
    
    self.zoomSlider.left = 0.f;
    self.zoomSlider.bottom = self.cameraModeView.top;
    self.zoomSlider.size = CGSizeMake(self.width, kCXCameraZoomSliderHeight);
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.flashPopView.isShowing) {  // 不让事件传递
        return YES;
    } else {
        BOOL insideStatusView = [self.cameraStatusView pointInside:[self convertPoint:point toView:self.cameraStatusView] withEvent:event];
        BOOL insideModeView = [self.cameraModeView pointInside:[self convertPoint:point toView:self.cameraModeView] withEvent:event];
        BOOL inSideSlider = !self.zoomSlider.isHidden && [self.zoomSlider pointInside:[self convertPoint:point toView:self.zoomSlider] withEvent:event];
        if (insideStatusView || insideModeView || inSideSlider) {
            return YES;
        }
        return NO;
    }
}

#pragma mark - public method

- (void)switchDeviceMode:(CXDeviceMode)deviceMode
{
    if (deviceMode == CXDeviceModeFront) {
        // flash置为打开
        [self flashPopView:nil itemDidSelected:self.popItems[2]];
        self.cameraStatusView.flashButton.hidden = YES;
        
    } else {
        self.cameraStatusView.flashButton.hidden = NO;
    }
    [self setZoomSliderHiden:YES];
}

- (BOOL)prepareToRecording
{
    self.cameraStatusView.switchButton.userInteractionEnabled = NO;
    return self.cameraModeView.shutterButton.isSelected;
}

- (void)endRedording
{
    self.cameraStatusView.switchButton.userInteractionEnabled = YES;
    self.cameraStatusView.timeLabel.text = @"00:00:00";
    self.cameraModeView.shutterButton.selected = NO;
}

- (void)setRecordingFormattedTime:(NSString *)formattedTime
{
    self.cameraStatusView.timeLabel.text = formattedTime;
}

- (void)setShutterEnable:(BOOL)enable
{
    self.cameraModeView.shutterButton.enabled = enable;
}

- (void)setCameraMode:(CXCameraMode)cameraMode
{
    _cameraMode = cameraMode;
    
    BOOL isCameraModePhoto = cameraMode ==CXCameraModePhoto;
    
    UIColor *toColor = isCameraModePhoto ? [UIColor blackColor] : [UIColor colorWithWhite:0 alpha:0.4];
    self.cameraStatusView.backgroundColor = toColor;
    self.cameraModeView.backgroundColor = toColor;
    
    CXShutterButtonMode shutterButtonMode = isCameraModePhoto ? CXShutterButtonModePhoto : CXShutterButtonModeVideo;
    self.cameraModeView.shutterButton.shutterButtonMode = shutterButtonMode;
    
    self.cameraStatusView.timeLabel.hidden = isCameraModePhoto;
}

- (void)setZoomSliderHiden:(BOOL)hiden
{
    self.zoomSlider.hidden = hiden;
}


- (void)updateZoomValue:(CGFloat)zoomValue
{
    self.zoomSlider.slider.value = zoomValue;
}

- (CGFloat)currentZoomValue
{
    return self.zoomSlider.slider.value;
}

#pragma mark - CXFlashPopViewDelegate

- (void)flashPopView:(CXFlashPopView *)flashPopView itemDidSelected:(CXPopItem *)item
{
    [self.cameraStatusView.flashButton setImage:[UIImage imageNamed:item.imageName]
                                   forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(didSelectedFlashMode:)]) {
        [self.delegate didSelectedFlashMode:item.flashMode];
    }
}


- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    
    CXCameraModeView *cameraModeView = [[CXCameraModeView alloc] initWithFrame:CGRectZero];
    [self addSubview:cameraModeView];
    self.cameraModeView = cameraModeView;
    
    
    CXCameraStatusView *cameraStatusView = [[CXCameraStatusView alloc] initWithFrame:CGRectZero];
    [self addSubview:cameraStatusView];
    self.cameraStatusView = cameraStatusView;
    
    
    
    
    CXCameraZoomSlider *zoomSlider = [[CXCameraZoomSlider alloc] init];
    [self addSubview:zoomSlider];
    self.zoomSlider = zoomSlider;
    self.zoomSlider.hidden = YES;
    
    
    
    [self.cameraStatusView.flashButton addTarget:self
                                      action:@selector(flashChange:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [self.cameraStatusView.switchButton addTarget:self
                                       action:@selector(switchCamera:)
                             forControlEvents:UIControlEventTouchUpInside];

    [self.cameraModeView.shutterButton addTarget:self
                                      action:@selector(shutter:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [self.cameraModeView.cancelButton addTarget:self
                                     action:@selector(cancel:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [self.zoomSlider.subtractButton addTarget:self action:@selector(touchDownZoomSubstract:) forControlEvents:UIControlEventTouchDown];
    
    [self.zoomSlider.subtractButton addTarget:self action:@selector(touchUpInsideZoomSubstract:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.zoomSlider.plusButton addTarget:self action:@selector(touchDownZoomPlus:) forControlEvents:UIControlEventTouchDown];
    
    [self.zoomSlider.plusButton addTarget:self action:@selector(touchUpInsideZoomPlus:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.zoomSlider.slider addTarget:self action:@selector(touchDownZoomSliderView:) forControlEvents:UIControlEventTouchDown];
    
    [self.zoomSlider.slider addTarget:self action:@selector(touchUpInsideZoomSliderView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.zoomSlider.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
}


#pragma mark - target event

- (void)flashChange:(UIButton *)sender
{
    if (self.flashPopView.isShowing) {
        [self.flashPopView dismiss];
    } else {
        [self.flashPopView showFromView:self toView:self.cameraStatusView.flashButton];
    }
}

- (void)switchCamera:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSwitchCamera)]) {
        [self.delegate didSwitchCamera];
    }
}

- (void)shutter:(CXShutterButton *)sender
{
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(didSelectedShutter:)]) {
        [self.delegate didSelectedShutter:self];
    }
}

- (void)cancel:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedCancel:)]) {
        [self.delegate didSelectedCancel:self];
    }
}


- (void)touchDownZoomSubstract:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didtouchDownToCameraZoomType:)]) {
        [self.delegate didtouchDownToCameraZoomType:CXCameraZoomTypeSubstract];
    }
}


- (void)touchUpInsideZoomSubstract:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchUpInsideToCameraZoomType:)]) {
        [self.delegate didTouchUpInsideToCameraZoomType:CXCameraZoomTypeSubstract];
    }
}

- (void)touchDownZoomPlus:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didtouchDownToCameraZoomType:)]) {
        [self.delegate didtouchDownToCameraZoomType:CXCameraZoomTypePlus];
    }
}


- (void)touchUpInsideZoomPlus:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchUpInsideToCameraZoomType:)]) {
        [self.delegate didTouchUpInsideToCameraZoomType:CXCameraZoomTypePlus];
    }
}


- (void)sliderValueChange:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(sliderChangeToValue:)]) {
        [self.delegate sliderChangeToValue:sender.value];
    }
}


- (void)touchDownZoomSliderView:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchDownZoomSliderView:)]) {
        [self.delegate didTouchDownZoomSliderView:self];
    }
}

- (void)touchUpInsideZoomSliderView:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchUpInsideZoomSliderView:)]) {
        [self.delegate didTouchUpInsideZoomSliderView:self];
    }
}



#pragma mark - lazy

- (CXFlashPopView *)flashPopView
{
    if (_flashPopView == nil) {
        _flashPopView = [[CXFlashPopView alloc] initWithItems:self.popItems];
        _flashPopView.delegate = self;
    }
    return _flashPopView;
}

- (NSArray *)popItems
{
    if (_popItems == nil) {
        NSArray *images = @[
                            CXCameraSrcName(@"camera_flash_off_a"),
                            CXCameraSrcName(@"camera_flash_auto_a"),
                            CXCameraSrcName(@"camera_flash_on_a"),
                            CXCameraSrcName(@"camera_torch_on_a")
                            ];
        NSMutableArray *items = @[].mutableCopy;
        for (int i = 0 ; i < images.count; i++) {
            CXPopItem *item = [CXPopItem popItemWithFalshMode:i imageName:images[i]];
            [items addObject:item];
        }
        _popItems = items.copy;
    }
    return _popItems;
}

@end
