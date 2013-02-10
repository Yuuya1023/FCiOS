//
//  DetailViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize table = table_;
@synthesize button = button_;

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
//        self.table.separatorColor = [UIColor lightGrayColor];
        [self.view addSubview:self.table];
        
        self.button = [[UIBarButtonItem alloc] initWithTitle:@"一括編集"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editData:)];
        self.navigationItem.rightBarButtonItem = self.button;
        
        
        //ツールバー
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 108, [UIScreen mainScreen].bounds.size.width, 44)];
        toolBar.barStyle = UIBarStyleBlack;
        [self.view addSubview:toolBar];
        
        
        //ツールバーアイテム
        //通常
        viewMode = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width - 25, 40)];
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
        toolbarItemsInEditing = [[NSArray alloc] initWithObjects:labelBtn2,canelBtn,okBtn, nil];

        
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

- (void)cancel{
    editing = NO;
    self.navigationItem.rightBarButtonItem = self.button;
    toolBar.items = toolbarItems;
    [self clearCheckList];
    [self.table reloadData];
}

- (void)commitUpdate{
    NSLog(@"update");
    for (int i = 0; i < [self.checkList count]; i++) {
        if ([[self.checkList objectAtIndex:i] isEqualToString:@"1"]) {
            //update
            int music_id = [[[self.tableData objectAtIndex:i] objectForKey:@"music_id"] intValue];
            int status = someEditType;
            int playRank = [[[self.tableData objectAtIndex:i] objectForKey:@"type"] intValue];
            int style = self.playStyleSortType;
            
            [self dbUpdate:music_id changeToStatus:status playRank:playRank style:style];
            [self setTableData];
        }
        else{
            
        }
    }
    
    [self cancel];
}

- (void)editData:(UIBarButtonItem *)b{
    if (!editing) {
        self.navigationItem.rightBarButtonItem = nil;
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.tag = -1;
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



- (void)setTableData{
    NSLog(@"%d %d %d %d %d",self.versionSortType,self.levelSortType,self.playStyleSortType,self.playRankSortType,self.sortingType);
    [self.tableData removeAllObjects];
    [self dbSelector];
    self.title = [NSString stringWithFormat:@"%d曲",[self.tableData count]];
    //セルチェックリスト
    for (int i = 0; i <= [self.tableData count]; i++){
        [self.checkList addObject:@"0"];
    }

    [self.table reloadData];
}

- (void)clearCheckList{
    [self.checkList removeAllObjects];
    for (int i = 0; i <= [self.tableData count]; i++){
        [self.checkList addObject:@"0"];
    }
}




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
        NSString *playStyleSql;
        if (self.playStyleSortType == 0) {
            playStyleSql = [NSString stringWithFormat:@"SP_"];
        }
        else{
            playStyleSql = [NSString stringWithFormat:@"DP_"];
        }
        
        NSString *playRankSql;
        switch (self.playRankSortType) {
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
                playRankSql = @"UNION_ALL";
                break;
        }
        
        //クリアランプそーと
        NSString *statusSort = @"";
        switch (self.clearSortType) {
            case 1:
                statusSort = @"AND status = 7";
                break;
            case 2:
                statusSort = @"AND status = 6";
                break;
            case 3:
                statusSort = @"AND status = 5";
                break;
            case 4:
                statusSort = @"AND status = 4";
                break;
            case 5:
                statusSort = @"AND status = 3";
                break;
            case 6:
                statusSort = @"AND status = 2";
                break;
            case 7:
                statusSort = @"AND status = 1";
                break;
            case 8:
                statusSort = @"AND status = 0";
                break;
            case 9:
                statusSort = @"AND status < 7";
                break;
            case 10:
                statusSort = @"AND status < 6";
                break;
            case 11:
                statusSort = @"AND status < 5";
                break;
            case 12:
                statusSort = @"AND status < 4";
                break;
            case 13:
                statusSort = @"AND status < 3";
                break;
            default:
                break;
        }
        

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
                [sql appendFormat:@") AS tblResults ORDER BY LOWER(tblResults.name) ASC"];
                break;
            case 1:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.status ASC,LOWER(tblResults.name) ASC"];
                break;
            case 2:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.status DESC,LOWER(tblResults.name) ASC"];
                break;
            case 3:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.level ASC,LOWER(tblResults.name) ASC"];
                break;
            case 4:
                [sql appendFormat:@") AS tblResults ORDER BY tblResults.level DESC,LOWER(tblResults.name) ASC"];
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
        viewMode.text = [NSString stringWithFormat:@"FC:%d  EXH:%d  H:%d  C:%d EC:%d AC:%d F:%d NO:%d",fcCount,exCount,hcCount,clCount,ecCount,acCount,faCount,npCount];
        
        [rs2 close];
        [database close];
        
    }else{
        NSLog(@"Could not open db.");
    }
    
}

- (void)dbUpdate:(int)music_id changeToStatus:(int)status playRank:(int)playRank style:(int)style{
    
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
        
        NSString *playRankSql;
        switch (playRank) {
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
                playRankSql = @"UNION_ALL";
                break;
        }
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE userData SET %@%@_Status = %d WHERE music_id = %d",
                         playStyleSql,
                         playRankSql,
                         status,
                         music_id];
        NSLog(@"\n update sql \n %@",sql);
        [database executeUpdate:sql];
        
        //エラー処理
        if ([database hadError]) {
            NSLog(@"update error %d: %@",[database lastErrorCode],[database lastErrorMessage]);
            [database rollback];
        }
        else{
            [database commit];
        }
        
        [database close];
    }
    else{
        NSLog(@"Could not open db.");
    }
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 8) {
        [self cancel];
    }
    else{
        //一括編集から出した場合
        if (actionSheet.tag == -1) {
            editing = YES;
            someEditType = 7 - buttonIndex;
            editMode.text = [editTypes objectAtIndex:buttonIndex];
            toolBar.items = toolbarItemsInEditing;
        }
        //セルをタップした際
        else {
            NSLog(@"tag = %d",actionSheet.tag);
            int tag = actionSheet.tag;
            //update
            int music_id = [[[self.tableData objectAtIndex:tag] objectForKey:@"music_id"] intValue];
            int status = 7 - buttonIndex;
            int playRank = [[[self.tableData objectAtIndex:tag] objectForKey:@"type"] intValue];
            int style = self.playStyleSortType;

            [self dbUpdate:music_id changeToStatus:status playRank:playRank style:style];
            [self setTableData];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            cell.difficulityLabel.textColor = [UIColor yellowColor];
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
        NSString *name = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSString *type = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"type"];
        NSLog(@"cell name %@, type = %@",name,type);
        
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.tag = indexPath.row;
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

@end
