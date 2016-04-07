//
//  NSTimer+CXExtension.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CXTimerFireBlock)();

@interface NSTimer (CXExtension)

/**
 *  创建不重复执行定时器，会自动添加到runloop，只会在当前的runLoop调度，如果在子线程启动，需要同时启动子线程的runloop
 *
 *  @param seconds 执行时间段
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)cx_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                     fireBlock:(CXTimerFireBlock)block;

/**
 *  创建不重复执行定时器，需要手动添加到runloop才会执行
 *
 *  @param seconds 执行时间段
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)cx_timerWithTimeInterval:(NSTimeInterval)seconds
                               fireBlock:(CXTimerFireBlock)block;

/**
 *  创建定时器，只会在当前的runLoop调度
 *
 *  @param seconds 执行时间段
 *  @param repeats 是否重复执行
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)cx_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                       repeats:(BOOL)repeats
                                     fireBlock:(CXTimerFireBlock)block;

+ (instancetype)cx_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats fireBlock:(CXTimerFireBlock)block;

@end
