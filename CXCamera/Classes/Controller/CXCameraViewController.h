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
 *  结束图片捕捉，当捕捉出错时image为空
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
- (void)cameraViewController:(CXCameraViewController *)cameraVC finishWriteImageToPhotosAlbum:(UIImage *)image
                       error:(NSError *)error;

/**
 *  自动保存视频回调
 */
- (void)cameraViewController:(CXCameraViewController *)cameraVC finishWriteVideoToPhotosAlbumAtPath:(NSURL *)videoURL
                       error:(NSError *)error;

/**
 *  关闭相机回调
 */
- (void)cameraViewControllerDidDismiss:(CXCameraViewController *)cameraVC;

@end


@interface CXCameraViewController : UIViewController

/**
 * 相机代理
 */
@property (nonatomic,weak,readwrite) id<CXCameraViewControllerDelegate> delegate;

/**
 *  相机类型 CXCameraModePhoto;CXCameraModeVideo
 */
@property (nonatomic,assign,readwrite) CXCameraMode cameraMode;

/**
 * 最长录制时间，当置为0或者CGFLOAT_MAX时可以不受时间限制
 */
@property (nonatomic,assign,readwrite) NSTimeInterval maxRecordedDuration;

/**
 *  是否自动写入相册 , 默认为NO
 */
@property (nonatomic,assign,readwrite,getter=isAutomaticWriteToLibary) BOOL automaticWriteToLibary;

/**
 * 当设备检测到亮度变化（lighting lighting）或大范围活动（substantial movement）时， 会重新以中心点开始自动连续对焦与曝光,默认为NO
 */
@property (nonatomic,assign,readwrite,getter=isAutoFocusAndExpose) BOOL autoFocusAndExpose;


/**
 *	present一个拍照相机控制器
 *
 *	@param	delegate  相机代理
 *
 *  @param	automaticWriteToLibary	是否自动写入相册
 *
 *  @param	autoFocusAndExpose	当亮度或者场景变化时是否重新对焦曝光
 *
 *	@return	相机控制器
 */
+ (instancetype)presentPhotoCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                        automaticWriteToLibary:(BOOL)automaticWriteToLibary
                            autoFocusAndExpose:(BOOL)autoFocusAndExpose;

/**
 *	present一个录像相机控制器
 *
 *	@param	delegate	相机代理
 *
 *  @param	maxRecordedDuration	最长录制时间，当置为0或者CGFLOAT_MAX时可以不受时间限制
 *
 *  @param	automaticWriteToLibary	是否自动写入相册
 *
 *  @param	autoFocusAndExpose	当亮度或者场景变化时是否重新对焦曝光
 *
 *	@return	相机控制器
 */
+ (instancetype)presentVideoCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                           maxRecordedDuration:(NSTimeInterval)maxRecordedDuration
                        automaticWriteToLibary:(BOOL)automaticWriteToLibary
                            autoFocusAndExpose:(BOOL)autoFocusAndExpose;



@end
