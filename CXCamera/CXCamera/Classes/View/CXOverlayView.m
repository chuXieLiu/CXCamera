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
    
    _cameraModeView.left = 0.f;
    _cameraModeView.bottom = self.height;
    _cameraModeView.size = CGSizeMake(self.width,kCXOverlayModeViewHeight);
    
    _cameraStatusView.left = 0.f;
    _cameraStatusView.top = 0.f;
    _cameraStatusView.size = CGSizeMake(self.width, kCXOverlayStatusViewheight);
    
    _zoomSlider.left = 0.f;
    _zoomSlider.bottom = _cameraModeView.top;
    _zoomSlider.size = CGSizeMake(self.width, kCXCameraZoomSliderHeight);
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.flashPopView.isShowing) {  // 不让事件传递
        return YES;
    } else {
        BOOL insideStatusView = [_cameraStatusView pointInside:[self convertPoint:point toView:_cameraStatusView] withEvent:event];
        BOOL insideModeView = [_cameraModeView pointInside:[self convertPoint:point toView:_cameraModeView] withEvent:event];
        BOOL inSideSlider = !_zoomSlider.isHidden && [_zoomSlider pointInside:[self convertPoint:point toView:_zoomSlider] withEvent:event];
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
        _cameraStatusView.flashButton.hidden = YES;
        
    } else {
        _cameraStatusView.flashButton.hidden = NO;
    }
    [self setZoomSliderHiden:YES];
}

- (BOOL)prepareToRecording
{
    _cameraStatusView.switchButton.userInteractionEnabled = NO;
    return _cameraModeView.shutterButton.isSelected;
}

- (void)endRedording
{
    _cameraStatusView.switchButton.userInteractionEnabled = YES;
    _cameraStatusView.timeLabel.text = @"00:00:00";
}

- (void)setRecordingFormattedTime:(NSString *)formattedTime
{
    _cameraStatusView.timeLabel.text = formattedTime;
}

- (void)setCameraMode:(CXCameraMode)cameraMode
{
    _cameraMode = cameraMode;
    
    BOOL isCameraModePhoto = cameraMode ==CXCameraModePhoto;
    
    UIColor *toColor = isCameraModePhoto ? [UIColor blackColor] : [UIColor colorWithWhite:0 alpha:0.4];
    _cameraStatusView.backgroundColor = toColor;
    _cameraModeView.backgroundColor = toColor;
    
    CXShutterButtonMode shutterButtonMode = isCameraModePhoto ? CXShutterButtonModePhoto : CXShutterButtonModeVideo;
    _cameraModeView.shutterButton.shutterButtonMode = shutterButtonMode;
    
    _cameraStatusView.timeLabel.hidden = isCameraModePhoto;
}

- (void)setZoomSliderHiden:(BOOL)hiden
{
    _zoomSlider.hidden = hiden;
}


- (void)updateZoomValue:(CGFloat)zoomValue
{
    _zoomSlider.slider.value = zoomValue;
}

- (CGFloat)currentZoomValue
{
    return _zoomSlider.slider.value;
}

#pragma mark - CXFlashPopViewDelegate

- (void)flashPopView:(CXFlashPopView *)flashPopView itemDidSelected:(CXPopItem *)item
{
    [_cameraStatusView.flashButton setImage:[UIImage imageNamed:item.imageName]
                                   forState:UIControlStateNormal];
    if ([_delegate respondsToSelector:@selector(didSelectedFlashMode:)]) {
        [_delegate didSelectedFlashMode:item.flashMode];
    }
}


- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    
    CXCameraModeView *cameraModeView = [[CXCameraModeView alloc] initWithFrame:CGRectZero];
    [self addSubview:cameraModeView];
    _cameraModeView = cameraModeView;
    
    
    CXCameraStatusView *cameraStatusView = [[CXCameraStatusView alloc] initWithFrame:CGRectZero];
    [self addSubview:cameraStatusView];
    _cameraStatusView = cameraStatusView;
    
    
    
    
    CXCameraZoomSlider *zoomSlider = [[CXCameraZoomSlider alloc] init];
    [self addSubview:zoomSlider];
    _zoomSlider = zoomSlider;
    _zoomSlider.hidden = YES;
    
    
    
    [_cameraStatusView.flashButton addTarget:self
                                      action:@selector(flashChange:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [_cameraStatusView.switchButton addTarget:self
                                       action:@selector(switchCamera:)
                             forControlEvents:UIControlEventTouchUpInside];

    [_cameraModeView.shutterButton addTarget:self
                                      action:@selector(shutter:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [_cameraModeView.cancelButton addTarget:self
                                     action:@selector(cancel:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [_zoomSlider.subtractButton addTarget:self action:@selector(touchDownZoomSubstract:) forControlEvents:UIControlEventTouchDown];
    
    [_zoomSlider.subtractButton addTarget:self action:@selector(touchUpInsideZoomSubstract:) forControlEvents:UIControlEventTouchUpInside];
    
    [_zoomSlider.plusButton addTarget:self action:@selector(touchDownZoomPlus:) forControlEvents:UIControlEventTouchDown];
    
    [_zoomSlider.plusButton addTarget:self action:@selector(touchUpInsideZoomPlus:) forControlEvents:UIControlEventTouchUpInside];
    
    [_zoomSlider.slider addTarget:self action:@selector(touchDownZoomSliderView:) forControlEvents:UIControlEventTouchDown];
    
    [_zoomSlider.slider addTarget:self action:@selector(touchUpInsideZoomSliderView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_zoomSlider.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
}


#pragma mark - target event

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
    if ([_delegate respondsToSelector:@selector(didSwitchCamera)]) {
        [_delegate didSwitchCamera];
    }
}

- (void)shutter:(CXShutterButton *)sender
{
    sender.selected = !sender.isSelected;
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


- (void)touchDownZoomSubstract:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didtouchDownToCameraZoomType:)]) {
        [_delegate didtouchDownToCameraZoomType:CXCameraZoomTypeSubstract];
    }
}


- (void)touchUpInsideZoomSubstract:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didTouchUpInsideToCameraZoomType:)]) {
        [_delegate didTouchUpInsideToCameraZoomType:CXCameraZoomTypeSubstract];
    }
}

- (void)touchDownZoomPlus:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didtouchDownToCameraZoomType:)]) {
        [_delegate didtouchDownToCameraZoomType:CXCameraZoomTypePlus];
    }
}


- (void)touchUpInsideZoomPlus:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didTouchUpInsideToCameraZoomType:)]) {
        [_delegate didTouchUpInsideToCameraZoomType:CXCameraZoomTypePlus];
    }
}


- (void)sliderValueChange:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(sliderChangeToValue:)]) {
        [_delegate sliderChangeToValue:sender.value];
    }
}


- (void)touchDownZoomSliderView:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(didTouchDownZoomSliderView:)]) {
        [_delegate didTouchDownZoomSliderView:self];
    }
}

- (void)touchUpInsideZoomSliderView:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(didTouchUpInsideZoomSliderView:)]) {
        [_delegate didTouchUpInsideZoomSliderView:self];
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
                            @"camera_flash_off_a",
                            @"camera_flash_auto_a",
                            @"camera_flash_on_a",
                            @"camera_torch_on_a"
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
