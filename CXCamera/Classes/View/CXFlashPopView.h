//
//  CXFlashPopView.h
//  CXCamera
//
//  Created by c_xie on 16/3/30.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCommonConst.h"
@class CXFlashPopView;
@class CXPopItem;



@protocol CXFlashPopViewDelegate <NSObject>

- (void)flashPopView:(CXFlashPopView *)flashPopView itemDidSelected:(CXPopItem *)item;

@end


#pragma mark - CXPopItem


@interface CXPopItem : NSObject

@property (nonatomic,assign) CXCaptureFlashMode flashMode;

@property (nonatomic,copy) NSString *imageName;

+ (instancetype)popItemWithFalshMode:(CXCaptureFlashMode)flashMode imageName:(NSString *)imageName;

@end


#pragma mark - CXFlashPopView


@interface CXFlashPopView : UIView

@property (nonatomic,assign,getter=isShowing) BOOL showing;

@property (nonatomic,weak) id<CXFlashPopViewDelegate> delegate;

- (instancetype)initWithItems:(NSArray<CXPopItem *> *)items;

- (void)showFromView:(UIView *)from toView:(UIView *)to;
- (void)dismiss;

@end


