//
//  MoviesTableController.m
//  xiaoshipin
//
//  Created by kede on 16/1/5.
//  Copyright © 2016年 miaojinliang. All rights reserved.
//

#import "MoviesTableController.h"
#import "MovieController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MoviesTableController ()<MovieControllerDelegate>
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *urls;
@property (nonatomic,strong) MPMoviePlayerController *movieController;
@property (nonatomic,strong) NSMutableArray *ThumbnailImages;

@end

@implementation MoviesTableController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(fanhui)];
    self.title = @"我的酷拍";
    self.urls = [NSMutableArray array];
    self.dataArr = [NSMutableArray array];
    self.ThumbnailImages = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.rowHeight = 100.;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDirectoryEnumerator *Enumerator = [[NSFileManager defaultManager] enumeratorAtPath:document];
    NSString *filename;
   
        
        while ( filename = [Enumerator nextObject]) {
            if ([[filename pathExtension] isEqualToString:@"mov"]) {
                if (![filename isEqualToString:@"myVidio.mov"]) {
                    NSString *temp = [document stringByAppendingPathComponent:filename];
                    double a = (double)[[[NSFileManager defaultManager] attributesOfItemAtPath:temp error:nil] fileSize]/(1024*1024);
                    NSLog(@"%@---%.2f",filename,a);
                    [self.dataArr addObject:[NSString stringWithFormat:@"%@----%.2fMB",filename,a]];
                    NSURL *tempurl = [NSURL fileURLWithPath:temp];
                    [self.urls addObject:tempurl];
                    [self.ThumbnailImages addObject:[self thumbnailImageForVideo:tempurl atTime:1.0]];
                }
            }
        }
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    cell.textLabel.text = _dataArr[indexPath.row];
    cell.imageView.image = self.ThumbnailImages[indexPath.row];

    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   [[NSFileManager defaultManager] removeItemAtURL:self.urls[indexPath.row] error:nil];
    [self.urls removeObjectAtIndex:indexPath.row];
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [self.ThumbnailImages removeObjectAtIndex:indexPath.row];
    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
}


- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

- (void)fanhui
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];

    
    MovieController *mc = [[MovieController alloc]init];
    mc.delegate = self;
    mc.url = self.urls[indexPath.row];
    [self presentViewController:mc animated:YES completion:^{

    }];

    
    
   }

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
