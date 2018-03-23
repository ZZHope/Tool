//
//  MyAutoScrollView.h
//  testScroll
//
//  Created by  淑萍 on 2018/3/23.
//  Copyright © 2018年 huaxiafinance.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAutoScrollView : UIView
@property(nonatomic,assign) NSInteger scrollTime;//每张滚动的时间
@property(nonatomic,strong)NSArray *imageUrlArr;//存放imgUrl的数组
@property(nonatomic,strong) UIColor *pageIndicateColor;//pageControl指示颜色
@end
