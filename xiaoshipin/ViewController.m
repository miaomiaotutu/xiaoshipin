//
//  ViewController.m
//  xiaoshipin
//
//  Created by kede on 15/12/3.
//  Copyright © 2015年 miaojinliang. All rights reserved.
//

#import "ViewController.h"
#import "AVCaptureController.h"
@interface ViewController ()
- (IBAction)start:(UIButton *)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(UIButton *)sender {
    AVCaptureController *avc = [[AVCaptureController alloc]init];
    [self.navigationController pushViewController:avc animated:YES];
   }

@end
