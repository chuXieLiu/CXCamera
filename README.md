# CXCamera
纯OC，基于AVFoundation实现的轻量级相机框架，自定义UI界面，不依赖任何第三方库!
### 已实现功能

* 支持摄像头切换，可捕捉图片与录制视频
* 支持点按手势对焦曝光
* 支持曝光模式的控制与手电筒模式
* 支持捏合手势平滑缩放预览视频
* 支持写入相册
* 支持相片预览与视频播放


### 效果截图

* 拍照

![](https://github.com/chuXieLiu/CXCamera/blob/master/capturePhotoDemo.png?raw=true">)

* 录像

![](https://github.com/chuXieLiu/CXCamera/blob/master/capturePhotoDemo.png?raw=true">)


* 播放录制的视频

![](https://github.com/chuXieLiu/CXCamera/blob/master/capturePhotoDemo.png?raw=true">)

###系统支持

* IOS 7.0+
* Xcode 7.3

###使用

* 导入框架
	
	将二级目录中的CXCamera文件夹拖拽进自己的工程，导入头文件

```objc
 #import "CXCamera.h"
```

* 调用CXCameraViewController的类方法，present一个相机控制器

```objc
+ (instancetype)showCameraWithDelegate:(id<CXCameraViewControllerDelegate>)delegate
                            cameraMode:(CXCameraMode)cameraMode
                automaticWriteToLibary:(BOOL)automaticWriteToLibary;
```

cameraMode 为相机功能模式，分别为

	拍照模式 ： CXCameraModePhoto
	录像模式 ： CXCameraModeVideo

automaticWriteToLibary 为是否自动写入相册，当按下快门时会自动将捕捉的照片或音频写入相册，默认为NO，不开启。

CXCameraViewControllerDelegate 定义了可遵守的协议，

捕捉图片回调

```objc
- (void)cameraViewController:(CXCameraViewController *)cameraVC didCaptureImage:(UIImage *)image;
```

捕捉视频回调

```objc
- (void)cameraViewController:(CXCameraViewController *)cameraVC didCaptureVideo:(NSURL *)videoURL
```
## 联系
* 发现问题，请您Issues Me，O(∩_∩)O 谢谢
* 如果您有什么好的建议或需求请Email Me ^_^
* Email ：c_xieliu@163.com






















