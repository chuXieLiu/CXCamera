//
//  CXFlashPopView.h
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXFlashPopView : UIView

@property (nonatomic,assign,getter=isShowing) BOOL showing;

- (void)showFromView:(UIView *)from toView:(UIView *)to;
- (void)dismiss;

@end
