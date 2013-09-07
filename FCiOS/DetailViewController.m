//
//  DetailViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>





typedef enum {
    TAG_NORMAL_BUTTON       = 100,
    TAG_HYPER_BUTTON        = 101,
    TAG_ANOTHER_BUTTON      = 102
}TAG_BUTTON_TYPE;


typedef enum {
    PLAY_STYLE_SP           = 0,
    PLAY_STYLE_DP           = 1
}PLAY_STYLE_TYPE;

typedef enum {
    ACTION_SHEET_FOR_UPDATE                 = -1,
    ACTION_SHEET_FOR_TAG_SETTING_NORMAL     = -100,
    ACTION_SHEET_FOR_TAG_SETTING_HYPER      = -101,
    ACTION_SHEET_FOR_TAG_SETTING_ANOTHER    = -102
}ACTION_SHEET_TYPE;









@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize table = table_;
@synthesize titleView = titleView_;
@synthesize titleLabel = titleLabel_;
@synthesize button = button_;
@synthesize editStateButton = editStateButton_;
@synthesize allSelectButton = allSelectButton_;

@synthesize versionSortType = versionSortType_;
@synthesize levelSortType = levelSortType_;
@synthesize clearSortType = clearSortType_;
@synthesize playStyleSortType = playStyleSortType_;
@synthesize playRankSortType = playRankSortType_;
@synthesize sortingType = sortingType_;

@synthesize tableData = tableData_;
@synthesize checkList = checkList_;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108) style:UITableViewStylePlain];
        self.table.delegate = self;
        self.table.dataSource = self;
        self.table.rowHeight = 40;
