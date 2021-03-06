//
//  SortConfigViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSources.h"
#import "DetailViewController.h"

@interface SortConfigViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
 
    UITableView *tableVIew_;
    
    NSArray *tableList_;
    NSArray *clearList_;
    NSArray *levelList_;
    NSArray *versionList_;
    NSArray *sortingList_;
    NSArray *playStyleList_;
    NSArray *playRankList_;
    
    UILabel *versionSortLabel;
    UILabel *levelSortLabel;
    UILabel *clearSortLabel;
    UILabel *playStyleSortLabel;
    UILabel *playRankSortLabel;
    UILabel *sortingSortLabel;
    
    UILabel *version;
    UILabel *level;
    UILabel *clear;
    UILabel *playStyle;
    UILabel *playRank;
    UILabel *sorting;
    
    UIButton *versionSelect;
    UIButton *levelSelect;
    UIButton *clearSelect;
    UIButton *playStyleSelect;
    UIButton *playRankSelect;
    UIButton *sortingSelect;
    
    UIButton *resultButton;
//    UIButton *cancelButton;
    
    int versionSortType;
    int levelSortType;
    int clearSortType;
    int playStyleSortType;
    int playRankSortType;
    int sortingType;
    
    int selectedType;
    
    UIScrollView *pageView;
    float pageSizeX;
}

@property (nonatomic, retain)UITableView *tablelVIew;

@property (nonatomic ,retain)NSArray *tableList;
@property (nonatomic ,retain)NSArray *clearList;
@property (nonatomic ,retain)NSArray *levelList;
@property (nonatomic ,retain)NSArray *versionList;
@property (nonatomic ,retain)NSArray *sortingList;
@property (nonatomic ,retain)NSArray *playStyleList;
@property (nonatomic ,retain)NSArray *playRankList;

@end
