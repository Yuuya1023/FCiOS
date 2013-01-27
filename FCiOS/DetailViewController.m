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
        self.tableData = [self dbSelector];

//        NSLog(@"%@",self.tableData);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"%d %d %d %d %d",self.versionSortType,self.levelSortType,self.playStyleSortType,self.playRankSortType,self.sortingType);

    
    
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
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM musicMaster"];
        while ([rs next]) {
            NSLog(@"result %d %@",[rs intForColumn:@"music_id"],[rs stringForColumn:@"name"]);
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[rs intForColumn:@"music_id"]],@"music_id",
                                 [rs stringForColumn:@"name"],@"name",
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
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
