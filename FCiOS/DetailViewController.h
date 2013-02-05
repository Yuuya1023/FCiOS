//
//  DetailViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#import "dbConnector.h"

@interface DetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    UITableView *table_;
    
    FMDatabase* music_DB_;
    FMDatabase* userData_DB_;
    
    int versionSortType_;
    int levelSortType_;
    int playStyleSortType_;
    int playRankSortType_;
    int sortingType_;
    
    NSMutableArray *tableData_;
    BOOL editing;
    
    UIBarButtonItem *button_;
    NSArray *editTypes;
    UILabel *viewMode;
    UILabel *editMode;
    NSArray *toolbarItems;
    NSArray *toolbarItemsInEditing;
    
    UIToolbar *toolBar;
    
    NSMutableArray *checkList_;
}

@property (nonatomic ,retain) UITableView *table;
@property (nonatomic ,retain) UIBarButtonItem *button;

@property (nonatomic ,retain) FMDatabase *music_DB;
@property (nonatomic ,retain) FMDatabase *userData_DB;

@property (nonatomic, assign) int versionSortType;
@property (nonatomic, assign) int levelSortType;
@property (nonatomic, assign) int playStyleSortType;
@property (nonatomic, assign) int playRankSortType;
@property (nonatomic, assign) int sortingType;

@property (nonatomic ,retain) NSMutableArray *tableData;

@property (nonatomic ,retain) NSMutableArray *checkList;

- (void)setTableData;


@end
