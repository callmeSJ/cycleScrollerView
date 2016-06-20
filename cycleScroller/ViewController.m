//
//  ViewController.m
//  cycleScroller
//
//  Created by SJ on 16/6/17.
//  Copyright © 2016年 SJ. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
//滑动视图
@property(nonatomic,strong)UIScrollView *scrollerView;
//分页控制器
@property(nonatomic,strong)UIPageControl *pageControl;
//覆盖页面
@property(nonatomic,strong)UIView *coverView;
//详细图片
@property(nonatomic,strong)UIImageView *detailImageView;
//定时器
@property(nonatomic,strong)NSTimer *timer;
//图片数组
@property(nonatomic,strong)NSArray *imageNameArray;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createView];
    
}

-(void)createView{
    _imageNameArray = @[@"scroll1",@"scroll2",@"scroll3",@"scroll4"];

    [self createScroller];
    [self creatDetail];
    [self createTimer];
}
#pragma 创建ScollerView和PageControl
-(void)createScroller{
    //根据图片比例计算高度，本地图片可以用这种方法，网络图片再议。
    CGFloat height = 803*kScreenWidth/1600;
    _scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    _scrollerView.showsVerticalScrollIndicator = NO;
    _scrollerView.showsHorizontalScrollIndicator = NO;
    _scrollerView.contentSize = CGSizeMake(kScreenWidth*(_imageNameArray.count + 2), height);
    _scrollerView.pagingEnabled = YES;
    _scrollerView.userInteractionEnabled = YES;
    _scrollerView.bounces = NO;
    _scrollerView.delegate = self;
    [self.view addSubview:_scrollerView];
    
    
    //加图像
    
    for (int i = 0 ; i < _imageNameArray.count + 2; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[self getImageStrWithIndex:i] ofType:@"jpg"];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, height)];
        imageView.image = [UIImage imageWithContentsOfFile:path];
        imageView.tag = 100 + i;
        imageView.userInteractionEnabled = YES;
        [_scrollerView addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailImage:)];
        
        [imageView addGestureRecognizer:tap];
    }
    _scrollerView.contentOffset = CGPointMake(kScreenWidth, 0);
    
    
    //添加pageControll
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, height - 40, kScreenWidth, 20)];
    _pageControl.backgroundColor = [UIColor blackColor];
    _pageControl.alpha = 0.5;
    _pageControl.numberOfPages = _imageNameArray.count;
    _pageControl.currentPage = 0;
    _pageControl.pageIndicatorTintColor = [UIColor redColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
    [_pageControl addTarget:self action:@selector(scrollImage:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview: _pageControl];
    
}

#pragma mark 创建coverView
-(void)creatDetail{
    _coverView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.hidden = YES;
    _coverView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelDetail:)];
    [_coverView addGestureRecognizer:tap];
    [self.view addSubview:_coverView];
    
    _detailImageView = [[UIImageView alloc]initWithFrame:_scrollerView.frame];
    _detailImageView.hidden = YES;
    [self.view addSubview:_detailImageView];
    
    
}

#pragma mark 获取每页对应的图片字符串
-(NSString *)getImageStrWithIndex:(NSInteger)index{
    NSString *imageStr;
    if(index == 0){
        imageStr = _imageNameArray.lastObject;
    }else if(index == _imageNameArray.count + 1){
        imageStr = _imageNameArray.firstObject;
    }else{
        imageStr = _imageNameArray[index - 1];
    }
    return imageStr;
    
}

-(void)detailImage:(UIGestureRecognizer *)tap{
    NSInteger index = tap.view.tag - 100;
    _coverView.hidden = NO;
    NSString *path = [[NSBundle mainBundle]pathForResource:[self getImageStrWithIndex:index] ofType:@"jpg"];
    _detailImageView.image = [UIImage imageWithContentsOfFile:path];
    _detailImageView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _detailImageView.center = self.view.center;
        _coverView.alpha = 0.8;
        
    }];
    
    
}

#pragma 取消详情界面
-(void)cancelDetail:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 0;
        _detailImageView.center = CGPointMake(_detailImageView.center.x, _detailImageView.frame.size.height*0.5+kScreenHeight);
    } completion:^(BOOL finished) {
        _coverView.hidden = YES;
        _detailImageView.hidden = YES;
        _detailImageView.image = nil;
        _detailImageView.frame = _scrollerView.frame;
    }];
}


#pragma 滑动图片
-(void)scrollImage:(id)sender{
    if(sender == _pageControl){
        [_scrollerView setContentOffset:CGPointMake((_imageNameArray.count + 1)*kScreenWidth, 0) animated:YES];
    }else if(sender == _timer){
        CGPoint point = _scrollerView.contentOffset;
        point.x = point.x + kScreenWidth;
        [_scrollerView setContentOffset:point animated:YES];
        
    }
    
    
    
}


#pragma mark scrollerView代理

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger index = _scrollerView.contentOffset.x / kScreenWidth;
    if(index == 0){
        _scrollerView.contentOffset = CGPointMake(_imageNameArray.count * kScreenWidth, 0);
        _pageControl.currentPage = _imageNameArray.count - 1;
    }else if(index == _imageNameArray.count + 1){
        _scrollerView.contentOffset = CGPointMake(kScreenWidth, 0);
        _pageControl.currentPage = 0 ;
    
    }else{
        _pageControl.currentPage = index - 1;
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:_scrollerView];
}

#pragma mark 创建定时器
-(void)createTimer{
    if(_timer != nil){
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(scrollImage:) userInfo:nil repeats:YES];
}
-(void)dealloc{
    [_timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
