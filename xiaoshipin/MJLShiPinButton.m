//
//  MJLShiPinButton.m
//  xiaoshipin
//
//  Created by kede on 16/1/20.
//  Copyright © 2016年 miaojinliang. All rights reserved.
//

#import "MJLShiPinButton.h"

@implementation MJLShiPinButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.enabled = NO;
        self.adjustsImageWhenDisabled = NO;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.];
        self.enabled = NO;
        self.adjustsImageWhenDisabled = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, contentRect.size.height*0.8, contentRect.size.width, contentRect.size.height*0.2);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.height*0.7);

}
@end
