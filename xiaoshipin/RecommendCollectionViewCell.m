//
//  RecommendCollectionViewCell.m
//  Wendao
//
//  Created by lanou3g on 15/10/22.
//  Copyright (c) 2015年 Jyp. All rights reserved.
//

#import "RecommendCollectionViewCell.h"
#import "UIImage+MultiFormat.h"
#import "UIImageView+WebCache.h"
@interface RecommendCollectionViewCell ()

@property (strong, nonatomic)UIImageView *MyImage;
@property (nonatomic,strong)UILabel * myTitle;
@property (nonatomic,strong)UIImageView * zan;
@property (nonatomic,strong)UIImageView * touxiang;
@property (nonatomic,strong)UIImageView * hongbao;
@property (nonatomic,strong)UIView * sepreatr;


@property (nonatomic,strong)NSData * data;

@end

@implementation RecommendCollectionViewCell

- (void)setModel:(Recommend *)model
{
    [self.MyImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"1.png"]];
    self.myTitle.text = [NSString stringWithFormat:@"%d",arc4random()%100000+100];
//    [self.touxiang sd_setImageWithURL:[NSURL URLWithString:model.headline_img] placeholderImage:[UIImage imageNamed:@"1.png"]];

    [self.touxiang sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"1.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"%@",NSStringFromCGSize(image.size));
    }];
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _MyImage = [[UIImageView alloc]init];
        [self.contentView addSubview:_MyImage];
        
        _myTitle = [[UILabel alloc]init];
        _myTitle.textColor = [UIColor lightGrayColor];
        _myTitle.font = [UIFont systemFontOfSize:14.];
        [self.contentView addSubview:_myTitle];
        
        _touxiang = [[UIImageView alloc]init];
        [self.contentView addSubview:_touxiang];
        
        
        _hongbao = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shipinhongbao"]];
        [self.contentView addSubview:_hongbao];
        
        
        _zan = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"zan"]];
        [self.contentView addSubview:_zan];
        
        _sepreatr = [[UIView alloc]init];
        _sepreatr.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:_sepreatr];
        
    }
    return self;
}

// 自定义Layout
-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    CGFloat width = layoutAttributes.frame.size.width;
    CGFloat height = layoutAttributes.frame.size.height;
    _MyImage.frame = CGRectMake(0, 0, width, height-40);
    _touxiang.frame = CGRectMake(10, height-55, 40, 40);
    _hongbao.frame = CGRectMake(CGRectGetMaxX(_touxiang.frame)-10, height-30, 20, 20);
    _zan.frame = CGRectMake(width-70, height-35, 20, 20);
    _myTitle.frame = CGRectMake(CGRectGetMaxX(_zan.frame), height-35, 50, 20);
    _sepreatr.frame = CGRectMake(0, height-5, width, 5);
    
}








//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    
//    self.MyImage.image = nil;
//    
//    self.MyImage.frame = self.contentView.bounds;
//}
//


@end