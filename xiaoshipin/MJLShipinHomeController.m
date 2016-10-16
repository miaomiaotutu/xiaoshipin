//
//  MJLShipinHomeController.m
//  xiaoshipin
//
//  Created by kede on 16/1/20.
//  Copyright © 2016年 miaojinliang. All rights reserved.
//
#define imageurl @"http://i1.15yan.guokr.cn/u0bk6rs5q79lnochkx3vj1ki18zjcobh.jpg!content"

#define HTTPURL @"http://www.oncould.com/api-bbs-get_pic_list?_json=1?suid=167&securityKey=/08OWTSYDWqgyIFJmT3qBRY2n3K/EQHmaHdaAhURLPzf1eooyFuGutdBphyGZahR7V6fkSzsLgYxRZHLkXG4UVIY7CxrBU1ileqrcRLlVlQnWyezTYZO88GtiiHh4Pwc&pageid=%ld"
//#define HTTPURL @"http://apis.guokr.com/handpick/article.json?limit=%ld&ad=1&category=all&retrieve_type=by_since"

#import "AoiroSoraLayout.h"
#import "Recommend.h"
#import "RecommendCollectionViewCell.h"
#import "UIImage+MultiFormat.h"
#import "UIImageView+WebCache.h"
#import "BLImageSize.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "MJLShipinHomeController.h"
#import "MJLShiPinButton.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MovieController.h"

@interface MJLShipinHomeController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,AoiroSoraLayoutDelegate,MovieControllerDelegate>
@property (nonatomic,weak) UIView *backView;
@property (nonatomic,weak) UIView *warning;
@property (nonatomic,weak) UIScrollView *paomadeng;
@property (nonatomic,assign) CGFloat Paomawidth;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *urls;
@property (nonatomic,strong) MPMoviePlayerController *movieController;
@property (nonatomic,strong) NSMutableArray *ThumbnailImages;


@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic,strong)UIImage * image; // 如果计算图片尺寸失败  则下载图片直接计算
@property (nonatomic,strong)NSMutableArray * heightArray;// 存储图片高度的数组
@property (nonatomic,strong)NSMutableArray * modelArray; //存储 model 类的数组

@property (nonatomic,assign)NSInteger page; // 一次刷新的个数

@property (nonatomic,strong)MBProgressHUD * hud;

@end
static float num = 0;
@implementation MJLShipinHomeController



- (void)p_MBProgressHUD
{
    _hud = [MBProgressHUD showHUDAddedTo:_collectionView animated:YES];
    _hud.dimBackground = YES;// 灰背景  菊花高亮
    _hud.labelText = @"加载中";
    _hud.square = YES;  // 背景矩形宽高一样
    _hud.mode = MBProgressHUDModeIndeterminate; // 菊花样式
    [_hud show:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urls = [NSMutableArray array];
    self.dataArr = [NSMutableArray array];
    self.ThumbnailImages = [NSMutableArray array];
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
                //[self.ThumbnailImages addObject:[self thumbnailImageForVideo:tempurl atTime:1.0]];
            }
        }
    }

    _page = 1;// 初次加载的个数
    
    [self p_collectionView]; // collectionView 布局
    
    // [self p_MBProgressHUD]; 菊花加载
    
    [self p_json];  // json 解析
    
    [self addHeader]; // 下拉刷新
    
    [self addFooter]; // 上拉刷新

    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 110)];
    view.backgroundColor = [UIColor whiteColor];
    self.backView = view;
    [self.view addSubview:view];
    NSArray *titles = @[@"奖励次数",@"单次获利",@"剩余名额",@"剩余奖金"];
    NSArray *numbers = @[@"117",@"20",@"6000",@"784"];

    for (int i = 0; i < 4; i++) {
        MJLShiPinButton *button = [MJLShiPinButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
        button.frame = CGRectMake(i*(self.view.frame.size.width/4.0), 0, self.view.frame.size.width/4.0, 80);
        [view addSubview:button];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i*(self.view.frame.size.width/4.0), 90, self.view.frame.size.width/4.0, 20)];
        label.tag = i+100;
        label.text = numbers[i];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
    }
    
    UIView *laba = [[UIView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 40)];
    self.warning = laba;
    laba.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self.view addSubview:laba];
    
    UIImageView *labaImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    labaImage.image = [UIImage imageNamed:@"shipinlaba"];
    [laba addSubview:labaImage];
    
    UIScrollView *paomadeng = [[UIScrollView alloc]initWithFrame:CGRectMake(50, 5, self.view.frame.size.width-50, 30)];
    self.paomadeng = paomadeng;
    NSString *str = @"酷得app主要服务目标为城市品牌定位,老字号,真正实现C2B线下主打提高消费群体的积极性... 酷得交流一群 189282437酷得网络科技群1 酷得交流二群 427177119";
    CGFloat width = [str sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.]}].width;
    paomadeng.contentSize = CGSizeMake(width, 30);
    self.Paomawidth = width;
    UILabel *paomadengLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
    paomadengLab.textColor = [UIColor orangeColor];
    paomadengLab.text = str;
    [paomadeng addSubview:paomadengLab];
   NSTimer *timerName = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changePaomadeng) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timerName forMode:NSRunLoopCommonModes];
    [laba addSubview:paomadeng];
}

