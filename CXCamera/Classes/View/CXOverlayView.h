//
//  CXOverlayView.h
//  CXCamera
//
//  Created by c_xie on 16/3/29.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCommonConst.h"

typedef enum : NSUInteger {
    CXCameraZoomTypeSubstract,
    CXCameraZoomTypePlus
} CXCameraZoomType;


@class CXOverlayView;

@protocol CXOverLayViewDelegate <NSObject>

@optional

- (void)didSelectedShutter:(CXOverlayView *)overlayView;
- (void)didSelectedCancel:(CXOverlayView *)overlayView;
- (void)didSelectedFlashMode:(CXCaptureFlashMode)flashMode;
- (void)didSwitchCamera;


- (void)didtouchDownToCameraZoomType:(CXCameraZoomType)zoomType;
- (void)didTouchUpInsideToCameraZoomType:(CXCameraZoomType)zoomType;
- (void)didTouchDownZoomSliderView:(CXOverlayView *)overlayView;
- (void)didTouchUpInsideZoomSliderView:(CXOverlayView *)overlayView;
- (void)sliderChangeToValue:(CGFloat)zoomValue;

@end

@interface CXOverlayView : UIView

@property (nonatomic,assign) CXCameraMode cameraMode;

@property (nonatomic,weak) id<CXOverLayViewDelegate> delegate;


// 切换设备
- (void)switchDeviceMode:(CXDeviceMode)deviceMode;

// 准备录制视频
- (BOOL)prepareToRecording;
- (void)endRedording;
- (void)setRecordingFormattedTime:(NSString *)formattedTime;

- (void)setZoomSliderHiden:(BOOL)hiden;
- (void)updateZoomValue:(CGFloat)zoomValue;
- (CGFloat)currentZoomValue;









@end
