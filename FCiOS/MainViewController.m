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
        
        //選択されているプレイスタイル&プレイランクをセット
        playStyleSortType = 0;
        playRankSortType = 2;
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            cell.folderDetailLabel.text = @"Count : 573";
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