- (void)changePaomadeng
{
    num += 5;
    if (num >= self.Paomawidth-(self.view.frame.size.width-50)) {
        num = 0;
    }
    [self.paomadeng setContentOffset:CGPointMake(num, 0) animated:NO];
}

// 懒加载数组
- (NSMutableArray *)heightArray
{
    if (_heightArray == nil) {
        _heightArray = [NSMutableArray array];
    }
    return _heightArray;
}

// 懒加载数组
- (NSMutableArray *)modelArray
{
    if (_modelArray == nil) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

#pragma mark -- 下拉刷新
- (void)addHeader
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加下拉刷新头部控件
    [self.collectionView addHeaderWithCallback:^{
        // 进入刷新状态就会调这个Block
        
        
        // 模拟延迟加载数据,因此2秒后才调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 结束刷新
            [vc.collectionView headerEndRefreshing];
        });
    }];
#pragma mark -- 自动刷新--进入程序就下拉刷新
    [self.collectionView headerBeginRefreshing];
}

#pragma mark -- 上拉刷新
- (void)addFooter
{
    __unsafe_unretained typeof(self)vc = self;
    // 添加上拉刷新尾部控件
    [self.collectionView addFooterWithCallback:^{
        // 添加刷新状态就会回调这个block
        vc.page = vc.page + 1;
        NSString * str = [NSString stringWithFormat:HTTPURL,(long)vc.page];
        
        NSURL * url = [NSURL URLWithString:str];
        // 创建请求对象
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        // 发送请求
        NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            [vc.modelArray removeAllObjects];
            [vc.heightArray removeAllObjects];
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            for (NSDictionary * d in [dict objectForKey:@"list"]) {
                Recommend * m = [[Recommend alloc]init];
                [m setValuesForKeysWithDictionary:d];
                
                [vc.modelArray addObject:m];
                
                [vc p_putImageWithURL:m.pic];
            }
            
            // 模拟延迟加载数据
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 判断图片高度数组的个数  是否已经全部计算完成
                // 完成则结束刷新
                if (vc.heightArray.count == vc.page) {
                    [vc.collectionView reloadData];
                    
                    [vc.collectionView footerEndRefreshing];
                }
                
            });
            
        }];
        
        [dataTask resume]; // 开始请求
        
    }];
    
    
}



#pragma mark -- json解析  初次加载
- (void)p_json
{
    NSString * str = [NSString stringWithFormat:HTTPURL,(long)_page];
    
    NSURL * url = [NSURL URLWithString:str];
    // 创建请求对象
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    // 发送请求
    NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!error) {
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            for (NSDictionary * d in [dict objectForKey:@"list"]) {
                Recommend * m = [[Recommend alloc]init];
                [m setValuesForKeysWithDictionary:d];
                
                [self.modelArray addObject:m];
                
                [self p_putImageWithURL:m.pic];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_collectionView reloadData];
        });
        
        
    }];
    
    [dataTask resume]; // 开始请求
}


#pragma mark -- 获取 图片 和 图片的比例高度
- (void)p_putImageWithURL:(NSString *)url
{
    // 获取图片
    CGSize  size = [BLImageSize dowmLoadImageSizeWithURL:url];
    
    // 获取图片的高度并按比例压缩
    CGFloat itemHeight = (size.height+arc4random()%200+arc4random()%300) * (((self.view.frame.size.width - 20) / 2.0 / size.width));
    
    NSNumber * number = [NSNumber numberWithDouble:itemHeight+40];
    
    [self.heightArray addObject:number];
    
}


#pragma mark -- collectionView 布局
- (void)p_collectionView
{
    
    AoiroSoraLayout * layout = [[AoiroSoraLayout alloc]init];
    layout.interSpace = 5; // 每个item 的间隔
    layout.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.colNum = 2; // 列数;
    layout.delegate = self;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 240, self.view.frame.size.width, self.view.frame.size.height-240) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [_collectionView registerClass:[RecommendCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_collectionView];
}

#pragma mark -- 返回每个item的高度
- (CGFloat)itemHeightLayOut:(AoiroSoraLayout *)layOut indexPath:(NSIndexPath *)indexPath
{
    
    if ([self.heightArray[indexPath.row] doubleValue] < 0 || !self.heightArray[indexPath.row]) {
        
        return 150.;
    }else{
        CGFloat intger = [self.heightArray[indexPath.row] doubleValue];
        return intger;
    }
    
}

#pragma mark -- collectionView 的分组个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -- item 的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

#pragma mark -- cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    Recommend * model = self.modelArray[indexPath.row];
    cell.model = model;
    return cell;
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark -- 选中某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MovieController *mc = [[MovieController alloc]init];
    mc.delegate = self;
    NSInteger index = arc4random()%self.urls.count;
    mc.url = self.urls[index];
    [self presentViewController:mc animated:YES completion:^{
        
    }];

}



@end
