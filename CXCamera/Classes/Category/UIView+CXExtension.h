//
//  UIView+CXExtension.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CXExtension)

@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGPoint origin;
@property (nonatomic,assign) CGPoint cx_center;
@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;
@property (nonatomic,assign) CGSize size;

/**
 *  将当前view渲染成image对象
 *
 *  @return
 */
- (UIImage *)renderImage;

/**
 *  将当前view渲染成指定大小的image对象
 *
 *  @param size
 *
 *  @return
 */
- (UIImage *)renderImageWithSize:(CGSize)size;


/**
 *  是否正在当前window上显示
 *
 *  @return
 */
- (BOOL)isShowingOnKeyWindow;


/**
 *  从xib加载view通用方法
 *
 *  @return
 */
+ (instancetype)viewFromXib;

@end
