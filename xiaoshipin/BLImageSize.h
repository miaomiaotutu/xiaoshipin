//
//  BLImageSize.h
//  瀑布流练习
//
//  Created by mac on 16/1/6.
//  Copyright © 2016年 丁志杰 --- 银泰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BLImageSize : NSObject

// 单例类
+ (instancetype)sharedImageSize;

// 计算网络图片的尺寸
+ (CGSize)dowmLoadImageSizeWithURL:(id)imageURL;

@end