//        self.table.backgroundColor = [UIColor blackColor];
//        self.table.separatorColor = [UIColor lightGrayColor];
        [self.view addSubview:self.table];
        
        
        self.button = [[UIBarButtonItem alloc] initWithTitle:@"一括編集"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editData:)];
        self.navigationItem.rightBarButtonItem = self.button;
        
        //タイトルビュー
        self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//        self.titleView.backgroundColor = [UIColor blueColor];
        
        self.editStateButton = [[UIButton alloc] init];
        if ([USER_DEFAULT boolForKey:EDITING_MODE_KEY]) {
            [self.editStateButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            self.editStateButton.frame = CGRectMake(16, 5, 30, 30);
        }
        else{
            [self.editStateButton setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
            self.editStateButton.frame = CGRectMake(13, 5, 30, 30);
        }
        [self.editStateButton addTarget:self action:@selector(changeEditMode:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:self.editStateButton];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 110, 40)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = DEFAULT_FONT_TITLE;
        [self.titleView addSubview:self.titleLabel];
        
        self.navigationItem.titleView = self.titleView;
        

        self.allSelectButton = [[UIBarButtonItem alloc] initWithTitle:@"すべて選択"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(allSelect:)];

        
        //ツールバー
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 108, [UIScreen mainScreen].bounds.size.width, 44)];
        toolBar.barStyle = UIBarStyleBlack;
        [self.view addSubview:toolBar];
        
        
        //ツールバーアイテム
        //通常
        viewMode = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width - 20, 40)];
        viewMode.adjustsFontSizeToFitWidth = YES;
        viewMode.text = @"";
        viewMode.font = DEFAULT_FONT;
        viewMode.textColor = [UIColor whiteColor];
        viewMode.backgroundColor = [UIColor clearColor];
        UIBarButtonItem *labelBtn = [[UIBarButtonItem alloc] initWithCustomView:viewMode];
        toolbarItems = [[NSArray alloc] initWithObjects:labelBtn, nil];
        toolBar.items = toolbarItems;
        
        //編集中
        editMode = [[UILabel alloc] initWithFrame:CGRectMake(2, 10, 145, 40)];
        editMode.adjustsFontSizeToFitWidth = YES;
        editMode.textColor = [UIColor whiteColor];
        editMode.font = DEFAULT_FONT;
        editMode.backgroundColor = [UIColor clearColor];
        UIBarButtonItem *labelBtn2 = [[UIBarButtonItem alloc] initWithCustomView:editMode];
        
        UIBarButtonItem *canelBtn =[[UIBarButtonItem alloc] initWithTitle:@"キャンセル"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(cancel)
                               ];
        
        UIBarButtonItem *okBtn =[[UIBarButtonItem alloc] initWithTitle:@"更新！"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(commitUpdate)
                                    ];
        if (![Utilities isOS4]) {
            okBtn.tintColor = [UIColor redColor];
        }
        toolbarItemsInEditing = [[NSArray alloc] initWithObjects:labelBtn2,canelBtn,okBtn, nil];
        
        
        //メモ用
        {
            // 2ページ目のx始点用
            float width = [UIScreen mainScreen].bounds.size.width;
            
            //ページ
            pageView = [[UIScrollView alloc] init];
            pageView.frame = CGRectMake(0, 100, width, [UIScreen mainScreen].bounds.size.height - 100);
            pageView.contentSize = CGSizeMake(width * 2, [UIScreen mainScreen].bounds.size.height - 100);
            pageView.delegate = self;
            pageView.pagingEnabled = YES;
            pageView.showsHorizontalScrollIndicator = NO;
            pageView.bounces = NO;
            
            //背景
            grayViewForMemo = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            grayViewForMemo.backgroundColor = [UIColor blackColor];
            grayViewForMemo.alpha = 0.0;
            
            //曲名
            memoTitle = [[UILabel alloc] init];
            memoTitle.frame = CGRectMake(10, 60, 220, 40);
            memoTitle.alpha = 0.0;
            memoTitle.backgroundColor = [UIColor clearColor];
            memoTitle.font = DEFAULT_FONT_TITLE;
            memoTitle.textColor = [UIColor whiteColor];
            memoTitle.adjustsFontSizeToFitWidth = YES;
            
            
            //更新ボタン
            memoUpdateButton = [UIButton buttonWithType:UIButtonTypeCustom];
            memoUpdateButton.frame = CGRectMake(250, 65, 60, 30);
            memoUpdateButton.titleLabel.font = DEFAULT_FONT;
            [memoUpdateButton setTitle:@"OK" forState:UIControlStateNormal];
            [memoUpdateButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            
//            [[memoUpdateButton layer] setCornerRadius:8.0f];
//            [[memoUpdateButton layer] setMasksToBounds:YES];
            [[memoUpdateButton layer] setBorderWidth:1.0f];
            [[memoUpdateButton layer] setBorderColor:[UIColor whiteColor].CGColor];
            
            
            [memoUpdateButton addTarget:self action:NSSelectorFromString(@"memoEditFinished:") forControlEvents:UIControlEventTouchUpInside];
            
            
            // 下部のページ案内
            rightPage_ = [[UILabel alloc] init];
            rightPage_.alpha = 0.0;
            rightPage_.text = @"タグ設定 >";
            rightPage_.font = DEFAULT_FONT;
            rightPage_.textColor = [UIColor whiteColor];
            rightPage_.backgroundColor = [UIColor clearColor];
            
            [pageView addSubview:rightPage_];
            
            leftPage_ = [[UILabel alloc] init];
            leftPage_.alpha = 0.0;
            leftPage_.text = @"< メモ編集";
            leftPage_.font = DEFAULT_FONT;
            leftPage_.textColor = [UIColor whiteColor];
            leftPage_.backgroundColor = [UIColor clearColor];
            
            [pageView addSubview:leftPage_];
            
            
            
            //メモ
            memoTextView = [[UITextView alloc] init];
            if ([Utilities isDevice5thGen]) {
                memoTextView.frame = CGRectMake(10, 5, 300, 410);
                rightPage_.frame = CGRectMake(200, 425, 100, 40);
                leftPage_.frame = CGRectMake(10 + width, 425, 100, 40);
            }
            else{
                memoTextView.frame = CGRectMake(10, 5, 300, 325);
                rightPage_.frame = CGRectMake(200, 340, 100, 40);
                leftPage_.frame = CGRectMake(10 + width, 340, 100, 40);
            }
            memoTextView.delegate = self;
            memoTextView.font = DEFAULT_FONT;
            memoTextView.alpha = 0.0;
            
            
            //ラベル
            normal = [[UILabel alloc] initWithFrame:CGRectMake(width + 25, 10, 100, 40)];
            normal.text = @"NORMAL";
            normal.font = DEFAULT_FONT;
            normal.alpha = 0.0;
            normal.textColor = [UIColor blueColor];
            normal.backgroundColor = [UIColor clearColor];

            hyper = [[UILabel alloc] initWithFrame:CGRectMake(width + 25, 110, 100, 40)];
            hyper.text = @"HYPER";
            hyper.font = DEFAULT_FONT;
            hyper.alpha = 0.0;
            hyper.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
            hyper.backgroundColor = [UIColor clearColor];

            another = [[UILabel alloc] initWithFrame:CGRectMake(width + 25, 210, 100, 40)];
            another.text = @"ANOTHER";
            another.font = DEFAULT_FONT;
            another.alpha = 0.0;
            another.textColor = [UIColor redColor];
            another.backgroundColor = [UIColor clearColor];
            
            [pageView addSubview:normal];
            [pageView addSubview:hyper];
            [pageView addSubview:another];
            
            
            // タグ用リスト
            spTagList_ = [[USER_DEFAULT objectForKey:SP_TAG_LIST_KEY] mutableCopy];
            if (!spTagList_) {
                spTagList_ = [[NSMutableDictionary alloc] init];
            }
            dpTagList_ = [[USER_DEFAULT objectForKey:DP_TAG_LIST_KEY] mutableCopy];
            if (!dpTagList_) {
                dpTagList_ = [[NSMutableDictionary alloc] init];
            }
            
            // タグ文字
            tagNormal = [[UILabel alloc] initWithFrame:CGRectMake(width + 50, 50, 100, 40)];
            tagNormal.text = @"Tag";
            tagNormal.font = DEFAULT_FONT;
            tagNormal.alpha = 0.0;
            tagNormal.textColor = [UIColor whiteColor];
            tagNormal.backgroundColor = [UIColor clearColor];
            
            tagHyper = [[UILabel alloc] initWithFrame:CGRectMake(width + 50, 150, 100, 40)];
            tagHyper.text = @"Tag";
            tagHyper.font = DEFAULT_FONT;
            tagHyper.alpha = 0.0;
            tagHyper.textColor = [UIColor whiteColor];
            tagHyper.backgroundColor = [UIColor clearColor];
            
            tagAnother = [[UILabel alloc] initWithFrame:CGRectMake(width + 50, 250, 100, 40)];
            tagAnother.text = @"Tag";
            tagAnother.font = DEFAULT_FONT;
            tagAnother.alpha = 0.0;
            tagAnother.textColor = [UIColor whiteColor];
            tagAnother.backgroundColor = [UIColor clearColor];
            
            [pageView addSubview:tagNormal];
            [pageView addSubview:tagHyper];
            [pageView addSubview:tagAnother];
            
            
            // タグ変更ボタン
            tagNormalButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tagNormalButton.tag = TAG_NORMAL_BUTTON;
            tagNormalButton.frame = CGRectMake(width + 110, 55, 200, 35);
            tagNormalButton.titleLabel.font = DEFAULT_FONT;
            tagNormalButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [tagNormalButton setTitle:@"たぐたぐたぐ" forState:UIControlStateNormal];
            [tagNormalButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            
            [[tagNormalButton layer] setBorderWidth:1.0f];
            [[tagNormalButton layer] setBorderColor:[UIColor whiteColor].CGColor];
            [tagNormalButton addTarget:self action:NSSelectorFromString(@"tagSelect:") forControlEvents:UIControlEventTouchUpInside];
            [pageView addSubview:tagNormalButton];
            
            tagHyperButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tagHyperButton.tag = TAG_HYPER_BUTTON;
            tagHyperButton.frame = CGRectMake(width + 110, 155, 200, 35);
            tagHyperButton.titleLabel.font = DEFAULT_FONT;
            tagHyperButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [tagHyperButton setTitle:@"たぐたぐたぐ" forState:UIControlStateNormal];
            [tagHyperButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            
            [[tagHyperButton layer] setBorderWidth:1.0f];
            [[tagHyperButton layer] setBorderColor:[UIColor whiteColor].CGColor];
            [tagHyperButton addTarget:self action:NSSelectorFromString(@"tagSelect:") forControlEvents:UIControlEventTouchUpInside];
            [pageView addSubview:tagHyperButton];
            
            tagAnotherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tagAnotherButton.tag = TAG_ANOTHER_BUTTON;
            tagAnotherButton.frame = CGRectMake(width + 110, 255, 200, 35);
            tagAnotherButton.titleLabel.font = DEFAULT_FONT;
            tagAnotherButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [tagAnotherButton setTitle:@"たぐたぐたぐ" forState:UIControlStateNormal];
            [tagAnotherButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            
            [[tagAnotherButton layer] setBorderWidth:1.0f];
            [[tagAnotherButton layer] setBorderColor:[UIColor whiteColor].CGColor];
            [tagAnotherButton addTarget:self action:NSSelectorFromString(@"tagSelect:") forControlEvents:UIControlEventTouchUpInside];
            [pageView addSubview:tagAnotherButton];
            
//
//            
//            normalLevel = [[UILabel alloc] initWithFrame:CGRectMake(width + 140, 10, 100, 40)];
//            normalLevel.text = @"LEVEL 10";
//            normalLevel.font = DEFAULT_FONT;
//            normalLevel.alpha = 0.0;
//            normalLevel.textColor = [UIColor whiteColor];
//            normalLevel.backgroundColor = [UIColor clearColor];
//            
//            hyperLevel = [[UILabel alloc] initWithFrame:CGRectMake(width + 140, 110, 100, 40)];
//            hyperLevel.text = @"LEVEL 10";
//            hyperLevel.font = DEFAULT_FONT;
//            hyperLevel.alpha = 0.0;
//            hyperLevel.textColor = [UIColor whiteColor];
//            hyperLevel.backgroundColor = [UIColor clearColor];
//            
//            anotherLevel = [[UILabel alloc] initWithFrame:CGRectMake(width + 140, 210, 100, 40)];
//            anotherLevel.text = @"LEVEL 10";
//            anotherLevel.font = DEFAULT_FONT;
//            anotherLevel.alpha = 0.0;
//            anotherLevel.textColor = [UIColor whiteColor];
//            anotherLevel.backgroundColor = [UIColor clearColor];
//            
//            
//            normalUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
//            normalUpdate.frame = CGRectMake(width + 80, 50, 230, 40);
//            normalUpdate.alpha = 0.0;
//            [normalUpdate setTitle:@"FULLCOMBO" forState:UIControlStateNormal];
//            [normalUpdate setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
//            [normalUpdate setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//            
//            [[normalUpdate layer] setBorderWidth:1.0f];
//            [[normalUpdate layer] setBorderColor:[UIColor whiteColor].CGColor];
//            [normalUpdate addTarget:self action:NSSelectorFromString(@"updateFromViewMode:") forControlEvents:UIControlEventTouchUpInside];
//            
//            hyperUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
//            hyperUpdate.frame = CGRectMake(width + 80, 150, 230, 40);
//            hyperUpdate.alpha = 0.0;
//            [hyperUpdate setTitle:@"FULLCOMBO" forState:UIControlStateNormal];
//            [hyperUpdate setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
//            [hyperUpdate setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//            
//            [[hyperUpdate layer] setBorderWidth:1.0f];
//            [[hyperUpdate layer] setBorderColor:[UIColor whiteColor].CGColor];
//            [hyperUpdate addTarget:self action:NSSelectorFromString(@"updateFromViewMode:") forControlEvents:UIControlEventTouchUpInside];
//            
//            anotherUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
//            anotherUpdate.frame = CGRectMake(width + 80, 250, 230, 40);
//            anotherUpdate.alpha = 0.0;
//            [anotherUpdate setTitle:@"FULLCOMBO" forState:UIControlStateNormal];
//            [anotherUpdate setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
//            [anotherUpdate setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//            
//            [[anotherUpdate layer] setBorderWidth:1.0f];
//            [[anotherUpdate layer] setBorderColor:[UIColor whiteColor].CGColor];
//            [anotherUpdate addTarget:self action:NSSelectorFromString(@"updateFromViewMode:") forControlEvents:UIControlEventTouchUpInside];

        }

        
        //エディットタイプ配列
        editTypes = [[NSArray alloc] initWithObjects:
                     @"TO FULLCOMBO",
                     @"TO EXHARDCLEAR",
                     @"TO HARDCLEAR",
                     @"TO CLEAR",
                     @"TO EASYCLEAR",
                     @"TO ASSISTCLEAR",
                     @"TO FAILED",
                     @"TO NOPLAY",
                     nil];
        
        self.tableData = [[NSMutableArray alloc] init];
        self.checkList = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}


/////////////////////////////////
// 編集モードから抜ける
/////////////////////////////////
- (void)cancel{
    editing = NO;
    self.navigationItem.rightBarButtonItem = self.button;
    toolBar.items = toolbarItems;
    [self clearCheckList];
    [self.table reloadData];
    self.editStateButton.hidden = NO;
    self.titleView.frame = CGRectMake(0, 0, 200, 40);
}




/////////////////////////////////
// データアップデート
/////////////////////////////////
- (void)commitUpdate{
    NSLog(@"update");
    
    //ぐるぐるを出す
    UIView *grayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.0;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = self.navigationController.view.center;
    [indicator startAnimating];
    [grayView addSubview:indicator];
    [self.navigationController.view addSubview: grayView];
    
    [UIView animateWithDuration:0.3f animations:^(void) {
        grayView.alpha = 0.6;
        
    }completion:^(BOOL finished){
        
        //アップデート対象のidとタイプを配列に入れる
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.checkList count]; i++) {
            if ([[self.checkList objectAtIndex:i] isEqualToString:@"1"]) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                //update
                [dic setObject:[[self.tableData objectAtIndex:i] objectForKey:@"music_id"] forKey:@"music_id"];
                [dic setObject:[[self.tableData objectAtIndex:i] objectForKey:@"type"] forKey:@"type"];
                
                [array addObject:dic];
            }
            else{
            }
        }
        
        //アップデート
        int status = someEditType;
        int style = self.playStyleSortType;
        BOOL b = [self dbUpdate:array changeToStatus:status style:style];
        
        [UIView animateWithDuration:0.3f animations:^(void) {
            grayView.alpha = 0.0;
            
        }completion:^(BOOL finished){
            [indicator removeFromSuperview];
            [grayView removeFromSuperview];
            [self cancel];
            
            if (b) {
                [Utilities showMessage:UPDATE_SUCCEEDED_MESSAGE cgRect:MESSAGE_FIELD inView:self.view];
            }
            else{
                [Utilities showMessage:UPDATE_FAILED_MESSAGE cgRect:MESSAGE_FIELD inView:self.view];
            }
        }];
    }];
}


