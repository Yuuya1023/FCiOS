//
//  CustomSettingViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSettingPageView.h"

@interface CustomSettingViewController : UIViewController<UIScrollViewDelegate>{
    
    UILabel *titleLabel;
    UIScrollView *pageView_;
    UIPageControl *pageControl;
    int prePageNum;
    UIImageView *bg;
    int currentPlayStyle;
    
    CustomSettingPageView *page1;
    CustomSettingPageView *page2;
    CustomSettingPageView *page3;
    CustomSettingPageView *page4;
    CustomSettingPageView *page5;
}

@property (nonatomic ,retain) UIScrollView *pageView;

- (void)setPagesWithPlayStyle:(int)style;

@end
