//
//  SettingViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/17.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *tableView_;
    
    NSArray *tableList_;
    NSArray *defaultSort_;
    
    NSArray *customSPList_;
    NSArray *customDPList_;
    
    UILabel *defaultSort;
    UILabel *defaultSortLabel;
    UIButton * defaultSortButton;
    
    UILabel *custom;
    UILabel *customLabelSP;
    UILabel *customLabelDP;
    UIButton *custom_SP;
    UIButton *custom_DP;

    UIButton *cancelButton;
    
    int selectedType;
}

@property (nonatomic, retain)UITableView *tablelView;

@property (nonatomic ,retain)NSArray *tableList;
@property (nonatomic ,retain)NSArray *defaultSort;

@property (nonatomic ,retain)NSArray *customSPList;
@property (nonatomic ,retain)NSArray *customDPList;

@end

