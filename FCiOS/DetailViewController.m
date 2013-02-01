//
//  DetailViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "DetailViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#import "dbConnector.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize versionSortType = versionSortType_;
@synthesize levelSortType = levelSortType_;
@synthesize playStyleSortType = playStyleSortType_;
@synthesize playRankSortType = playRankSortType_;
@synthesize sortingType = sortingType_;
@synthesize tableData = tableData_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
//        NSLog(@"%@",self.tableData);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%d %d %d %d %d",self.versionSortType,self.levelSortType,self.playStyleSortType,self.playRankSortType,self.sortingType);
    self.tableData = [self dbSelector];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(id) dbConnect{
    BOOL success;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"musicMaster.db"];
    NSLog(@"%@",writableDBPath);
    success = [fm fileExistsAtPath:writableDBPath];
    if(!success){
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"musicMaster.db"];
        success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if(!success){
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    return db;
}


- (NSMutableArray *)dbSelector{
    FMDatabase* db = [self dbConnect];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        
        // SELECT
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
//        self.versionSortType,self.levelSortType,self.playStyleSortType,self.playRankSortType,self.sortingType
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
        [sql appendFormat:@" ORDER BY name ASC"];
        NSLog(@"%@",sql);
        FMResultSet *rs = [db executeQuery:sql];
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
        [db close];
        
        return array;
        
    }else{
        NSLog(@"Could not open db.");
        return nil;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
