//
//  CXShutterButton.h
//  CXCamera
//
//  Created by c_xie on 16/3/26.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CXShutterButtonModePhoto,
    CXShutterButtonModeVideo,
} CXShutterButtonMode;

@interface CXShutterButton : UIButton

@property (nonatomic,assign) CXShutterButtonMode shutterButtonMode;

@end
