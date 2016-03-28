//
//  CXOverlayView.m
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXOverlayView.h"
#import "CXShutterButton.h"
#import "UIView+CXExtension.h"


@interface CXModeView : UIView

@property (nonatomic,weak) CXShutterButton *shutterButton;

@end

@implementation CXModeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    CXShutterButton *shutterButton = [[CXShutterButton alloc] initWithMode:CXShutterButtonModeVideo];
    [self addSubview:shutterButton];
    _shutterButton = shutterButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _shutterButton.centerX = self.width * 0.5;
    _shutterButton.size = CGSizeMake(kCXShutterButtonWidth, kCXShutterButtonHeight);
    _shutterButton.bottom = self.height - 10.0f;
    NSLog(@"%f",_shutterButton.centerX);
}

@end

@interface CXOverlayView ()

@property (nonatomic,weak) CXModeView *modeView;

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

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    
}

- (void)setup
{
    self.backgroundColor = [UIColor blueColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    
    CXModeView *modeView = [[CXModeView alloc] init];
    [self addSubview:modeView];
    _modeView = modeView;
   
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_modeView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0f
                                                             constant:0.f];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_modeView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0f
                                                             constant:0.f];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_modeView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0f
                                                              constant:0.f];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_modeView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0.0f
                                                               constant:kCXOverlayModeViewHeight];
    
    [_modeView addConstraint:height];
    
    [self addConstraints:@[left,right,bottom]];
    
    
    [_modeView.shutterButton addTarget:self action:@selector(shuterEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)shuterEvent:(CXShutterButton *)sender
{
    if (sender.shutterButtonMode == CXShutterButtonModePhoto) {
        
    } else {
        sender.selected = !sender.isSelected;
    }
}


@end
