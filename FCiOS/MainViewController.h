//
//  MainViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSources.h"

#import "DetailViewController.h"
#import "HomeDetailCell.h"

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    
    UITableView *tableView_;
    UIBarButtonItem *button_;
    
    NSArray *clearList_;
    NSArray *levelList_;
    NSArray *versionList_;
    NSMutableArray *clearDetailArray_;
    NSMutableArray *levelDetailArray_;
    NSMutableArray *versionDetailArray_;
    
    int versionSortType;
    int levelSortType;
    int playStyleSortType;
    int playRankSortType;
    int sortingType;
}

@property (nonatomic, retain)UITableView *tablelView;
@property (nonatomic ,retain) UIBarButtonItem *button;

@property (nonatomic ,retain)NSArray *clearList;
@property (nonatomic ,retain)NSArray *levelList;
@property (nonatomic ,retain)NSArray *versionList;
@property (nonatomic ,retain)NSMutableArray *clearDetailArray;
@property (nonatomic ,retain)NSMutableArray *levelDetailArray;
@property (nonatomic ,retain)NSMutableArray *versionDetailArray;


@end
