//
//  CXOverlayView.h
//  CXCamera
//
//  Created by c_xie on 16/3/29.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXShutterButton.h"
#import "CXCommonConst.h"

@class CXOverlayView;

@protocol CXOverLayViewDelegate <NSObject>

@optional

- (void)didSelectedShutter:(CXOverlayView *)overlayView;
- (void)didSelectedCancel:(CXOverlayView *)overlayView;

@end

@interface CXOverlayView : UIView

@property (nonatomic,weak) id<CXOverLayViewDelegate> delegate;

@property (nonatomic,weak) CXShutterButton *shutterButton;



@end
