//
//  CXCameraManager.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CXCameraManagerDelegate <NSObject>

@optional

- (void)cameraConfigurateFailed:(NSError *)error;

@end


@interface CXCameraManager : NSObject

@property (nonatomic,weak) id<CXCameraManagerDelegate> delegate;

/**
 *  创建会话，捕捉场景活动
 */
- (BOOL)setupSession:(NSError **)error;

/**
 *  启动会话
 */
- (void)startSession;

/**
 *  停止会话
 */
- (void)stopSession;


/**
 *  是否支持切换摄像头
 */
- (BOOL)canSwitchCamera;

/**
 *  切换摄像头
 */
- (BOOL)switchCamera;


/**
 *  对焦
 */
- (void)focusAtPoint:(CGPoint)point;

















@end
