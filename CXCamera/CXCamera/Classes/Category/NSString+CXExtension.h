//
//  NSString+CXExtension.h
//  CXCamera
//
//  Created by c_xie on 16/3/28.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CXExtension)

/**
 * 拼接文档目录
 */
- (NSString *)appendDocumentPath;

/**
 * 拼接缓存目录
 */
- (NSString *)appendCachePath;

/**
 * 拼接临时目录
 */
- (NSString *)appendTempPath;

@end
