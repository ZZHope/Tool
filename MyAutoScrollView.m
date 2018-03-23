//
//  MyAutoScrollView.m
//  testScroll
//
//  Created by  淑萍 on 2018/3/23.
//  Copyright © 2018年 huaxiafinance.com. All rights reserved.
//

#import "MyAutoScrollView.h"
#import "UIImageView+WebCache.h"
@interface MyAutoScrollView()<UIScrollViewDelegate>
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIPageControl *pageControl;//指示点,可发挥的余地比较大，只写了默认的样式，可更改
@property(nonatomic,strong) NSMutableArray *imgUrlArrM;
@property(nonatomic,strong) NSTimer *timer;
//@property(nonatomic,assign) NSInteger startPage;
@end

@implementation MyAutoScrollView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        //pageContrl
        /*
         默认样式：宽100，高30 居中显示，距离底部15cm的间距
         */
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((frame.size.width-100)/2.0, (frame.size.height-15-30), 100, 30)];
        self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        [self addSubview:self.pageControl];
    }
    return self;
}
//设置数据
-(void)setImageUrlArr:(NSArray *)imageUrlArr
{
    _imageUrlArr = imageUrlArr;
    if (self.imageUrlArr.count) {
        //前后各加一张后面和第一张
        self.imgUrlArrM = [NSMutableArray arrayWithArray:imageUrlArr];
        [self.imgUrlArrM insertObject:[self.imageUrlArr lastObject] atIndex:0];
        [self.imgUrlArrM addObject:[self.imageUrlArr firstObject]];
        //scrollView设置
        //避免重复添加清空scrollView的子试图
        [self.scrollView.subviews respondsToSelector:@selector(removeAllObjects)];
        self.scrollView.contentSize = CGSizeMake(self.imgUrlArrM.count*CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        for (int i=0;i<self.imgUrlArrM.count;i++) {
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.scrollView.frame), 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
            [imgView sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArrM[i]] placeholderImage:nil];
            [self.scrollView addSubview:imgView];
        }
        //默认显示第零张
        [self.scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        self.pageControl.numberOfPages = self.imageUrlArr.count;
        [self startTimer];
    }
    
}
//pageControl
-(void)setPageIndicateColor:(UIColor *)pageIndicateColor
{
    _pageIndicateColor = pageIndicateColor;
     self.pageControl.currentPageIndicatorTintColor = self.pageIndicateColor;
}
#pragma mark --- 自动轮播
//开始自动轮播
-(void)startTimer
{
    if (!self.timer) {
        //此方法初始化timer已自动加到了runloop中
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.scrollTime>0?self.scrollTime:5 target:self selector:@selector(timeGoGoGo:) userInfo:nil repeats:YES];
    }
    
}
//自动滚动---只能朝一个方向
-(void)timeGoGoGo:(NSTimer*)timer
{
    CGPoint point = CGPointZero;
    if (self.scrollView.contentOffset.x<(self.imgUrlArrM.count-1)*CGRectGetWidth(self.scrollView.frame)) {
        point = CGPointMake(self.scrollView.contentOffset.x+CGRectGetWidth(self.scrollView.frame), 0);
        [UIView animateWithDuration:3 animations:^{
            [self.scrollView setContentOffset:point animated:YES];
        }];
    }else{
        point = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        [self.scrollView setContentOffset:point];
    }
    
}
-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark -- scrollDelegate
//手动拖拽
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x>=(self.imgUrlArrM.count-1)*CGRectGetWidth(self.scrollView.frame)) {//显示第一张图片
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    }
    if (scrollView.contentOffset.x <= 0) {//显示最后一张
        [scrollView setContentOffset:CGPointMake((self.imgUrlArrM.count - 2) *CGRectGetWidth(self.scrollView.frame), 0) animated:NO];
    }
    self.pageControl.currentPage =(NSInteger)(scrollView.contentOffset.x-scrollView.bounds.size.width)/CGRectGetWidth(self.scrollView.frame);
    
}
@end
