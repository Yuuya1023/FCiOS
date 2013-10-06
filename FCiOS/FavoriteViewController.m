//
//  FavoriteViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "FavoriteViewController.h"
#import "SBJson.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController
@synthesize tablelView = tableView_;
@synthesize button = button_;
@synthesize customDetailArray = customDetailArray_;
//@synthesize tagDictionary = tagDictionary_;
@synthesize tagDetailArray = tagDetailArray_;

- (id)init
{
    self = [super init];
    if (self) {
        self.tablelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 113) style:UITableViewStylePlain];
        self.tablelView.delegate = self;
        self.tablelView.dataSource = self;
        self.tablelView.rowHeight = 50;
        [self.view addSubview:self.tablelView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"Favorite";
        titleLabel.font = DEFAULT_FONT_TITLE;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleLabel;
        
        self.title = @"Favorite";
        self.tabBarItem.image = [UIImage imageNamed:@"star"];
        
        //選択されているプレイスタイル&プレイランクをセット
        playStyleSortType = [USER_DEFAULT integerForKey:DEFAULT_PLAYSTYLE_KEY];
        
        //ソートボタン
        NSString *playStyle;
        if (playStyleSortType == 0) {
            playStyle = @"SP";
        }
        else{
            playStyle = @"DP";
        }
        
        self.button = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@",playStyle]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:NSSelectorFromString(@"setSortType:")];
        self.navigationItem.leftBarButtonItem = self.button;
        
        //更新ボタン
        UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:NSSelectorFromString(@"update:")];
        self.navigationItem.rightBarButtonItem = updateButton;
        
        
        //配列初期化
        self.customDetailArray = [[NSMutableArray alloc] init];

        
        [self reloadTable];
    }
    return self;
}


- (void)reloadTable{
    [self setCustomDetail:playStyleSortType];
    [self setTagDetail:playStyleSortType];
    [self.tablelView reloadData];
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
        [self setCustomDetail:playStyleSortType];
        [self setTagDetail:playStyleSortType];
        [self.tablelView reloadData];
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
}


- (void)setTagDetail:(int)style{
    
//    tagDictionary_ = NULL;
    self.tagDetailArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *tagList;
    NSMutableDictionary *tagInfo;
    if (style == 0) {
        tagList = [[USER_DEFAULT objectForKey:SP_TAG_LIST_KEY] mutableCopy];
        tagInfo = [[USER_DEFAULT objectForKey:SP_TAG_INFO_KEY] mutableCopy];
    }
    else{
        tagList = [[USER_DEFAULT objectForKey:DP_TAG_LIST_KEY] mutableCopy];
        tagInfo = [[USER_DEFAULT objectForKey:DP_TAG_INFO_KEY] mutableCopy];
    }
    
    for(NSString *key in tagList){        
        NSDictionary *dic2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                              key, @"tagId",
                              [tagList objectForKey:key], @"tagName",
                              [[tagInfo objectForKey:key] objectForKey:@"count"] , @"count",
                              [[tagInfo objectForKey:key] objectForKey:@"min"] , @"min",
                              nil];
        [self.tagDetailArray addObject:dic2];
    }
    
//    // NSSortDescriptorを生成して
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagiId" ascending:YES];
//    // 配列に入れておいて
//    NSArray *sortarray = [NSArray arrayWithObject:sortDescriptor];
//    // ソートしちゃる！
//    NSArray *resultarray;
//    resultarray = [resultarray sortedArrayUsingDescriptors:sortarray];
//    NSLog(@"%@",resultarray);
    
    NSLog(@"%@",self.tagDetailArray);
    
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
    [as addButtonWithTitle:@"SP"];
    [as addButtonWithTitle:@"DP"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 2;
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
            self.button.title = @"SP";
            break;
        case 1:
            playStyleSortType = 1;
            self.button.title = @"DP";
            break;            
        default:
            return;
            break;
    }
    [USER_DEFAULT setInteger:playStyleSortType forKey:DEFAULT_PLAYSTYLE_KEY];
    [USER_DEFAULT synchronize];
    
    //セルの曲数を取得
    [self reloadTable];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    switch (section) {
        case 0:
            return @"CUSTOM";
            break;
        case 1:
            return @"TAG";
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
            return [self.customDetailArray count];
            break;
        case 1:
            return [self.tagDetailArray count];
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (section) {
        case 0:
            cell.nameLabel.text = [[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"Count : %@",[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"count"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_main_%@",[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
            break;
        case 1:
            cell.nameLabel.text = [[self.tagDetailArray objectAtIndex:indexPath.row] objectForKey:@"tagName"];
            cell.folderDetailLabel.text = [NSString stringWithFormat:@"Count : %@",[[self.tagDetailArray objectAtIndex:indexPath.row] objectForKey:@"count"]];
            cell.clearLamp.image = [UIImage imageNamed:[NSString stringWithFormat:@"clearLampImage_main_%@",[[self.tagDetailArray objectAtIndex:indexPath.row] objectForKey:@"min"]]];
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
    
    detail.playStyleSortType = playStyleSortType;
    detail.sortingType = [USER_DEFAULT integerForKey:DEFAULT_SORT_KEY];
    
    int section = indexPath.section;
    switch (section) {
        case 0:
            detail.playRankSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"playRank"] intValue];
            detail.sortingType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"sortType"] intValue];

            detail.clearSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"clearLamp"] intValue];
            
            detail.levelSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"difficulity"] intValue];
            detail.versionSortType = [[[self.customDetailArray objectAtIndex:indexPath.row] objectForKey:@"version"] intValue];
            break;
            
        case 1:
            detail.playRankSortType = 0;
            detail.clearSortType = 0;
            
            detail.levelSortType = 0;
            detail.versionSortType = 0;
            detail.tagId = [[[self.tagDetailArray objectAtIndex:indexPath.row] objectForKey:@"tagId"] intValue];
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
