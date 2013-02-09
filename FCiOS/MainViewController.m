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

- (id)init
{
    self = [super init];
    if (self) {
        self.tablelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108) style:UITableViewStylePlain];
        self.tablelView.delegate = self;
        self.tablelView.dataSource = self;
        self.tablelView.rowHeight = 50;
//        self.table.separatorColor = [UIColor lightGrayColor];
        [self.view addSubview:self.tablelView];
        
        self.title = @"Home";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
        self.button = [[UIBarButtonItem alloc] initWithTitle:@"SP ANOTHER"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(setSortType:)];
        self.navigationItem.rightBarButtonItem = self.button;
        
        TableSources *tableSources = [[TableSources alloc] init];
        self.clearList = tableSources.clearList;
        self.versionList = tableSources.versionList;
        self.levelList = tableSources.levelList;
        
        //配列初期化
        self.clearDetailArray = [[NSMutableArray alloc] init];
        
        [self initializeArray];
        
        //選択されているプレイスタイル&プレイランクをセット
        playStyleSortType = 0;
        playRankSortType = 2;
        [self dbSelector];
        
    }
    return self;
}

- (void)initializeArray{
    [self.clearDetailArray removeAllObjects];
    for (int i = 0; i <= 7; i++){
        [self.clearDetailArray addObject:@"0"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            NSLog(@"result %d, %d",status,count);
            
            [self.clearDetailArray insertObject:[NSString stringWithFormat:@"%d",count] atIndex:status];
        }
        
        [rs_lamp close];

        
        //難易度検索
        
        
        
        
        
        //バージョン検索
        
        
//        //バージョン
//        NSString *versionSql;
//        if (self.versionSortType == 0) {
//            versionSql = @"version < 21";
//        }
//        else{
//            versionSql = [NSString stringWithFormat:@"version = %d",self.versionSortType];
//        }
//        
//        //レベル
//        NSString *levelSql;
//        if (self.levelSortType == 0) {
//            levelSql = @"< 13";
//        }
//        else{
//            levelSql = [NSString stringWithFormat:@" = %d",self.levelSortType];
//        }
//        NSString *playStyleSql;
//        if (self.playStyleSortType == 0) {
//            playStyleSql = [NSString stringWithFormat:@"SP_"];
//        }
//        else{
//            playStyleSql = [NSString stringWithFormat:@"DP_"];
//        }
//        
//
//        //クリアランプそーと
//        NSString *statusSort = @"";
//        switch (self.clearSortType) {
//            case 1:
//                statusSort = @"AND status = 7";
//                break;
//            case 2:
//                statusSort = @"AND status = 6";
//                break;
//            case 3:
//                statusSort = @"AND status = 5";
//                break;
//            case 4:
//                statusSort = @"AND status = 4";
//                break;
//            case 5:
//                statusSort = @"AND status = 3";
//                break;
//            case 6:
//                statusSort = @"AND status = 2";
//                break;
//            case 7:
//                statusSort = @"AND status = 1";
//                break;
//            case 8:
//                statusSort = @"AND status = 0";
//                break;
//            case 9:
//                statusSort = @"AND status < 7";
//                break;
//            case 10:
//                statusSort = @"AND status < 6";
//                break;
//            case 11:
//                statusSort = @"AND status < 5";
//                break;
//            case 12:
//                statusSort = @"AND status < 4";
//                break;
//            case 13:
//                statusSort = @"AND status < 3";
//                break;
//            default:
//                break;
//        }
//        
//        
//        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT tblResults.* FROM("];
//        
//        //N/H/Aすべての結果を表示
//        if ([playRankSql isEqualToString:@"UNION_ALL"]) {
//            [sql appendFormat:@"SELECT music_id,name,version,%@Normal_Level AS level,%@Normal_Status AS status,selectType_Normal AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Normal_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//             playStyleSql,
//             playStyleSql,
//             versionSql,
//             playStyleSql,
//             levelSql,
//             statusSort];
//            
//            [sql appendFormat:@" UNION ALL "];
//            [sql appendFormat:@"SELECT music_id,name,version,%@Hyper_Level AS level,%@Hyper_Status AS status,selectType_Hyper AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Hyper_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//             playStyleSql,
//             playStyleSql,
//             versionSql,
//             playStyleSql,
//             levelSql,
//             statusSort];
//            
//            [sql appendFormat:@" UNION ALL "];
//            [sql appendFormat:@"SELECT music_id,name,version,%@Another_Level AS level ,%@Another_Status AS status,selectType_Another AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND  %@Another_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//             playStyleSql,
//             playStyleSql,
//             versionSql,
//             playStyleSql,
//             levelSql,
//             statusSort];
//            
//        }
//        else{
//            //プレイランクを指定したとき
//            [sql appendFormat:@"SELECT music_id,name,version,%@%@_Level AS level,%@%@_Status AS status,selectType_%@ AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@%@_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//             playStyleSql,
//             playRankSql,
//             playStyleSql,
//             playRankSql,
//             playRankSql,
//             versionSql,
//             playStyleSql,
//             playRankSql,
//             levelSql,
//             statusSort];
//        }
//        
//        NSString *sql_tmp = [NSString stringWithFormat:@"%@) AS tblResults",sql];
//        
//        
//        //ソート順
//        switch (self.sortingType) {
//            case 0:
//                [sql appendFormat:@") AS tblResults ORDER BY LOWER(tblResults.name) ASC"];
//                break;
//            case 1:
//                [sql appendFormat:@") AS tblResults ORDER BY tblResults.status ASC,LOWER(tblResults.name) ASC"];
//                break;
//            case 2:
//                [sql appendFormat:@") AS tblResults ORDER BY tblResults.status DESC,LOWER(tblResults.name) ASC"];
//                break;
//            case 3:
//                [sql appendFormat:@") AS tblResults ORDER BY tblResults.level ASC,LOWER(tblResults.name) ASC"];
//                break;
//            case 4:
//                [sql appendFormat:@") AS tblResults ORDER BY tblResults.level DESC,LOWER(tblResults.name) ASC"];
//                break;
//                
//            default:
//                break;
//        }
//        
//        NSLog(@"\n%@",sql);
//        FMResultSet *rs = [database executeQuery:sql];
//        while ([rs next]) {
//            //            NSLog(@"result %d %@",[rs intForColumn:@"music_id"],[rs stringForColumn:@"name"]);
//            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"music_id"]],@"music_id",
//                                 [rs stringForColumn:@"name"],@"name",
//                                 [rs stringForColumn:@"level"],@"level",
//                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"type"]],@"type",
//                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"status"]],@"status",
//                                 nil];
//            
//            [self.tableData addObject:dic];
//            
//        }
//        [rs close];
//        
//        
//
//        //フッターの統計ラベルに表示
//        viewMode.text = [NSString stringWithFormat:@"FC:%d  EXH:%d  HARD:%d  CLEAR:%d",fcCount,exCount,hcCount,clCount];
        
//        [rs2 close];
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
    [self initializeArray];
    [self dbSelector];
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
            return @"CELAR";
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
            break;
        case 1:
            cell.nameLabel.text = [self.levelList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = @"FC:100 EXH:100 H:100";
            break;
        case 2:
            cell.nameLabel.text = [self.versionList objectAtIndex:indexPath.row];
            cell.folderDetailLabel.text = @"FC:100 EXH:100 H:100";
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