#pragma mark - UIBarButtonItem

- (void)editData:(UIBarButtonItem *)b{
    if (!editing) {
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.tag = ACTION_SHEET_FOR_UPDATE;
        as.title = @"選択してください。";
        [as addButtonWithTitle:@"TO FULLCOMBO"];
        [as addButtonWithTitle:@"TO EXHARDCLEAR"];
        [as addButtonWithTitle:@"TO HARDCLEAR"];
        [as addButtonWithTitle:@"TO CLEAR"];
        [as addButtonWithTitle:@"TO EASYCLEAR"];
        [as addButtonWithTitle:@"TO ASSISTCLEAR"];
        [as addButtonWithTitle:@"TO FAILED"];
        [as addButtonWithTitle:@"TO NOPLAY"];
        [as addButtonWithTitle:@"キャンセル"];
        as.cancelButtonIndex = 8;
        [as showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)allSelect:(UIBarButtonItem *)b{
    if (!allChecking) {
        self.allSelectButton.title = @"すべて解除";
        if (![Utilities isOS4]) {
            self.allSelectButton.tintColor = [UIColor redColor];
        }
        [self allCheckList];
    }
    else{
        self.allSelectButton.title = @"すべて選択";
        if (![Utilities isOS4]) {
            self.allSelectButton.tintColor = [UIColor darkGrayColor];
        }
        [self clearCheckList];
    }
    [self.table reloadData];
    allChecking = !allChecking;
}





#pragma mark - UIButton

- (void)changeEditMode:(UIButton *)b{
    if (![USER_DEFAULT boolForKey:EDITING_MODE_KEY]) {
        [self.editStateButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        self.editStateButton.frame = CGRectMake(16, 5, 30, 30);
    }
    else{
        [self.editStateButton setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        self.editStateButton.frame = CGRectMake(13, 5, 30, 30);
    }
    [USER_DEFAULT setBool:![USER_DEFAULT boolForKey:EDITING_MODE_KEY] forKey:EDITING_MODE_KEY];
    [USER_DEFAULT synchronize];
}

- (void)tagSelect:(UIButton *)b{
    
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = @"選択してください。";
    
    switch (b.tag) {
        case TAG_NORMAL_BUTTON:
            as.tag = ACTION_SHEET_FOR_TAG_SETTING_NORMAL;
            break;
        case TAG_HYPER_BUTTON:
            as.tag = ACTION_SHEET_FOR_TAG_SETTING_HYPER;
            break;
        case TAG_ANOTHER_BUTTON:
            as.tag = ACTION_SHEET_FOR_TAG_SETTING_ANOTHER;
            break;
            
        default:
            break;
    }
    
    NSMutableDictionary *list;
    switch (self.playStyleSortType) {
        case PLAY_STYLE_SP:
            list = spTagList_;
            break;
        case PLAY_STYLE_DP:
            list = dpTagList_;
            break;
            
        default:
            break;
    }
    
    if ([list count] == 0) {
        [Utilities showDefaultAlertWithTitle:@"タグが設定されていません" message:@"設定画面よりタグを追加してください。"];
        return;
    }
    
    for(NSString *value in list){
        [as addButtonWithTitle:[NSString stringWithFormat:@"%@",[list objectForKey:value]]];
    }
    [as addButtonWithTitle:@"タグを外す"];
    [as addButtonWithTitle:@"キャンセル"];

    as.destructiveButtonIndex = [list count];
    as.cancelButtonIndex = [list count] + 1;
    [as showFromTabBar:self.tabBarController.tabBar];
    
}


- (void)updateFromViewMode:(UIButton *)b{
    NSLog(@"pppp");
}


#pragma mark -





- (void)setTableData{
    NSLog(@"setTableData %d %d %d %d %d",self.versionSortType,self.levelSortType,self.playStyleSortType,self.playRankSortType,self.sortingType);
    [self.tableData removeAllObjects];
    [self dbSelector];
    
    NSString *playStyle = @"SP";
    if (self.playStyleSortType == 1) {
        playStyle = @"DP";
    }
    self.titleLabel.text = [NSString stringWithFormat:@"%@  %d曲",playStyle,[self.tableData count]];
    //セルチェックリスト
    for (int i = 0; i <= [self.tableData count]; i++){
        [self.checkList addObject:@"0"];
    }

    [self.table reloadData];
}

- (void)clearCheckList{
    [self.checkList removeAllObjects];
//    NSLog(@"[self.tableData count] %d",[self.tableData count]);
    for (int i = 0; i < [self.tableData count]; i++){
        [self.checkList addObject:@"0"];
    }
}


- (void)allCheckList{
    [self.checkList removeAllObjects];
//    NSLog(@"[self.tableData count] %d",[self.tableData count]);
    for (int i = 0; i < [self.tableData count]; i++){
        [self.checkList addObject:@"1"];
    }
}


#pragma mark - SQLite

- (void)dbSelector{
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    FMDatabase *database = dbManager.music_DB;
    if ([database open]) {
        [database setShouldCacheStatements:YES];
        
        
        //バージョン
        NSString *versionSql;
        if (self.versionSortType == 0) {
            versionSql = @"version < 21";
        }
        else{
            versionSql = [NSString stringWithFormat:@"version = %d",self.versionSortType];
        }
        
        //レベル
        NSString *levelSql;
        if (self.levelSortType == 0) {
            levelSql = @"< 13";
        }
        else{
            levelSql = [NSString stringWithFormat:@" = %d",self.levelSortType];
        }
        NSString *playStyleSql = [NSString stringWithFormat:@"%@_",[DatabaseManager SQLPlayStyleString:self.playStyleSortType]];
        NSString *playRankSql = [DatabaseManager SQLPlayRankString:self.playRankSortType];
        NSString *statusSort = [NSString stringWithFormat:@"AND status%@",[DatabaseManager SQLClearLampString:self.clearSortType]];
        

        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT tblResults.* FROM("];
        
        //N/H/Aすべての結果を表示
        if ([playRankSql isEqualToString:@"UNION_ALL"]) {
            [sql appendFormat:@"SELECT music_id,name,version,%@Normal_Level AS level,%@Normal_Status AS status,selectType_Normal AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Normal_Level%@ %@ AND deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql,
             statusSort];
            
            [sql appendFormat:@" UNION ALL "];
            [sql appendFormat:@"SELECT music_id,name,version,%@Hyper_Level AS level,%@Hyper_Status AS status,selectType_Hyper AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Hyper_Level%@ %@ AND deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql,
             statusSort];
            
            [sql appendFormat:@" UNION ALL "];
            [sql appendFormat:@"SELECT music_id,name,version,%@Another_Level AS level ,%@Another_Status AS status,selectType_Another AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND  %@Another_Level%@ %@ AND deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql,
             statusSort];
            
        }
        else if ([playRankSql isEqualToString:@"AnotherAndHyper"]) {
            
            [sql appendFormat:@"SELECT music_id,name,version,%@Hyper_Level AS level,%@Hyper_Status AS status,selectType_Hyper AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Hyper_Level%@ %@ AND deleteFlg = 0 AND level != 0 AND %@Another_Level = 0",
             playStyleSql,
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql,
             statusSort,
             playStyleSql];
            
            [sql appendFormat:@" UNION ALL "];
            [sql appendFormat:@"SELECT music_id,name,version,%@Another_Level AS level ,%@Another_Status AS status,selectType_Another AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND  %@Another_Level%@ %@ AND deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql,
             statusSort];
            
        }
        else{
            //プレイランクを指定したとき
            [sql appendFormat:@"SELECT music_id,name,version,%@%@_Level AS level,%@%@_Status AS status,selectType_%@ AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@%@_Level%@ %@ AND deleteFlg = 0 AND level != 0",
             playStyleSql,
             playRankSql,
             playStyleSql,
             playRankSql,
             playRankSql,
             versionSql,
             playStyleSql,
             playRankSql,
             levelSql,
             statusSort];
        }
        
        NSString *sql_tmp = [NSString stringWithFormat:@"%@) AS tblResults",sql];
        
        
        //ソート順
        switch (self.sortingType) {
            case 0:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.level ASC,LOWER(tblResults.name) ASC"];
                break;
            case 1:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.level DESC,LOWER(tblResults.name) ASC"];
                break;
            case 2:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.status ASC,tblResults.level ASC,LOWER(tblResults.name) ASC"];
                break;
            case 3:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.status DESC,tblResults.level ASC,LOWER(tblResults.name) ASC"];
                break;
            default:
                break;
        }
        
        NSLog(@"\n%@",sql);
        FMResultSet *rs = [database executeQuery:sql];
        while ([rs next]) {
//            NSLog(@"result %d %@",[rs intForColumn:@"music_id"],[rs stringForColumn:@"name"]);
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"music_id"]],@"music_id",
                                 [rs stringForColumn:@"name"],@"name",
                                 [rs stringForColumn:@"level"],@"level",
                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"type"]],@"type",
                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"status"]],@"status",
                                 nil];
            
            [self.tableData addObject:dic];
            
        }
        [rs close];


        //統計データを抽出
        NSString *sql2 = [NSString stringWithFormat:@"SELECT status,count(music_id) FROM (%@) GROUP BY status",sql_tmp];
        NSLog(@"\n%@",sql2);
        FMResultSet *rs2 = [database executeQuery:sql2];
        fcCount = 0;
        exCount = 0;
        hcCount = 0;
        clCount = 0;
        ecCount = 0;
        acCount = 0;
        faCount = 0;
        npCount = 0;
        while ([rs2 next]) {
            int status = [rs2 intForColumn:@"status"];
            int count =  [rs2 intForColumn:@"count(music_id)"];
            switch (status) {
                case 7:
                    fcCount = count;
                    break;
                case 6:
                    exCount = count;
                    break;
                case 5:
                    hcCount = count;
                    break;
                case 4:
                    clCount = count;
                    break;
                case 3:
                    ecCount = count;
                    break;
                case 2:
                    acCount = count;
                    break;
                case 1:
                    faCount = count;
                    break;
                case 0:
                    npCount = count;
                    break;
                default:
                    break;
            }
        }
        
        //フッターの統計ラベルに表示
        viewMode.text = [NSString stringWithFormat:@"FC:%d EX:%d H:%d C:%d EC:%d AC:%d F:%d NO:%d",fcCount,exCount,hcCount,clCount,ecCount,acCount,faCount,npCount];
        
        [rs2 close];
        [database close];
        
    }else{
        NSLog(@"Could not open db.");
    }
    
}

