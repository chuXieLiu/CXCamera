//
//  NSTimer+CXExtension.m
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "NSTimer+CXExtension.h"

@implementation NSTimer (CXExtension)

/**
 *  创建不重复执行定时器
 *
 *  @param seconds 执行时间段
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)cx_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds fireBlock:(CXTimerFireBlock)block
{
    if (!block) return nil;
    return [self cx_scheduledTimerWithTimeInterval:seconds repeats:NO fireBlock:block];
}

+ (instancetype)cx_timerWithTimeInterval:(NSTimeInterval)seconds fireBlock:(CXTimerFireBlock)block
{
    if (!block) return nil;
    return [self cx_timerWithTimeInterval:seconds repeats:NO fireBlock:block];
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
+ (instancetype)cx_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats fireBlock:(CXTimerFireBlock)block;
{
    if (!block) return nil;
    return [NSTimer scheduledTimerWithTimeInterval:seconds
                                            target:self
                                          selector:@selector(timerFire:)
                                          userInfo:[block copy]
                                           repeats:repeats];
}



+ (instancetype)cx_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats fireBlock:(CXTimerFireBlock)block
{
    if (!block) return nil;
    return [NSTimer timerWithTimeInterval:seconds
                                   target:self
                                 selector:@selector(timerFire:)
                                 userInfo:[block copy]
                                  repeats:repeats];
}




+ (void)timerFire:(NSTimer *)timer
{
    CXTimerFireBlock block = timer.userInfo;
    block();
}
















@end
