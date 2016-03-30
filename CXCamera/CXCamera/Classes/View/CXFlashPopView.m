//
//  CXFlashPopView.m
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXFlashPopView.h"
#import "UIView+CXExtension.h"

@interface CXFlashPopView ()

@property (nonatomic,weak) UIView *contentView;

@property (nonatomic,weak) UIImageView *imageView;


@end

@implementation CXFlashPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
        contentView.backgroundColor = [UIColor whiteColor];
//        contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView];
        _contentView = contentView;
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage imageNamed:@"camera_flash_setting_bg"];
        CGFloat top = image.size.height * 0.5;
        CGFloat bottom = image.size.height * 0.5;
        CGFloat left = image.size.width * 0.5;
        CGFloat right = image.size.width * 0.5;
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        image = [image resizableImageWithCapInsets:insets];
        imageView.image = image;
        [_contentView addSubview:imageView];
        _imageView = imageView;
        
    }
    return self;
}

- (void)showFromView:(UIView *)from toView:(UIView *)to
{
    _showing = YES;
    CGRect toRect = [self convertRect:to.frame toView:self];
    
    [from addSubview:self];
    self.frame = from.bounds;
    
    _contentView.left = toRect.origin.x;
    _contentView.top = CGRectGetMaxY(toRect);
    _contentView.size = CGSizeMake(200, 44 *4);
    
    _imageView.frame = _contentView.bounds;
    
}

- (void)dismiss
{
    _showing = NO;
    [self removeFromSuperview];
}

@end
