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
@synthesize music_DB = music_DB_;
@synthesize userData_DB = userData_DB_;
@synthesize versionSortType = versionSortType_;
@synthesize levelSortType = levelSortType_;
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
        viewMode.text = @"sssssssssssssssss";
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
        
        self.checkList = [[NSMutableArray alloc] init];
    }
    return self;
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
    
    [self cancel];
}

- (void)editData:(UIBarButtonItem *)b{
    if (!editing) {
        self.navigationItem.rightBarButtonItem = nil;
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setTableData{
    NSLog(@"%d %d %d %d %d",self.versionSortType,self.levelSortType,self.playStyleSortType,self.playRankSortType,self.sortingType);
    self.tableData = [self dbSelector];
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

-(id) dbConnect:(NSString *)dbName{
    BOOL success;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
    NSLog(@"%@",writableDBPath);
    success = [fm fileExistsAtPath:writableDBPath];
    if(!success){
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
        success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if(!success){
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    return db;
}


- (NSMutableArray *)dbSelector{
    self.music_DB = [self dbConnect:@"musicMaster"];
    self.userData_DB = [self dbConnect:@"userData"];
    if ([self.music_DB open]) {
        [self.music_DB setShouldCacheStatements:YES];
        
        // SELECT
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
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
                playRankSql = [NSString stringWithFormat:@"Normal_Level"];
                break;
            case 1:
                playRankSql = [NSString stringWithFormat:@"Hyper_Level"];
                break;
            case 2:
                playRankSql = [NSString stringWithFormat:@"Another_Level"];
                break;
            default:
                playRankSql = @"UNION_ALL";
                break;
        }
        
        
        //        switch (self.sortingType) {
        //            case 0:
        //
        //                break;
        //
        //            default:
        //                break;
        //        }
        NSString *from = [NSString stringWithFormat:@""];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT music_id,name,version,%@%@ AS level FROM musicMaster where %@ and %@%@%@",
                                playStyleSql,
                                playRankSql,
                                versionSql,
                                playStyleSql,
                                playRankSql,
                                levelSql];
        
        if ([playRankSql isEqualToString:@"UNION_ALL"]) {
            sql = [NSMutableString stringWithFormat:@"SELECT music_id,name,version,%@Another_Level AS level FROM musicMaster where %@ and  %@Another_Level%@",
                   playStyleSql,
                   versionSql,
                   playStyleSql,
                   levelSql];
            
            [sql appendFormat:@" UNION ALL "];
            [sql appendFormat:@"SELECT music_id,name,version,%@Hyper_Level AS level FROM musicMaster where %@ and  %@Hyper_Level%@",
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql];
            
            [sql appendFormat:@" UNION ALL "];
            [sql appendFormat:@"SELECT music_id,name,version,%@Normal_Level AS level FROM musicMaster where %@ and  %@Normal_Level%@",
             playStyleSql,
             versionSql,
             playStyleSql,
             levelSql];
        }
        
        //ソートタイプ
        [sql appendFormat:@" ORDER BY LOWER(name) ASC"];
        NSLog(@"%@",sql);
        FMResultSet *rs = [self.music_DB executeQuery:sql];
        while ([rs next]) {
//            NSLog(@"result %d %@",[rs intForColumn:@"music_id"],[rs stringForColumn:@"name"]);
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"music_id"]],@"music_id",
                                 [rs stringForColumn:@"name"],@"name",
                                 [rs stringForColumn:@"level"],@"level",
//                                 [rs stringForColumn:@"type"],@"type",
                                 nil];
            
            [array addObject:dic];
            
        }
        [rs close];
        [self.music_DB close];
        
        return array;
        
    }else{
        NSLog(@"Could not open db.");
        return nil;
    }
    
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 8) {
        [self cancel];
    }
    else{
        editing = YES;
        editMode.text = [editTypes objectAtIndex:buttonIndex];
        toolBar.items = toolbarItemsInEditing;

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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if ([[self.checkList objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *detail1 = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"level"];
    NSString *detail2 = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"type"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Lv %@, type%@",detail1,detail2];
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
    
	
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
