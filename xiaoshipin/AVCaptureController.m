//
//  AVCaptureController.m
//  xiaoshipin
//
//  Created by kede on 15/12/3.
//  Copyright © 2015年 miaojinliang. All rights reserved.
//

#import "AVCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MoviesTableController.h"
#import "MJLShipinHomeController.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#define MaxRecordedTime 8.f
@interface AVCaptureController ()<AVCaptureFileOutputRecordingDelegate>
@property (nonatomic,strong) AVCaptureMovieFileOutput *output;
@property (nonatomic,weak) UIProgressView *progress;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *inputVideo;
@property (nonatomic,strong) MPMoviePlayerController *movieController;

@end

@implementation AVCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"视频" style:UIBarButtonItemStylePlain target:self action:@selector(jumpFabu)];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    self.inputVideo = inputVideo;
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    AVCaptureMovieFileOutput *output = [[AVCaptureMovieFileOutput alloc] init];
    output.maxRecordedDuration = CMTimeMakeWithSeconds(MaxRecordedTime,30);

    self.output = output;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    if ([session canAddInput:inputVideo]) {
        [session addInput:inputVideo];
    }
    if ([session canAddInput:inputAudio]) {
        [session addInput:inputAudio];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }

    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-250);
    [self.view.layer addSublayer:preLayer];
    [session startRunning];

    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, 250)];
    backview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backview];
    UIView *alertLab = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-300, self.view.frame.size.width, 48)];
    alertLab.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:alertLab];
    UILabel *label = [[UILabel alloc]initWithFrame:alertLab.bounds];
    label.text = @"对准有趣的画面，开始拍摄";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [alertLab addSubview:label];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width-100)/2.0, (250-100)/2.0, 100, 100);
    [button setTitle:@"按住拍" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:@"paishe_normal"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"paishe_selected"] forState:UIControlStateHighlighted];
    button.tag = 100;
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(end:) forControlEvents:UIControlEventTouchUpInside];
    [backview addSubview:button];
    
    
    
    
    UIButton *deletebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    deletebutton.frame = CGRectMake(30, (250-100)/2.0+15, 70, 70);
    [deletebutton setImage:[UIImage imageNamed:@"shipinshanchu"] forState:UIControlStateNormal];
    deletebutton.tag = 200;

    [deletebutton addTarget:self action:@selector(end:) forControlEvents:UIControlEventTouchUpInside];
    [backview addSubview:deletebutton];

    
    
    UIButton *nextbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextbutton.tag = 300;

    nextbutton.frame = CGRectMake(self.view.frame.size.width-100, (250-100)/2.0+15, 70, 70);
    [nextbutton setImage:[UIImage imageNamed:@"shipinnext"] forState:UIControlStateNormal];
    [nextbutton addTarget:self action:@selector(end:) forControlEvents:UIControlEventTouchUpInside];
    [backview addSubview:nextbutton];

    
    
    
    
    
    UIProgressView *progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    progress.trackTintColor = [UIColor grayColor];
    progress.progressTintColor = [UIColor greenColor];
    progress.transform = CGAffineTransformMakeScale(1.0, 3.0);  ;
    [backview addSubview:progress];
    self.progress = progress;
    
    UIButton *changeCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    changeCamera.frame = CGRectMake(self.view.frame.size.width-50, 100, 35, 35);
    [changeCamera setImage:[UIImage imageNamed:@"record_lensflip_normal"] forState:UIControlStateNormal];
    [changeCamera setImage:[UIImage imageNamed:@"record_lensflip_highlighted"] forState:UIControlStateSelected];
    [changeCamera addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeCamera];
    
    UIButton *changeFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    changeFlash.frame = CGRectMake(self.view.frame.size.width-50, 180, 35, 35);
    [changeFlash setImage:[UIImage imageNamed:@"record_flashlight_disable"] forState:UIControlStateNormal];
    [changeFlash setImage:[UIImage imageNamed:@"record_flashlight_highlighted"] forState:UIControlStateSelected];
    [changeFlash addTarget:self action:@selector(changeFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeFlash];
}


