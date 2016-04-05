//
//  CXVideoEditView.h
//  CXCamera
//
//  Created by c_xie on 16/4/4.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CXCameraRecordAgainBlock)();  // 重拍
typedef void(^CXCameraEmployVideoBlock)();  // 使用视频

@interface CXVideoEditView : UIView

+ (instancetype)showVideoEditViewWithVideoURL:(NSURL *)videoURL
                             recordAgainBlock:(CXCameraRecordAgainBlock)recordAgainBlock
                             employVideoBlock:(CXCameraEmployVideoBlock)employVideoBlock;

@end
