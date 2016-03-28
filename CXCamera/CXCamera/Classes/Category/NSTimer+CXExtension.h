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
 *  创建不重复执行定时器
 *
 *  @param seconds 执行时间段
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                     fireBlock:(CXTimerFireBlock)block;

/**
 *  创建定时器
 *
 *  @param seconds 执行时间段
 *  @param repeats 是否重复执行
 *  @param block   回调块
 *
 *  @return
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                       repeats:(BOOL)repeats
                                     fireBlock:(CXTimerFireBlock)block;

@end
