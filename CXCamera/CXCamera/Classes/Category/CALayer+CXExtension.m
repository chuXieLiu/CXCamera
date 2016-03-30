//
//  CALayer+CXExtension.m
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CALayer+CXExtension.h"

@implementation CALayer (CXExtension)

- (CGFloat)transformRotation
{
    return [[self valueForKeyPath:@"transform.rotation"] doubleValue];
}

- (void)setTransformRotation:(CGFloat)transformRotation
{
    [self setValue:@(transformRotation) forKeyPath:@"transform.rotation"];
}

- (void)setTransformRotationX:(CGFloat)transformRotationX
{
    [self setValue:@(transformRotationX) forKeyPath:@"transform.rotation.x"];
}

- (CGFloat)transformRotationX
{
    return [[self valueForKeyPath:@"transform.rotation.x"] doubleValue];
}

- (void)setTransformRotationY:(CGFloat)transformRotationY
{
    [self setValue:@(transformRotationY) forKeyPath:@"transform.rotation.y"];
}

- (CGFloat)transformRotationY
{
    return [[self valueForKeyPath:@"transform.rotation.y"] doubleValue];
}

- (void)setTransformRotationZ:(CGFloat)transformRotationZ
{
    [self setValue:@(transformRotationZ) forKeyPath:@"transform.rotation.z"];
}

- (CGFloat)transformRotationZ
{
    return [[self valueForKeyPath:@"transform.rotation.z"] doubleValue];
}

- (void)setTransformScale:(CGFloat)transformScale
{
    [self setValue:@(transformScale) forKeyPath:@"transform.scale"];
}

- (CGFloat)transformScale
{
    return [[self valueForKeyPath:@"transform.scale"] doubleValue];
}

- (void)setTransformScaleX:(CGFloat)transformScaleX
{
    [self setValue:@(transformScaleX) forKeyPath:@"transform.scale.x"];
}

- (CGFloat)transformScaleX
{
    return [[self valueForKeyPath:@"transform.scale.x"] doubleValue];
}

- (void)setTransformScaleY:(CGFloat)transformScaleY
{
    [self setValue:@(transformScaleY) forKeyPath:@"transform.scale.y"];
}

- (CGFloat)transformScaleY
{
    return [[self valueForKeyPath:@"transform.scale.y"] doubleValue];
}

- (void)setTransformScaleZ:(CGFloat)transformScaleZ
{
    [self setValue:@(transformScaleZ) forKeyPath:@"transform.scale.z"];
}

- (CGFloat)transformScaleZ
{
    return [[self valueForKeyPath:@"transform.scale.z"] doubleValue];
}

- (void)setTransformTranslationX:(CGFloat)transformTranslationX
{
    [self setValue:@(transformTranslationX) forKeyPath:@"transform.translation.x"];
}

- (CGFloat)transformTranslationX
{
    return [[self valueForKeyPath:@"transform.translation.x"] doubleValue];
}

- (void)setTransformTranslationY:(CGFloat)transformTranslationY
{
    [self setValue:@(transformTranslationY) forKeyPath:@"transform.translation.y"];
}

- (CGFloat)transformTranslationY
{
    return [[self valueForKeyPath:@"transform.translation.y"] doubleValue];
}

- (void)setTransformTranslationZ:(CGFloat)transformTranslationZ
{
    [self setValue:@(transformTranslationZ) forKeyPath:@"transform.translation.z"];
}

- (CGFloat)transformTranslationZ
{
    return [[self valueForKeyPath:@"transform.translation.z"] doubleValue];
}



@end
