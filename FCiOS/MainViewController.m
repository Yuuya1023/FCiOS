//
//  MainViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize tablelView = tableView_;
@synthesize button = button_;
@synthesize clearList = clearList_;
@synthesize levelList = levelList_;
@synthesize versionList = versionList_;
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
//        self.table.separatorColor = [UIColor lightGrayColor];
        [self.view addSubview:self.tablelView];
        
        self.title = @"Home";
        self.tabBarItem.image = [UIImage imageNamed:@"home"];
        
        //ソートボタン
        self.button = [[UIBarButtonItem alloc] initWithTitle:@"SP ANOTHER"
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
        self.clearDetailArray = [[NSMutableArray alloc] init];
        self.levelDetailArray = [[NSMutableArray alloc] init];
        self.versionDetailArray = [[NSMutableArray alloc] init];
        
        //選択されているプレイスタイル&プレイランクをセット
        playStyleSortType = 0;
        playRankSortType = 2;
        
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

//- (void)viewWillAppear:(BOOL)animated{
//	[super viewWillAppear:animated];
//    [self reloadTable];
//}

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
            default:
                break;
        }
        
        //クリアランプ検索
        NSMutableString *sql_lamp = [NSMutableString stringWithFormat:@"SELECT status,count(music_id) FROM ( SELECT tblResults.* FROM("];
        
        [sql_lamp appendFormat:@"SELECT music_id,%@_%@_Level AS level,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level != 0",
         playStyleSql,
         playRankSql,
         playStyleSql,
         playRankSql];
        
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
            
            NSString *sql_level = [NSString stringWithFormat:@"SELECT status,count(status) AS min,count(music_id) FROM ( SELECT tblResults.* FROM(SELECT music_id,%@_%@_Level AS level,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND level = %d) AS tblResults) GROUP BY status",
                                   playStyleSql,
                                   playRankSql,
                                   playStyleSql,
                                   playRankSql,
                                   i];
        
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
        for (int i = 1; i <= 20; i++) {
            int resultSum = 0;
            int min = -1;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"0" forKey:@"C"];
            [dic setObject:@"0" forKey:@"H"];
            [dic setObject:@"0" forKey:@"EXH"];
            [dic setObject:@"0" forKey:@"FC"];
            [dic setObject:@"0" forKey:@"sum"];
            
            NSString *sql_version = [NSString stringWithFormat:@"SELECT status,count(music_id) FROM ( SELECT tblResults.* FROM(SELECT music_id,%@_%@_Level AS level,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version = %d) AS tblResults WHERE level != 0) GROUP BY status",
                                   playStyleSql,
                                   playRankSql,
                                   playStyleSql,
                                   playRankSql,
                                   i];
            
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
    [as addButtonWithTitle:@"SP NORMAL"];
    [as addButtonWithTitle:@"SP HYPER"];
    [as addButtonWithTitle:@"SP ANOTHER"];
    [as addButtonWithTitle:@"DP NORMAL"];
    [as addButtonWithTitle:@"DP HYPER"];
    [as addButtonWithTitle:@"DP ANOTHER"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 6;
    [as showFromTabBar:self.tabBarController.tabBar];
}

- (void)update:(UIBarButtonItem *)b{
    NSLog(@"reload");
    [self reloadTable];    
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            playStyleSortType = 0;
            playRankSortType = 0;
            self.button.title = @"SP NORMAL";
            break;
        case 1:
            playStyleSortType = 0;
            playRankSortType = 1;
            self.button.title = @"SP HYPER";
            break;
        case 2:
            playStyleSortType = 0;
            playRankSortType = 2;
            self.button.title = @"SP ANOTHER";
            break;
        case 3:
            playStyleSortType = 1;
            playRankSortType = 0;
            self.button.title = @"DP NORMAL";
            break;
        case 4:
            playStyleSortType = 1;
            playRankSortType = 1;
            self.button.title = @"DP HYPER";
            break;
        case 5:
            playStyleSortType = 1;
            playRankSortType = 2;
            self.button.title = @"DP ANOTHER";
            break;
            
        default:
            break;
    }
    
    //セルの曲数を取得
    [self reloadTable];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"CLEAR";
        break;
        case 1:
            return @"LEVEL";
        break;
        case 2:
            return @"VERSION";
        break;

        default:
            return @"";
        break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.clearList count];
            break;
        case 1:
            return [self.levelList count];
            break;
        case 2:
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
            cell.nameLabel.text = [self.clearList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"Count : %@",[self.clearDetailArray objectAtIndex:7 - indexPath.row]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_%d",7 - indexPath.row]];
            break;
        case 1:
            cell.nameLabel.text = [self.levelList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"FC:%@ EXH:%@ H:%@ C:%@  /%@",
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"FC"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"EXH"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"H"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"C"],
                                           [[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"sum"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_%@",[[self.levelDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
            break;
        case 2:
            cell.nameLabel.text = [self.versionList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"FC:%@ EXH:%@ H:%@ C:%@  /%@",
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"FC"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"EXH"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"H"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"C"],
                                           [[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"sum"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_%@",[[self.versionDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
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
    switch (indexPath.section) {
        case 0:
            detail.clearSortType = indexPath.row + 1;
            
            detail.levelSortType = 0;
            detail.versionSortType = 0;
            break;
            
        case 1:
            detail.levelSortType = indexPath.row + 1;
            
            detail.clearSortType = 0;
            detail.versionSortType = 0;
            break;
            
        case 2:
            detail.versionSortType = indexPath.row + 1;
            
            detail.clearSortType = 0;
            detail.levelSortType = 0;
            break;
            
        default:
            break;
    }
    
    //プレイランクは選択されているもので検索
    detail.playRankSortType = playRankSortType;
    detail.playStyleSortType = playStyleSortType;
    
    [detail setTableData];
    [detail setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
