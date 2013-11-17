//
//  MainViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "MainViewController.h"
#import "SBJson.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize tablelView = tableView_;
@synthesize button = button_;
@synthesize clearList = clearList_;
@synthesize levelList = levelList_;
@synthesize versionList = versionList_;
@synthesize customDetailArray = customDetailArray_;
@synthesize clearDetailArray = clearDetailArray_;
@synthesize levelDetailArray = levelDetailArray_;
@synthesize versionDetailArray = versionDetailArray_;

- (id)init
{
    self = [super init];
    if (self) {
        self.tablelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 113) style:UITableViewStylePlain];
        self.tablelView.delegate = self;
        self.tablelView.dataSource = self;
        self.tablelView.rowHeight = 50;
//        self.tablelView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
//        self.table.separatorColor = [UIColor lightGrayColor];
        [self.view addSubview:self.tablelView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"Home";
        titleLabel.font = DEFAULT_FONT_TITLE;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleLabel;
        
        self.title = @"Home";
        self.tabBarItem.image = [UIImage imageNamed:@"home"];
        
        //選択されているプレイスタイル&プレイランクをセット
        playStyleSortType = [USER_DEFAULT integerForKey:DEFAULT_PLAYSTYLE_KEY];
        playRankSortType = [USER_DEFAULT integerForKey:DEFAULT_PLAYRANK_KEY];
        
        //ソートボタン
        NSString *playStyle;
        if (playStyleSortType == 0) {
            playStyle = @"SP";
        }
        else{
            playStyle = @"DP";
        }
        
        NSString *playRank;
        switch (playRankSortType) {
            case 0:
                playRank = @"NORMAL";
                break;
            case 1:
                playRank = @"HYPER";
                break;
            case 2:
                playRank = @"ANOTHER";
                break;
            case 3:
                playRank = @"A+H";
                break;
                
            default:
                playRank = @"ALL";
                break;
        }
        self.button = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@",playStyle,playRank]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:NSSelectorFromString(@"setSortType:")];
        self.navigationItem.leftBarButtonItem = self.button;
        
        //更新ボタン
        UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(@"update:")];
        self.navigationItem.rightBarButtonItem = updateButton;
        
        TableSources *tableSources = [[TableSources alloc] init];
        self.clearList = tableSources.clearList;
        self.versionList = tableSources.versionList;
        self.levelList = tableSources.levelList;
        
        //配列初期化
        self.customDetailArray = [[NSMutableArray alloc] init];
        self.clearDetailArray = [[NSMutableArray alloc] init];
        self.levelDetailArray = [[NSMutableArray alloc] init];
        self.versionDetailArray = [[NSMutableArray alloc] init];
        
        [self reloadTable];
    }
    return self;
}

- (void)initializeArray{
    [self.clearDetailArray removeAllObjects];
    for (int i = 0; i <= 7; i++){
        [self.clearDetailArray addObject:@"0"];
    }
    
    [self.levelDetailArray removeAllObjects];
    [self.versionDetailArray removeAllObjects];
}


- (void)reloadTable{
    [self initializeArray];
//    [self setCustomDetail:playStyleSortType];
    [self dbSelector];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.tablelView deselectRowAtIndexPath:[self.tablelView indexPathForSelectedRow] animated:YES];
    if ([USER_DEFAULT boolForKey:UPDATED_USERDATA_KEY]) {
        [self reloadTable];
        [USER_DEFAULT setBool:NO forKey:UPDATED_USERDATA_KEY];
        [USER_DEFAULT synchronize];
    }
    else{
//        [self setCustomDetail:playStyleSortType];
    }

}

