//
//  CXPreviewView.m
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXPreviewView.h"


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

- (void)setup
{
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}




@end