- (void)jumpFabu
{
    MJLShipinHomeController *mhc = [[MJLShipinHomeController alloc]init];
    [self.navigationController pushViewController:mhc animated:YES];
}

- (void)changeFlash:(UIButton *)btn
{
    btn.selected = !btn.selected;
    AVCaptureTorchMode torchMode;
    if (btn.selected) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });


}
- (void)changeCamera:(UIButton *)btn
{

    btn.selected = !btn.selected;
    [_session beginConfiguration];
    [_session removeInput:self.inputVideo];

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = nil;
    if (btn.selected) {
        device = [devices lastObject];

    }else{
        device = [devices firstObject];

    }
    
    self.inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];

    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    if ([_session canAddInput:_inputVideo]) {
        [_session addInput:_inputVideo];
    }

    [_session commitConfiguration];

}
- (void)start:(UIButton *)btn {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myVidio.mov"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.output startRecordingToOutputFileURL:url recordingDelegate:self];
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(changeProgress) userInfo:nil repeats:YES];
        [self.timer fire];
    }
   
}

- (void)end:(UIButton *)btn
{
    if (btn.tag == 100) {
        if ([self.output isRecording]) {
            [self.output stopRecording];
        }
        
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }

    }
    
    if (btn.tag == 200) {
        [self.output stopRecording];
        [self.progress setProgress:0. animated:YES];

    }
    
    
    if (btn.tag == 300) {
        MoviesTableController *mvc = [[MoviesTableController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mvc];
        [self presentViewController:nav animated:YES completion:^{
            [self.progress setProgress:0. animated:YES];

        }];

        
    }
    
    
    
    }

- (void)changeProgress
{
    [self.progress setProgress:CMTimeGetSeconds(self.output.recordedDuration)/CMTimeGetSeconds(self.output.maxRecordedDuration) animated:YES];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"%lld",self.output.recordedFileSize/(1024*1024));
    
    self.movieController = [[MPMoviePlayerController alloc]initWithContentURL:outputFileURL];
        [self.movieController requestThumbnailImagesAtTimes:@[@1.0] timeOption:MPMovieTimeOptionNearestKeyFrame];
    self.movieController.shouldAutoplay = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(capthce:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.mov",arc4random()%1000000]];
    NSURL *url = [NSURL fileURLWithPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    [self lowQuailtyWithInputURL:outputFileURL outputURL:url blockHandler:^(AVAssetExportSession *session)
     {
         
//         if (session.status == AVAssetExportSessionStatusCompleted)
//         {
//             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//             [library writeVideoAtPathToSavedPhotosAlbum:url
//                                         completionBlock:^(NSURL *assetURL, NSError *error) {
//                                             if (error) {
//                                                 NSLog(@"Save video fail:%@",error);
//                                             } else {
//                                                 NSLog(@"Save video succeed.");
//                                                 [self dismissViewControllerAnimated:YES completion:^{
//                                                     NSLog(@"完成录制,退回来");
//                                                     
//                                                 }];
//                                             }
//                                         }];
//             
//         }
//         else
//         {
//             
//         }
         NSData *data = [NSData dataWithContentsOfURL:url];
         [data writeToFile:path atomically:YES];
         dispatch_async(dispatch_get_main_queue(), ^{
             MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             hud.labelText = @"保存成功";
             hud.removeFromSuperViewOnHide = YES;
             hud.dimBackground = YES;
             [hud hide:YES afterDelay:0.5];
         });
         
     }];
}


- (void)capthce:(NSNotification *)noti
{
    NSLog(@"%@",noti.userInfo);
    
}

- (void) lowQuailtyWithInputURL:(NSURL*)inputURL
                      outputURL:(NSURL*)outputURL
                   blockHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset     presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    session.shouldOptimizeForNetworkUse = YES;

    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
     }];
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
