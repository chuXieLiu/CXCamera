//
//  CXPhotoEditView.m
//  CXCamera
//
//  Created by c_xie on 16/4/4.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXPhotoEditView.h"
#import "UIView+CXExtension.h"

static const CGFloat kCXPhotoEditViewToolViewHeight = 70.0f;

@interface CXPhotoEditView ()

@property (nonatomic,copy) CXCameraRephotographBlock rephotographBlock;
@property (nonatomic,copy) CXCameraEmployPhotoBlock employPhotoBlock;

@property (nonatomic,strong) UIImage *photo;

@property (nonatomic,weak) UIImageView *photoView;
@property (nonatomic,weak) UIView *toolView;
@property (nonatomic,weak) UIButton *rephotographButton;
@property (nonatomic,weak) UIButton *employPhotoButton;

@end

@implementation CXPhotoEditView

+ (instancetype)photoEditViewWithPhoto:(UIImage *)photo
                     rephotographBlock:(CXCameraRephotographBlock)rephotographBlock
                      employPhotoBlock:(CXCameraEmployPhotoBlock)employPhotoBlock;
{
    CXPhotoEditView *photoView = [[CXPhotoEditView alloc] initWithFrame:CGRectZero];
    photoView.photo = photo;
    photoView.rephotographBlock = rephotographBlock;
    photoView.employPhotoBlock = employPhotoBlock;
    return photoView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        self.photoView = imageView;
        
        UIView *toolView = [[UIView alloc] init];
        toolView.backgroundColor = [UIColor colorWithRed:16 / 255.0f green:16 / 255.0f blue:16 / 255.0f alpha:1.0];
        [self addSubview:toolView];
        self.toolView = toolView;
        
        UIButton *rephotographButton = [[UIButton alloc] init];
        [rephotographButton setTitle:@"重拍" forState:UIControlStateNormal];
        [rephotographButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rephotographButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [rephotographButton addTarget:self action:@selector(rephotograph:) forControlEvents:UIControlEventTouchUpInside];
        [rephotographButton sizeToFit];
        [self.toolView addSubview:rephotographButton];
        self.rephotographButton = rephotographButton;
        
        UIButton *employPhotoButton = [[UIButton alloc] init];
        [employPhotoButton setTitle:@"使用照片" forState:UIControlStateNormal];
        [employPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [employPhotoButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [employPhotoButton addTarget:self action:@selector(employPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [employPhotoButton sizeToFit];
        [self.toolView addSubview:employPhotoButton];
        self.employPhotoButton = employPhotoButton;
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.photo.size.width > self.photo.size.height) {
        self.photoView.width = self.width;
        self.photoView.height = floorf(self.width * 3 / 4);// 4:3的比例
        
    } else {
        self.photoView.width = self.width;
        self.photoView.height = floorf(self.width * 4 / 3); // 4:3的比例
        
    }
    self.photoView.left = 0;
    self.photoView.top = (self.height - self.photoView.height) * 0.5;
    
    self.toolView.origin = CGPointMake(0, self.height - kCXPhotoEditViewToolViewHeight);
    self.toolView.size = CGSizeMake(self.width, kCXPhotoEditViewToolViewHeight);
    
    self.rephotographButton.left = 15.0f;
    self.rephotographButton.centerY = self.toolView.height * 0.5;
    
    self.employPhotoButton.right = self.width - self.rephotographButton.left;
    self.employPhotoButton.centerY = self.rephotographButton.centerY;
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (self.photo) {
        self.photoView.image = self.photo;
    }
}



#pragma mark - target event

- (void)rephotograph:(UIButton *)sender
{
    !self.rephotographBlock ? : self.rephotographBlock();
}

- (void)employPhoto:(UIButton *)sender
{
    !self.employPhotoBlock ? : self.employPhotoBlock();
}









@end
