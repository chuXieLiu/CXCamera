//
//  CALayer+CXExtension.h
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (CXExtension)

@property (nonatomic,assign) CGFloat transformRotation;  ///< key path "tranform.rotation"
@property (nonatomic,assign) CGFloat transformRotationX;
@property (nonatomic,assign) CGFloat transformRotationY;
@property (nonatomic,assign) CGFloat transformRotationZ;
@property (nonatomic,assign) CGFloat transformScale;
@property (nonatomic,assign) CGFloat transformScaleX;
@property (nonatomic,assign) CGFloat transformScaleY;
@property (nonatomic,assign) CGFloat transformScaleZ;
@property (nonatomic,assign) CGFloat transformTranslationX;
@property (nonatomic,assign) CGFloat transformTranslationY;
@property (nonatomic,assign) CGFloat transformTranslationZ;

@end
