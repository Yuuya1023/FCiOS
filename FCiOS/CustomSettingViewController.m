//
//  CustomSettingViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "CustomSettingViewController.h"

@interface CustomSettingViewController ()

@end

@implementation CustomSettingViewController
@synthesize pageView = pageView_;

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"SP 1/5";
        titleLabel.font = DEFAULT_FONT_TITLE;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleLabel;
        //ページコントロール
        bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pageControlBG"]];
        bg.frame = CGRectMake(85, [UIScreen mainScreen].bounds.size.height - 108, 150, 30);
        [self.view addSubview:bg];
        
        prePageNum = 1;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(85, [UIScreen mainScreen].bounds.size.height - 108, 150, 30)];
        pageControl.numberOfPages = 5;
        [self.view addSubview:pageControl];
        
//        [pageControl addTarget:self
//                        action:@selector(pageControlDidChanged:)
//              forControlEvents:UIControlEventValueChanged];
        
        //スクロールビュー
        self.pageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        self.pageView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 5, [UIScreen mainScreen].bounds.size.height - 108);
        self.pageView.delegate = self;
        self.pageView.pagingEnabled = YES;
        self.pageView.showsHorizontalScrollIndicator = NO;
        self.pageView.bounces = NO;
//        self.pageView.backgroundColor = [UIColor blueColor];
        self.pageView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.pageView];
        
        
        //ページたち
        page1 = [[CustomSettingPageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        [page1 setTextWithPage:1 style:0];
        [self.pageView addSubview:page1];
        
        page2 = [[CustomSettingPageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        [page2 setTextWithPage:2 style:0];
        [self.pageView addSubview:page2];
        
        page3 = [[CustomSettingPageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 2, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        [page3 setTextWithPage:3 style:0];
        [self.pageView addSubview:page3];
        
        page4 = [[CustomSettingPageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 3, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        [page4 setTextWithPage:4 style:0];
        [self.pageView addSubview:page4];
        
        page5 = [[CustomSettingPageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 4, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        [page5 setTextWithPage:5 style:0];
        [self.pageView addSubview:page5];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//- (void)pageControlDidChanged:(UIPageControl *)control {
//    CGRect frame = self.pageView.frame;
//    frame.origin.x = frame.size.width * control.currentPage;
//    frame.origin.y = 0.0;
//    [self.pageView scrollRectToVisible:frame animated:YES];
//}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (round)(self.pageView.contentOffset.x / self.pageView.bounds.size.width);
    pageControl.currentPage = page;
    if (page + 1 != prePageNum) {
        titleLabel.text = [NSString stringWithFormat:@"SP %d/5",page + 1];
        switch (prePageNum) {
            case 1:
                [page1 hideTable];
                break;
            case 2:
                [page2 hideTable];
                break;
            case 3:
                [page3 hideTable];
                break;
            case 4:
                [page4 hideTable];
                break;
            case 5:
                [page5 hideTable];
                break;
            default:
                break;
        }
    }
    prePageNum = page + 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