- (void)setCustomDetail:(int)style{
    [self.customDetailArray removeAllObjects];
    NSString *key;
    if (style == 0) {
        key = @"custom_sp";
    }
    else{
        key = @"custom_dp";
    }
    
    for (int i = 1; i <= 5; i++) {
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[USER_DEFAULT objectForKey:[NSString stringWithFormat:@"%@%d",key,i]]];
        if ([[dic objectForKey:@"active"] isEqualToString:@"0"]) {
            NSLog(@"custom%d not active.",i);
        }
        else{
            NSDictionary *tmpDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [dic objectForKey:@"title"],@"title",
                                    [dic objectForKey:@"count"],@"count",
                                    [dic objectForKey:@"version"],@"version",
                                    [dic objectForKey:@"difficulity"],@"difficulity",
                                    [dic objectForKey:@"clearLamp"],@"clearLamp",
                                    [dic objectForKey:@"playRank"],@"playRank",
                                    [dic objectForKey:@"sortType"],@"sortType",
                                    [dic objectForKey:@"min"],@"min",
                                    nil];
            [self.customDetailArray addObject:tmpDic];
        }
    }
    [self.tablelView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dbSelector{
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    FMDatabase *database = dbManager.music_DB;
    if ([database open]) {
        [database setShouldCacheStatements:YES];
        
        //表示中の設定からsql発行
        NSString *playStyleSql;
        if (playStyleSortType == 0) {
            playStyleSql = [NSString stringWithFormat:@"SP"];
        }
        else{
            playStyleSql = [NSString stringWithFormat:@"DP"];
        }
        
        NSString *playRankSql;
        switch (playRankSortType) {
            case 0:
                playRankSql = [NSString stringWithFormat:@"Normal"];
                break;
            case 1:
                playRankSql = [NSString stringWithFormat:@"Hyper"];
                break;
            case 2:
                playRankSql = [NSString stringWithFormat:@"Another"];
                break;
            case 3:
                playRankSql = [NSString stringWithFormat:@"AnotherAndHyper"];
                break;
                
            default:
                playRankSql = @"UNION_ALL";
                break;
        }
        
        //クリアランプ検索
        NSMutableString *sql_lamp = [NSMutableString stringWithFormat:@"SELECT status,count(music_id) FROM ( SELECT tblResults.* FROM("];
        if ([playRankSql isEqualToString:@"UNION_ALL"]) {
            [sql_lamp appendFormat:@"SELECT music_id,%@_Normal_Level AS level,%@_Normal_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql];
            
            [sql_lamp appendFormat:@" UNION ALL "];
            [sql_lamp appendFormat:@"SELECT music_id,%@_Hyper_Level AS level,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql];
            
            [sql_lamp appendFormat:@" UNION ALL "];
            [sql_lamp appendFormat:@"SELECT music_id,%@_Another_Level AS level,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql];
        }
        else if ([playRankSql isEqualToString:@"AnotherAndHyper"]) {
            
            [sql_lamp appendFormat:@"SELECT music_id,%@_Hyper_Level AS level,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0 AND %@_Another_Level = 0",
             playStyleSql,
             playStyleSql,
             playStyleSql];
            
            [sql_lamp appendFormat:@" UNION ALL "];
            [sql_lamp appendFormat:@"SELECT music_id,%@_Another_Level AS level,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0",
             playStyleSql,
             playStyleSql];
            
        }
        else{        
            [sql_lamp appendFormat:@"SELECT music_id,%@_%@_Level AS level,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0",
             playStyleSql,
             playRankSql,
             playStyleSql,
             playRankSql];
        }
        [sql_lamp appendFormat:@") AS tblResults) GROUP BY status"];
        NSLog(@"\n%@",sql_lamp);
        
        FMResultSet *rs_lamp = [database executeQuery:sql_lamp];
        while ([rs_lamp next]) {
            int status = [rs_lamp intForColumn:@"status"];
            int count =  [rs_lamp intForColumn:@"count(music_id)"];
            NSLog(@"result_lamp %d, %d",status,count);
            
            [self.clearDetailArray insertObject:[NSString stringWithFormat:@"%d",count] atIndex:status];
        }
        
        [rs_lamp close];
        
        //難易度検索
        for (int i = 1; i <= 12; i++) {
            int resultSum = 0;
            int min = -1;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"0" forKey:@"C"];
            [dic setObject:@"0" forKey:@"H"];
            [dic setObject:@"0" forKey:@"EXH"];
            [dic setObject:@"0" forKey:@"FC"];
            [dic setObject:@"0" forKey:@"sum"];
            
            NSMutableString *sql_level = [NSMutableString stringWithFormat:@"SELECT status,count(status) AS min,count(music_id) FROM ( SELECT tblResults.* FROM("];
            if ([playRankSql isEqualToString:@"UNION_ALL"]) {
                [sql_level appendFormat:@"SELECT music_id,%@_Normal_Level AS level,%@_Normal_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d",
                playStyleSql,
                playStyleSql,
                i];

                [sql_level appendFormat:@" UNION ALL "];
                [sql_level appendFormat:@"SELECT music_id,%@_Hyper_Level AS level,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
                
                [sql_level appendFormat:@" UNION ALL "];
                [sql_level appendFormat:@"SELECT music_id,%@_Another_Level AS level,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
            }
            else if ([playRankSql isEqualToString:@"AnotherAndHyper"]) {
                
                [sql_level appendFormat:@"SELECT music_id,%@_Hyper_Level AS level,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d AND %@_Another_Level = 0",
                 playStyleSql,
                 playStyleSql,
                 i,
                 playStyleSql];
                
                [sql_level appendFormat:@" UNION ALL "];
                [sql_level appendFormat:@"SELECT music_id,%@_Another_Level AS level,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
                
            }
            else{
                [sql_level appendFormat:@"SELECT music_id,%@_%@_Level AS level,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d",
                                    playStyleSql,
                                    playRankSql,
                                    playStyleSql,
                                    playRankSql,
                                    i];
            }
            [sql_level appendFormat:@") AS tblResults) GROUP BY status"];
        
            NSLog(@"sql_level \n%@",sql_level);
            FMResultSet *rs_level = [database executeQuery:sql_level];
            while ([rs_level next]) {
                int status = [rs_level intForColumn:@"status"];
                int count =  [rs_level intForColumn:@"count(music_id)"];
                resultSum += count;
                NSLog(@"result_level_%d %d, %d",i,status,count);
                
                if (min == -1 && count > 0) {
                    min = status;
                }
                
                switch (status) {
                    case 4:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"C"];
                        break;
                    case 5:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"H"];
                        break;
                    case 6:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"EXH"];
                        break;
                    case 7:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"FC"];
                        break;
                    default:
                        break;
                }                
            }
            [dic setObject:[NSString stringWithFormat:@"%d",resultSum] forKey:@"sum"];
            if (min == -1) {
                min = 0;
            }
            [dic setObject:[NSString stringWithFormat:@"%d",min] forKey:@"min"];
            [self.levelDetailArray insertObject:dic atIndex:i - 1];
            [rs_level close];
        }
        
        
        //バージョン検索
        for (int i = 1; i <= NEWEST_VERSION; i++) {
            int resultSum = 0;
            int min = -1;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"0" forKey:@"C"];
            [dic setObject:@"0" forKey:@"H"];
            [dic setObject:@"0" forKey:@"EXH"];
            [dic setObject:@"0" forKey:@"FC"];
            [dic setObject:@"0" forKey:@"sum"];
            
            NSMutableString *sql_version = [NSMutableString stringWithFormat:@"SELECT status,count(music_id) FROM ( SELECT tblResults.* FROM("];
            if ([playRankSql isEqualToString:@"UNION_ALL"]) {
                [sql_version appendFormat:@"SELECT music_id,%@_Normal_Level AS level,%@_Normal_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
                
                [sql_version appendFormat:@" UNION ALL "];
                [sql_version appendFormat:@"SELECT music_id,%@_Hyper_Level AS level,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
                
                [sql_version appendFormat:@" UNION ALL "];
                [sql_version appendFormat:@"SELECT music_id,%@_Another_Level AS level,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
            }
            else if ([playRankSql isEqualToString:@"AnotherAndHyper"]) {
                
                [sql_version appendFormat:@"SELECT music_id,%@_Hyper_Level AS level,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d AND %@_Another_Level = 0",
                 playStyleSql,
                 playStyleSql,
                 i,
                 playStyleSql];
                
                [sql_version appendFormat:@" UNION ALL "];
                [sql_version appendFormat:@"SELECT music_id,%@_Another_Level AS level,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d",
                 playStyleSql,
                 playStyleSql,
                 i];
                
            }
            else{
                [sql_version appendFormat:@"SELECT music_id,%@_%@_Level AS level,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d",
                                    playStyleSql,
                                    playRankSql,
                                    playStyleSql,
                                    playRankSql,
                                    i];
            }
            [sql_version appendFormat:@") AS tblResults WHERE level != 0) GROUP BY status"];
            
            NSLog(@"sql_version \n%@",sql_version);
            FMResultSet *rs_version = [database executeQuery:sql_version];
            while ([rs_version next]) {
                int status = [rs_version intForColumn:@"status"];
                int count =  [rs_version intForColumn:@"count(music_id)"];
                resultSum += count;
                NSLog(@"result_version_%d %d, %d",i,status,count);
                
                if (min == -1 && count > 0) {
                    min = status;
                }
                
                switch (status) {
                    case 4:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"C"];
                        break;
                    case 5:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"H"];
                        break;
                    case 6:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"EXH"];
                        break;
                    case 7:
                        [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"FC"];
                        break;
                    default:
                        break;
                }
            }

            [dic setObject:[NSString stringWithFormat:@"%d",resultSum] forKey:@"sum"];
            if (min == -1) {
                min = 0;
            }
            [dic setObject:[NSString stringWithFormat:@"%d",min] forKey:@"min"];
            [self.versionDetailArray insertObject:dic atIndex:i - 1];
            [rs_version close];
        }
    
        [database close];
        [self.tablelView reloadData];
        
    }else{
        NSLog(@"Could not open db.");
    }
    
}

- (void)setSortType:(UIBarButtonItem *)b{
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
//    as.tag = -1;
    as.title = @"選択してください。";
    [as addButtonWithTitle:@"SP ALL"];
    [as addButtonWithTitle:@"SP NORMAL"];
    [as addButtonWithTitle:@"SP HYPER"];
    [as addButtonWithTitle:@"SP ANOTHER"];
    [as addButtonWithTitle:@"SP A+H"];
    [as addButtonWithTitle:@"DP ALL"];
    [as addButtonWithTitle:@"DP NORMAL"];
    [as addButtonWithTitle:@"DP HYPER"];
    [as addButtonWithTitle:@"DP ANOTHER"];
    [as addButtonWithTitle:@"DP A+H"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 10;
    [as showFromTabBar:self.tabBarController.tabBar];
}

- (void)update:(UIBarButtonItem *)b{
    NSLog(@"reload");
        
    //ぐるぐるを出す
    grayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.0;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = self.navigationController.view.center;
    [indicator startAnimating];
    [grayView addSubview:indicator];
    [self.navigationController.view addSubview: grayView];
    
    [UIView animateWithDuration:0.3f animations:^(void) {
        grayView.alpha = 0.6;
        
    }completion:^(BOOL finished){
        if([DatabaseManager updateDatabase]){
            [self reloadTable];
        }
        [self hideAnimation];
    }];
}

- (void)hideAnimation{
    [UIView animateWithDuration:0.3f animations:^(void) {
        grayView.alpha = 0.0;
        
    }completion:^(BOOL finished){
        [indicator removeFromSuperview];
        [grayView removeFromSuperview];
    }];
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"index %d",buttonIndex);
    switch (buttonIndex) {
        case 0:
            playStyleSortType = 0;
            playRankSortType = 4;
            self.button.title = @"SP ALL";
            break;
        case 1:
            playStyleSortType = 0;
            playRankSortType = 0;
            self.button.title = @"SP NORMAL";
            break;
        case 2:
            playStyleSortType = 0;
            playRankSortType = 1;
            self.button.title = @"SP HYPER";
            break;
        case 3:
            playStyleSortType = 0;
            playRankSortType = 2;
            self.button.title = @"SP ANOTHER";
            break;
        case 4:
            playStyleSortType = 0;
            playRankSortType = 3;
            self.button.title = @"SP A+H";
            break;
        case 5:
            playStyleSortType = 1;
            playRankSortType = 4;
            self.button.title = @"DP ALL";
            break;
        case 6:
            playStyleSortType = 1;
            playRankSortType = 0;
            self.button.title = @"DP NORMAL";
            break;
        case 7:
            playStyleSortType = 1;
            playRankSortType = 1;
            self.button.title = @"DP HYPER";
            break;
        case 8:
            playStyleSortType = 1;
            playRankSortType = 2;
            self.button.title = @"DP ANOTHER";
            break;
        case 9:
            playStyleSortType = 1;
            playRankSortType = 3;
            self.button.title = @"DP A+H";
            break;
            
        default:
            return;
            break;
    }
    [USER_DEFAULT setInteger:playStyleSortType forKey:DEFAULT_PLAYSTYLE_KEY];
    [USER_DEFAULT setInteger:playRankSortType forKey:DEFAULT_PLAYRANK_KEY];
    [USER_DEFAULT synchronize];
    
    //セルの曲数を取得
    [self reloadTable];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.customDetailArray count] == 0) {
        return 3;
    }
    else{
        return 4;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([self.customDetailArray count] == 0) {
        section += 1;
    }

    switch (section) {
        case 0:
            return @"CUSTOM";
        break;
        case 1:
            return @"CLEAR";
        break;
        case 2:
            return @"LEVEL";
        break;
        case 3:
            return @"VERSION";
        break;

        default:
            return @"";
        break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.customDetailArray count] == 0) {
        section += 1;
    }
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.customDetailArray count];
            break;
        case 1:
            return [self.clearList count];
            break;
        case 2:
            return [self.levelList count];
            break;
        case 3:
            return [self.versionList count];
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HomeDetailCell";
    HomeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    int section = indexPath.section;
    if ([self.customDetailArray count] == 0) {
        section += 1;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (section) {
        case 0:
            cell.nameLabel.text = [[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"Count : %@",[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"count"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_main_%@",[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
            break;
        case 1:
            cell.nameLabel.text = [self.clearList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"Count : %@",[self.clearDetailArray objectAtIndex:7 - indexPath.row]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_main_%d",7 - indexPath.row]];
            break;
        case 2:
            cell.nameLabel.text = [self.levelList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"FC: %@  EX: %@  H: %@  C: %@   /%@",
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"FC"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"EXH"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"H"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"C"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"sum"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_main_%@",[[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
            break;
        case 3:
            cell.nameLabel.text = [self.versionList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"FC: %@  EX: %@  H: %@  C: %@   /%@",
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"FC"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"EXH"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"H"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"C"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"sum"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_main_%@",[[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
            break;
            
        default:
            break;
    }
        
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detail = [[DetailViewController alloc] init];
    
    detail.playRankSortType = playRankSortType;
    detail.playStyleSortType = playStyleSortType;
    detail.sortingType = [USER_DEFAULT integerForKey:DEFAULT_SORT_KEY];
    
    int section = indexPath.section;
    if ([self.customDetailArray count] == 0) {
        section += 1;
    }
    switch (section) {
        case 0:
            detail.playRankSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"playRank"] intValue];
            detail.sortingType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"sortType"] intValue];

            detail.clearSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"clearLamp"] intValue];
            
            detail.levelSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"difficulity"] intValue];
            detail.versionSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"version"] intValue];
            break;
            
        case 1:
            detail.clearSortType = indexPath.row + 1;
            
            detail.levelSortType = 0;
            detail.versionSortType = 0;
            break;
            
        case 2:
            detail.levelSortType = indexPath.row + 1;
            
            detail.clearSortType = 0;
            detail.versionSortType = 0;
            break;
            
        case 3:
            detail.versionSortType = indexPath.row + 1;
            
            detail.clearSortType = 0;
            detail.levelSortType = 0;
            break;
            
        default:
            break;
    }
    
    //プレイランクは選択されているもので検索
    
    
    [detail setTableData];
    [detail setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
