//
//  CustomSettingPageView.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSettingPageView : UIView<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *tableView_;
    
    NSArray *tableList_;
    NSArray *clearList_;
    NSArray *levelList_;
    NSArray *versionList_;
    NSArray *sortingList_;
    NSArray *playRankList_;
    
    UILabel *versionSortLabel;
    UILabel *levelSortLabel;
    UILabel *clearSortLabel;
    UILabel *playRankSortLabel;
    UILabel *sortingSortLabel;
    
    UILabel *active;
    UILabel *title;
    UILabel *version;
    UILabel *level;
    UILabel *clear;
    UILabel *playRank;
    UILabel *sorting;
    
    UISwitch *activeSwitch;
    UITextField *titleTextField;
    UIButton *versionSelect;
    UIButton *levelSelect;
    UIButton *clearSelect;
    UIButton *playRankSelect;
    UIButton *sortingSelect;
    
    UIButton *cancelButton;
    
    int selectedType;
    
    NSString *currentCustomKey;
}

@property (nonatomic, retain)UITableView *tablelView;

@property (nonatomic ,retain)NSArray *tableList;
@property (nonatomic ,retain)NSArray *clearList;
@property (nonatomic ,retain)NSArray *levelList;
@property (nonatomic ,retain)NSArray *versionList;
@property (nonatomic ,retain)NSArray *sortingList;
@property (nonatomic ,retain)NSArray *playRankList;

- (void)setTextWithPage:(int)page style:(int)style;
- (void)hideTable;

@end

