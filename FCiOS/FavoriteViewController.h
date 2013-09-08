//
//  FavoriteViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSources.h"

#import "DetailViewController.h"
#import "HomeDetailCell.h"

@interface FavoriteViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    
    UITableView *tableView_;
    UIBarButtonItem *button_;
    
    NSMutableArray *customDetailArray_;
    
//    NSMutableDictionary *tagDictionary_;
    NSMutableArray *tagDetailArray_;
    
    
    int playStyleSortType;
    
    UIView *grayView;
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, retain)UITableView *tablelView;
@property (nonatomic ,retain) UIBarButtonItem *button;

@property (nonatomic ,retain)NSMutableArray *customDetailArray;
//@property (nonatomic ,retain)NSMutableDictionary *tagDictionary;
@property (nonatomic ,retain)NSMutableArray *tagDetailArray;


@end
