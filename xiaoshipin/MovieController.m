//
//  MovieController.m
//  MovieController
//
//  Created by kede on 15/12/29.
//  Copyright © 2015年 miaojinliang. All rights reserved.
//

#import "MovieController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MovieController ()
@property (nonatomic,strong) MPMoviePlayerController *movieController;
@end

@implementation MovieController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"播放视频";
    self.movieController = [[MPMoviePlayerController alloc]initWithContentURL:self.url];
    [self.view addSubview:self.movieController.view];
    self.movieController.controlStyle = MPMovieControlStyleFullscreen;
    self.movieController.view.frame = self.view.bounds;
   // [self.movieController play];
    [self.movieController requestThumbnailImagesAtTimes:@[@1.0] timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Playfinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(capthce:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];

    
}

- (void)capthce:(NSNotification *)noti
{
    NSLog(@"%@",noti.userInfo);
}

- (void)Playfinished:(NSNotification *)noti
{
    NSLog(@"播放完成");
    if ([self.delegate respondsToSelector:@selector(dismiss)]) {
        [self.delegate dismiss];
    }
   
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.movieController setFullscreen:YES animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
