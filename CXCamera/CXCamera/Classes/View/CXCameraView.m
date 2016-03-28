//
//  CXCameraView.m
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXCameraView.h"

@interface CXCameraView ()

@property (nonatomic,weak) CXPreviewView *preview;
@property (nonatomic,weak) CXOverlayView *overlay;

@end

@implementation CXCameraView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _preview.frame = self.bounds;
    _overlay.frame = self.bounds;
    
}


- (void)setup
{
    
    // 预览图层
    CXPreviewView *preview = [[CXPreviewView alloc] initWithFrame:self.bounds];
    [self addSubview:preview];
    _preview = preview;
    
    
    // 操作界面
    CXOverlayView *overlay= [[CXOverlayView alloc] initWithFrame:self.bounds];
    [self addSubview:overlay];
    _overlay = overlay;
    
}




@end