- (BOOL)dbUpdate:(NSMutableArray *)list changeToStatus:(int)status style:(int)style{
    BOOL isSuccess = NO;
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    FMDatabase *database = dbManager.music_DB;
    
    if ([database open]) {
        [database setShouldCacheStatements:YES];
        [database beginTransaction];
        
        NSString *playStyleSql;
        if (style == 0) {
            playStyleSql = [NSString stringWithFormat:@"SP_"];
        }
        else{
            playStyleSql = [NSString stringWithFormat:@"DP_"];
        }
        
        for (int i = 0; i < [list count]; i++) {
        
            NSString *playRankSql;
            switch ([[[list objectAtIndex:i] objectForKey:@"type"] intValue]) {
                case 0:
                    playRankSql = [NSString stringWithFormat:@"Normal"];
                    break;
                case 1:
                    playRankSql = [NSString stringWithFormat:@"Hyper"];
                    break;
                case 2:
                    playRankSql = [NSString stringWithFormat:@"Another"];
                    break;
                default:
                    break;
            }
        
            NSString *sql = [NSString stringWithFormat:@"UPDATE userData SET %@%@_Status = %d WHERE music_id = %d",
                             playStyleSql,
                             playRankSql,
                             status,
                             [[[list objectAtIndex:i] objectForKey:@"music_id"] intValue]];
            NSLog(@"\n update sql \n %@",sql);
            [database executeUpdate:sql];
        
        }
        
        //エラー処理
        if ([database hadError]) {
            NSLog(@"update error %d: %@",[database lastErrorCode],[database lastErrorMessage]);
            [database rollback];
        }
        else{
            isSuccess = YES;
            [USER_DEFAULT setBool:YES forKey:UPDATED_USERDATA_KEY];
            [USER_DEFAULT synchronize];
            [database commit];
        }
        
        [database close];
        [dbManager customSortSelecter:style];
        [self setTableData];
    }
    else{
        NSLog(@"Could not open db.");
    }
    return isSuccess;
}


