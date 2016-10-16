//
//  MovieController.h
//  MovieController
//
//  Created by kede on 15/12/29.
//  Copyright © 2015年 miaojinliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MovieController;
@protocol MovieControllerDelegate <NSObject>

- (void)dismiss;

@end
@interface MovieController : UIViewController
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,weak) id<MovieControllerDelegate> delegate;
@end
