//
//  AVAsset+Extension.m
//  CXCamera
//
//  Created by c_xie on 16/3/23.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "AVAsset+Extension.h"
#import <AVFoundation/AVFoundation.h>

static NSString *kAVAssetPropertyCommonMetadata = @"commonMetadata";

@implementation AVAsset (Extension)

/**
 *  获取资源标题
 */
- (NSString *)title
{
    AVKeyValueStatus status =
    [self statusOfValueForKey:kAVAssetPropertyCommonMetadata error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items =
        [AVMetadataItem metadataItemsFromArray:self.commonMetadata
                                       withKey:AVMetadataCommonKeyTitle
                                      keySpace:AVMetadataKeySpaceCommon];
        if (items.count > 0) {
            AVMetadataItem *titleItem = [items firstObject];
            return (NSString *)titleItem.value;
        }
    }
    return nil;
}

@end