#pragma mark - memo edit mode

/////////////////////////////////
// メモ編集モード
/////////////////////////////////
- (void)memoEditModeWithMusicId:(NSString *)musicId title:(NSString *)title{
    
    [self.navigationController.view addSubview:grayViewForMemo];
    [self.navigationController.view addSubview:pageView];
    [self.navigationController.view addSubview:memoTitle];
    [self.navigationController.view addSubview:memoUpdateButton];
    [pageView addSubview:memoTextView];

//
//    [pageView addSubview:normalLevel];
//    [pageView addSubview:hyperLevel];
//    [pageView addSubview:anotherLevel];
//    
//    [pageView addSubview:normalUpdate];
//    [pageView addSubview:hyperUpdate];
//    [pageView addSubview:anotherUpdate];

    memoTitle.text = title;
    memoUpdateButton.tag = [musicId intValue];
    
    NSDictionary *res = [[DatabaseManager sharedInstance] getMemoAndTagWithMusicId:musicId];
    tmpText = [res objectForKey:@"memo"];
    
    NSDictionary *list;
    switch (self.playStyleSortType) {
        case PLAY_STYLE_SP:
        {
            list = [NSDictionary dictionaryWithDictionary:spTagList_];
            normalTagId_ = [[res objectForKey:@"SP_normalTag"] intValue];
            hyperTagId_ = [[res objectForKey:@"SP_hyperTag"] intValue];
            anotherTagId_ = [[res objectForKey:@"SP_anotherTag"] intValue];
        }
            break;
        case PLAY_STYLE_DP:
        {
            list = [NSDictionary dictionaryWithDictionary:dpTagList_];
            normalTagId_ = [[res objectForKey:@"DP_normalTag"] intValue];
            hyperTagId_ = [[res objectForKey:@"DP_hyperTag"] intValue];
            anotherTagId_ = [[res objectForKey:@"DP_anotherTag"] intValue];
        }
            break;
            
        default:
            break;
    }
    
    // タグのセット
    tagEdited_ = NO;
    if (normalTagId_ == -1) {
        [tagNormalButton setTitle:@"未設定" forState:UIControlStateNormal];
    }
    else{
        [tagNormalButton setTitle:[list objectForKey:[NSString stringWithFormat:@"%d",normalTagId_]] forState:UIControlStateNormal];
    }
    
    if (hyperTagId_ == -1) {
        [tagHyperButton setTitle:@"未設定" forState:UIControlStateNormal];
    }
    else{
        [tagHyperButton setTitle:[list objectForKey:[NSString stringWithFormat:@"%d",hyperTagId_]] forState:UIControlStateNormal];
    }
    
    if (anotherTagId_ == -1) {
        [tagAnotherButton setTitle:@"未設定" forState:UIControlStateNormal];
    }
    else{
        [tagAnotherButton setTitle:[list objectForKey:[NSString stringWithFormat:@"%d",anotherTagId_]] forState:UIControlStateNormal];
    }
    
    
    
    [UIView animateWithDuration:0.3f animations:^(void) {
        memoTextView.text = tmpText;
        
        grayViewForMemo.alpha = 0.9;
        memoTitle.alpha = 1.0;
        memoTextView.alpha = 0.8;
        
        normal.alpha = 1.0;
        hyper.alpha = 1.0;
        another.alpha = 1.0;
        
        tagNormal.alpha = 1.0;
        tagHyper.alpha = 1.0;
        tagAnother.alpha = 1.0;
        
        rightPage_.alpha = 1.0;
        leftPage_.alpha = 1.0;
//        normalLevel.alpha = 1.0;
//        hyperLevel.alpha = 1.0;
//        anotherLevel.alpha = 1.0;
//        normalUpdate.alpha = 1.0;
//        hyperUpdate.alpha = 1.0;
//        anotherUpdate.alpha = 1.0;
        
    }completion:^(BOOL finished){
        
    }];
}



