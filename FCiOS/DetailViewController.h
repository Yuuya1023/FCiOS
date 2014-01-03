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

#import "DatabaseManager.h"
#import "MusicDetailCell.h"

@interface DetailViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIActionSheetDelegate,
UITextFieldDelegate,
UITextViewDelegate,
MusicDetailCellDelegate
>
{
    UITableView *table_;
    UITableView *halfTableView_;
    
    int versionSortType_;
    int levelSortType_;
    int clearSortType_;
    int playStyleSortType_;
    int playRankSortType_;
    int sortingType_;
    int tagId_;
    
    int fcCount;
    int exCount;
    int hcCount;
    int clCount;
    int ecCount;
    int acCount;
    int faCount;
    int npCount;
    
    int someEditType;
    
    NSMutableArray *tableData_;
    BOOL editing;
    
    UIView *titleView_;
    UILabel *titleLabel_;
    UIBarButtonItem *button_;
    UIBarButtonItem *allSelectButton_;
    UIButton *editStateButton_;

    BOOL allChecking;
    NSArray *editTypes;
    UILabel *viewMode;
    UILabel *editMode;
    NSArray *toolbarItems;
    NSArray *toolbarItemsInEditing;
    
    UIToolbar *toolBar_;
    
    NSMutableArray *checkList_;
    
    UIView *grayViewForMemo;
    UILabel *memoTitle;
    UIButton *memoUpdateButton;
    UITextView *memoTextView;
    NSString *tmpText;
    
    UIScrollView *pageView;
    
    UILabel *version;
    UILabel *versionLabel;
    UILabel *normal;
    UILabel *hyper;
    UILabel *another;
    
    UILabel *tagAnother;
    UILabel *tagHyper;
    UILabel *tagNormal;
    
    UIButton *tagAnotherButton;
    UIButton *tagHyperButton;
    UIButton *tagNormalButton;
    
    UILabel *normalLevel;
    UILabel *hyperLevel;
    UILabel *anotherLevel;
    
    UIButton *normalUpdate;
    UIButton *hyperUpdate;
    UIButton *anotherUpdate;

    NSMutableDictionary *spTagList_;
    NSMutableDictionary *dpTagList_;
    
    int normalTagId_;
    int hyperTagId_;
    int anotherTagId_;
    
    BOOL tagEdited_;
    BOOL shouldTagReflesh_;
    
    UIButton *rightPage_;
    UIButton *leftPage_;
    
    UIView *informationView_;
    UIImageView *triangleImage_;
    UIButton *showSlideViewButton_;
    UIView *slideView_;
    
    UILabel *fullComboCount_;
    UILabel *exHardCount_;
    UILabel *hardCount_;
    UILabel *clearCount_;
    UILabel *easyClearCount_;
    UILabel *assistClearCount_;
    UILabel *failedcount_;
    UILabel *noPlayCount_;
    UILabel *allCount_;
    
    UILabel *playStyleLabel_;
    UILabel *nhaLabel_;
    UILabel *difficultyLabel_;
    UILabel *versionLabel_;
    UILabel *clearLampLabel_;
}

@property (nonatomic ,retain) UITableView *table;
@property (nonatomic ,retain) UIView *titleView;
@property (nonatomic ,retain) UILabel *titleLabel;
@property (nonatomic ,retain) UIBarButtonItem *button;
@property (nonatomic ,retain) UIBarButtonItem *allSelectButton;
@property (nonatomic ,retain) UIButton *editStateButton;

@property (nonatomic, assign) int versionSortType;
@property (nonatomic, assign) int levelSortType;
@property (nonatomic, assign) int clearSortType;
@property (nonatomic, assign) int playStyleSortType;
@property (nonatomic, assign) int playRankSortType;
@property (nonatomic, assign) int sortingType;
@property (nonatomic, assign) int tagId;

@property (nonatomic ,retain) NSMutableArray *tableData;

@property (nonatomic ,retain) NSMutableArray *checkList;

- (void)setTableData;


@end
