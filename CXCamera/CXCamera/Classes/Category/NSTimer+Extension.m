//
//  NSTimer+Extension.m
//  CXCamera
//
//  Created by c_xie on 16/3/24.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "NSTimer+Extension.h"


@implementation NSTimer (Extension)

/**
 *  创建不重复执行定时器
 *
 *  @param seconds 执行时间段
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds fireBlock:(CXTimerFireBlock)block
{
    return [self scheduledTimerWithTimeInterval:seconds repeats:NO fireBlock:block];
}

/**
 *  创建定时器
 *
 *  @param seconds 执行时间段
 *  @param repeats 是否重复执行
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats fireBlock:(CXTimerFireBlock)block;
{
    id fireBlock = [block copy];
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timerFire:) userInfo:fireBlock repeats:repeats];
}


+ (void)timerFire:(NSTimer *)timer
{
    CXTimerFireBlock block = timer.userInfo;
    block();
}

@end
