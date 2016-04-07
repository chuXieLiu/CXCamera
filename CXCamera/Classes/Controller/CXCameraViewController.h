//
//  CXCameraViewController.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCommonConst.h"

@class CXCameraViewController;

@protocol CXCameraViewControllerDelegate <NSObject>

@optional

/**
 *  没有权限访问摄像头
 */
- (void)cameraNoAccessForMedia;

/**
 *  没有权限访问相册
 */
- (void)cameraNoAccessForPhotosAlbum;

/**
 *  相机配置错误
 */
- (void)cameraDidConfigurateError:(NSError *)error;

/**
 *  结束图片捕捉，当捕捉出错是image为空
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC
          didEndCaptureImage:(UIImage *)image
                       error:(NSError *)error;

/**
 *  捕捉视频，当捕捉出错时video为空
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC
          didEndCaptureVideo:(NSURL *)videoURL
                       error:(NSError *)error;

/**
 *  自动保存图片回调
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC automaticWriteImageToPhotosAlbum:(UIImage *)image
                       error:(NSError *)error;

/**
 *  自动保存视频回调
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC automaticWriteVideoToPhotosAlbumAtPath:(NSURL *)videoURL
                       error:(NSError *)error;

@end


@interface CXCameraViewController : UIViewController

/**
 *  相机类型 CXCameraModePhoto;CXCameraModeVideo
 */
@property (nonatomic,assign) CXCameraMode cameraMode;

/**
 *  是否自动写入相册 , 默认为NO
 */
@property (nonatomic,assign) BOOL automaticWriteToLibary;

/**
 * 相机代理
 */
@property (nonatomic,weak) id<CXCameraViewControllerDelegate> delegate;

/**
 * 最长录制视频时间
 */
@property (nonatomic,assign) NSTimeInterval maxRecordedDuration;

/**
 *  present一个拍照相机控制器
 */
+ (instancetype)presentPhotoCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                        automaticWriteToLibary:(BOOL)automaticWriteToLibary;

/**
 *  present一个录像相机控制器
 */
+ (instancetype)presentVideoCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                           maxRecordedDuration:(NSTimeInterval)maxRecordedDuration
                        automaticWriteToLibary:(BOOL)automaticWriteToLibary;



@end