/////////////////////////////////
// メモ保存
/////////////////////////////////
- (void)memoEditFinished:(UIButton *)b{
    NSLog(@"memoEditFinished %@",memoTextView.text);
    
//    BOOL textChanged = ![tmpText isEqualToString:memoTextView.text];
    
    [UIView animateWithDuration:0.3f animations:^(void) {
        grayViewForMemo.alpha = 0.0;
        memoTitle.alpha = 0.0;
        memoTextView.alpha = 0.0;
        
        normal.alpha = 0.0;
        hyper.alpha = 0.0;
        another.alpha = 0.0;
        
        tagNormal.alpha = 0.0;
        tagHyper.alpha = 0.0;
        tagAnother.alpha = 0.0;
        
        rightPage_.alpha = 0.0;
        leftPage_.alpha = 0.0;
//        normalLevel.alpha = 0.0;
//        hyperLevel.alpha = 0.0;
//        anotherLevel.alpha = 0.0;
//        normalUpdate.alpha = 0.0;
//        hyperUpdate.alpha = 0.0;
//        anotherUpdate.alpha = 0.0;
        [memoTextView resignFirstResponder];
        
    }completion:^(BOOL finished){

//        [normalLevel removeFromSuperview];
//        [hyperLevel removeFromSuperview];
//        [anotherLevel removeFromSuperview];
//        [normalUpdate removeFromSuperview];
//        [hyperUpdate removeFromSuperview];
//        [anotherUpdate removeFromSuperview];
        
        [grayViewForMemo removeFromSuperview];
        [memoTitle removeFromSuperview];
        [memoUpdateButton removeFromSuperview];
        [memoTextView removeFromSuperview];
        [pageView removeFromSuperview];
        
        if (![tmpText isEqualToString:memoTextView.text] || tagEdited_) {
            //変更があったら更新
            NSString *playStyle = @"SP";
            if (self.playStyleSortType == PLAY_STYLE_DP) {
                playStyle = @"DP";
            }
            NSDictionary *tagInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%d",normalTagId_],[NSString stringWithFormat:@"%@_normalTag",playStyle],
                                     [NSString stringWithFormat:@"%d",hyperTagId_],[NSString stringWithFormat:@"%@_hyperTag",playStyle],
                                     [NSString stringWithFormat:@"%d",anotherTagId_],[NSString stringWithFormat:@"%@_anotherTag",playStyle],
                                     nil];
            
            if ([[DatabaseManager sharedInstance] updateMemoAndTagWithMusicId:b.tag text:memoTextView.text tagUpdateInfo:tagInfo]) {
                [Utilities showMessage:UPDATE_SUCCEEDED_MESSAGE cgRect:MESSAGE_FIELD inView:self.view];
            }
            else{
                [Utilities showMessage:UPDATE_FAILED_MESSAGE cgRect:MESSAGE_FIELD inView:self.view];
            }
        }
    }];
}



#pragma mark - UIScrollView Delegate

/////////////////////////////////
// scrollViewDidScroll
/////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (round)(scrollView.contentOffset.x / scrollView.bounds.size.width);
//    NSLog(@"scrollViewDidScroll %d",page);
    
    if (page == 1) {
        [UIView animateWithDuration:0.2f animations:^(void) {
            if ([Utilities isDevice5thGen]) {
                memoTextView.frame = CGRectMake(10, 5, 300, 410);
            }
            else{
                memoTextView.frame = CGRectMake(10, 5, 300, 325);
            }
        }];
        [memoTextView resignFirstResponder];
        
        
    }
}


#pragma mark - UITextView Delegate

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView{
    
    [UIView animateWithDuration:0.2f animations:^(void) {
        if ([Utilities isDevice5thGen]) {
            memoTextView.frame = CGRectMake(10, 5, 300, 195);
        }
        else{
            memoTextView.frame = CGRectMake(10, 5, 300, 115);
        }
    }];
        
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView*)textView{
    
    [UIView animateWithDuration:0.2f animations:^(void) {
        if ([Utilities isDevice5thGen]) {
            memoTextView.frame = CGRectMake(10, 5, 300, 410);
        }
        else{
            memoTextView.frame = CGRectMake(10, 5, 300, 325);
        }
    }];
    return YES;
}


#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"clickedButtonAtIndex %d",buttonIndex);
    
    // タグのIDを保持
    int tagId;
    NSString *tagName;
    if (actionSheet.tag == ACTION_SHEET_FOR_TAG_SETTING_NORMAL ||
        actionSheet.tag == ACTION_SHEET_FOR_TAG_SETTING_HYPER ||
        actionSheet.tag == ACTION_SHEET_FOR_TAG_SETTING_ANOTHER)
    {
        switch (self.playStyleSortType) {
            case PLAY_STYLE_SP:
            {
                if (buttonIndex == [spTagList_ count] + 1) {
                    [self cancel];
                    return;
                }
                else if (buttonIndex == [spTagList_ count]){
                    tagId = -1;
                    tagName = @"未設定";
                }
                else{
                    tagId = [[[spTagList_ allKeys] objectAtIndex:buttonIndex] intValue];
                    tagName = [spTagList_ objectForKey:[NSString stringWithFormat:@"%d",tagId]];
                }
            }
                break;
            case PLAY_STYLE_DP:
            {
                if (buttonIndex == [dpTagList_ count] + 1) {
                    [self cancel];
                    return;
                }
                else if (buttonIndex == [dpTagList_ count]){
                    tagId = -1;
                    tagName = @"未設定";
                }
                else{
                    tagId = [[[dpTagList_ allKeys] objectAtIndex:buttonIndex] intValue];
                    tagName = [dpTagList_ objectForKey:[NSString stringWithFormat:@"%d",tagId]];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    switch (actionSheet.tag) {
        case ACTION_SHEET_FOR_UPDATE:
        {
            //一括編集から出した場合
            if (buttonIndex == 8) {
                [self cancel];
            }
            else{
                self.navigationItem.rightBarButtonItem = self.allSelectButton;
                self.allSelectButton.title = @"すべて選択";
                if (![Utilities isOS4]) {
                    self.allSelectButton.tintColor = [UIColor darkGrayColor];
                }
                allChecking = NO;
                editing = YES;
                someEditType = 7 - buttonIndex;
                editMode.text = [editTypes objectAtIndex:buttonIndex];
                toolBar.items = toolbarItemsInEditing;
                self.editStateButton.hidden = YES;
            }
        }
            break;
        case ACTION_SHEET_FOR_TAG_SETTING_NORMAL:
        {
            if (normalTagId_ != tagId) {
                tagEdited_ = YES;
                normalTagId_ = tagId;
                [tagNormalButton setTitle:tagName forState:UIControlStateNormal];
                NSLog(@"normalTagId_ %d",normalTagId_);
            }
        }
            break;
        case ACTION_SHEET_FOR_TAG_SETTING_HYPER:
        {
            if (hyperTagId_ != tagId) {
                tagEdited_ = YES;
                hyperTagId_ = tagId;
                [tagHyperButton setTitle:tagName forState:UIControlStateNormal];
                NSLog(@"hyperTagId_ %d",hyperTagId_);
            }
        }
            break;
        case ACTION_SHEET_FOR_TAG_SETTING_ANOTHER:
        {
            if (anotherTagId_ != tagId) {
                tagEdited_ = YES;
                anotherTagId_ = tagId;
                [tagAnotherButton setTitle:tagName forState:UIControlStateNormal];
                NSLog(@"anotherTagId_ %d",anotherTagId_);
            }
        }
            break;

        default:
        {
            //セルをタップした際
            if (buttonIndex == 8) {
                [self cancel];
            }
            else{
                NSLog(@"tag = %d",actionSheet.tag);
                int tag = actionSheet.tag;
                //update
                //アップデート対象のidとtypeを配列に入れる
                NSMutableArray *array = [[NSMutableArray alloc] init];
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [[self.tableData objectAtIndex:tag] objectForKey:@"music_id"],@"music_id",
                                     [[self.tableData objectAtIndex:tag] objectForKey:@"type"],@"type",
                                     nil];
                [array addObject:dic];
                
                int status = 7 - buttonIndex;
                int style = self.playStyleSortType;
                
                if([self dbUpdate:array changeToStatus:status style:style]){
                    [Utilities showMessage:UPDATE_SUCCEEDED_MESSAGE cgRect:MESSAGE_FIELD inView:self.view];
                }
                else{
                    [Utilities showMessage:UPDATE_FAILED_MESSAGE cgRect:MESSAGE_FIELD inView:self.view];
                }
            }
        }
            break;
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicDetailCell";
    MusicDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell = [[MusicDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if ([[self.checkList objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    NSString *status = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"status"];
    cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_%@",status]];
    int type = [[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"type"] intValue];
    switch (type) {
        case 0:
            cell.difficulityLabel.textColor = [UIColor blueColor];
            break;
        case 1:
            //黄色
            cell.difficulityLabel.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
            break;
        case 2:
            cell.difficulityLabel.textColor = [UIColor redColor];
            break;
            
        default:
            break;
    }
    cell.difficulityLabel.text = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"level"];
    cell.nameLabel.text = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editing) {
        UITableViewCell* cell = nil;
        cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([[self.checkList objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.checkList replaceObjectAtIndex:indexPath.row withObject:@"1"];
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.checkList replaceObjectAtIndex:indexPath.row withObject:@"0"];
        }
    }
    else{
        if (![USER_DEFAULT boolForKey:EDITING_MODE_KEY]) {
            [self memoEditModeWithMusicId:[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"music_id"]
                                    title:[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"]];
        }
        else{
            NSString *name = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"];
            NSString *type = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"type"];
            NSLog(@"cell name %@, type = %@",name,type);
            
            UIActionSheet *as = [[UIActionSheet alloc] init];
            as.delegate = self;
            as.tag = indexPath.row;
            
            NSString *typeStr;
            switch ([type intValue]) {
                case 0:
                    typeStr = @"(N)";
                    break;
                case 1:
                    typeStr = @"(H)";
                    break;
                case 2:
                    typeStr = @"(A)";
                    break;
                default:
                    break;
            }
            as.title = [NSString stringWithFormat:@"%@ %@",name,typeStr];
            [as addButtonWithTitle:@"TO FULLCOMBO"];
            [as addButtonWithTitle:@"TO EXHARDCLEAR"];
            [as addButtonWithTitle:@"TO HARDCLEAR"];
            [as addButtonWithTitle:@"TO CLEAR"];
            [as addButtonWithTitle:@"TO EASYCLEAR"];
            [as addButtonWithTitle:@"TO ASSISTCLEAR"];
            [as addButtonWithTitle:@"TO FAILED"];
            [as addButtonWithTitle:@"TO NOPLAY"];
            [as addButtonWithTitle:@"キャンセル"];
            as.cancelButtonIndex = 8;
            [as showFromTabBar:self.tabBarController.tabBar];
        }
    }

}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
