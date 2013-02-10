//
//  SortConfigViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "SortConfigViewController.h"

@interface SortConfigViewController ()

@end

@implementation SortConfigViewController
@synthesize tablelVIew = tableVIew_;

@synthesize tableList = tableList_;
@synthesize clearList = clearList_;
@synthesize levelList = levelList_;
@synthesize versionList = versionList_;
@synthesize sortingList = sortingList_;
@synthesize playRankList = playRankList_;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Sort Setting";
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
        self.tableList = [[NSArray alloc] init];
        TableSources *tableSources = [[TableSources alloc] init];
        self.clearList = tableSources.clearSortList;
        self.levelList = tableSources.levelSortList;
        self.versionList = tableSources.versionSortList;
        self.sortingList = tableSources.sortingSortList;
        
        self.playStyleList = [[NSArray alloc] initWithObjects:@"SINGLE PLAY",@"DOUBLE PLAY", nil];
        self.playRankList = [[NSArray alloc] initWithObjects:@"NORMAL",@"HYPER",@"ANOTHER",@"ALL", nil];
        
        //キャンセルボタン
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(20, 320, 100, 40);
        cancelButton.alpha = 0.0;
        
        cancelLabel = [[UILabel alloc] init];
        cancelLabel.frame = cancelButton.frame;
        cancelLabel.center = cancelButton.center;
        cancelLabel.textAlignment = NSTextAlignmentCenter;
        cancelLabel.adjustsFontSizeToFitWidth = YES;
        cancelLabel.text = @"CANCEL";
        cancelLabel.font = DEFAULT_FONT;
        cancelLabel.alpha = 0.0;
        cancelLabel.backgroundColor = [UIColor clearColor];
        
        [cancelButton addTarget:self action:NSSelectorFromString(@"cancel:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];
        [self.view addSubview:cancelLabel];
        
        //ソート結果表示ボタン
        resultButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        resultButton.frame = CGRectMake(105, 320, 120, 40);

        buttonLabel = [[UILabel alloc] init];
        buttonLabel.frame = resultButton.frame;
        buttonLabel.center = resultButton.center;
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.adjustsFontSizeToFitWidth = YES;
        buttonLabel.text = @"RESULT";
        buttonLabel.font = DEFAULT_FONT;
        buttonLabel.backgroundColor = [UIColor clearColor];
        
        [resultButton addTarget:self action:NSSelectorFromString(@"showResult:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resultButton];
        [self.view addSubview:buttonLabel];
        
        //バージョン
        UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 20)];
        version.text = @"Version";
        version.font = DEFAULT_FONT;
        version.backgroundColor = [UIColor clearColor];
        
        versionSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 20, 190, 40)];
        versionSortLabel.text = @"20 tricoro";
        versionSortLabel.font = DEFAULT_FONT;
        versionSortType = 20;
        versionSortLabel.textAlignment = NSTextAlignmentRight;
        versionSortLabel.backgroundColor = [UIColor clearColor];
        
        versionSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        versionSelect.tag = 0;
        versionSelect.frame = CGRectMake(130, 20, 190, 40);
        [versionSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:versionSelect];
        [self.view addSubview:versionSortLabel];
        [self.view addSubview:version];
        
        //難易度
        UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 100, 20)];
        level.text = @"Difficulity";
        level.font = DEFAULT_FONT;
        level.backgroundColor = [UIColor clearColor];
        
        levelSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 70, 190, 40)];
        levelSortLabel.text = @"ALL";
        levelSortLabel.font = DEFAULT_FONT;
        levelSortType = 0;
        levelSortLabel.textAlignment = NSTextAlignmentRight;
        levelSortLabel.backgroundColor = [UIColor clearColor];
        
        levelSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        levelSelect.tag = 1;
        levelSelect.frame = CGRectMake(130, 70, 190, 40);
        [levelSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:levelSelect];
        [self.view addSubview:levelSortLabel];
        [self.view addSubview:level];
        
        //クリアランプ
        UILabel *clear = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 100, 20)];
        clear.text = @"Clear Lamp";
        clear.font = DEFAULT_FONT;
        clear.backgroundColor = [UIColor clearColor];
        
        clearSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 120, 190, 40)];
        clearSortLabel.text = @"ALL";
        clearSortLabel.font = DEFAULT_FONT;
        clearSortType = 0;
        clearSortLabel.textAlignment = NSTextAlignmentRight;
        clearSortLabel.backgroundColor = [UIColor clearColor];
        
        clearSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearSelect.tag = 2;
        clearSelect.frame = CGRectMake(130, 120, 190, 40);
        [clearSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clearSelect];
        [self.view addSubview:clearSortLabel];
        [self.view addSubview:clear];

        
        //プレイスタイル
        UILabel *playStyle = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 100, 20)];
        playStyle.text = @"PlayStyle";
        playStyle.font = DEFAULT_FONT;
        
        playStyleSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 170, 190, 40)];
        playStyleSortLabel.text = @"SINGLE PLAY";
        playStyleSortLabel.font = DEFAULT_FONT;
        playStyleSortLabel.textAlignment = NSTextAlignmentRight;
        playStyleSortLabel.backgroundColor = [UIColor clearColor];
        
        playStyleSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        playStyleSelect.tag = 3;
        playStyleSelect.frame = CGRectMake(130, 170, 190, 40);
        [playStyleSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:playStyleSelect];
        [self.view addSubview:playStyleSortLabel];
        [self.view addSubview:playStyle];
        
        //プレイランク
        UILabel *playRank = [[UILabel alloc] initWithFrame:CGRectMake(20, 210, 100, 20)];
        playRank.text = @"N/H/A";
        playRank.font = DEFAULT_FONT;
        
        playRankSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 220, 190, 40)];
        playRankSortLabel.text = @"ANOTHER";
        playRankSortLabel.font = DEFAULT_FONT;
        playRankSortType = 2;
        playRankSortLabel.textAlignment = NSTextAlignmentRight;
        playRankSortLabel.backgroundColor = [UIColor clearColor];
        
        playRankSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        playRankSelect.tag = 4;
        playRankSelect.frame = CGRectMake(130, 220, 190, 40);
        [playRankSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:playRankSelect];
        [self.view addSubview:playRankSortLabel];
        [self.view addSubview:playRank];
        
        //ソーティング
        UILabel *sorting = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 100, 20)];
        sorting.text = @"Sorting";
        sorting.font = DEFAULT_FONT;
        
        sortingSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 270, 190, 40)];
        sortingSortLabel.text = @"NONE";
        sortingSortLabel.font = DEFAULT_FONT;
        sortingSortLabel.textAlignment = NSTextAlignmentRight;
        sortingSortLabel.backgroundColor = [UIColor clearColor];
        
        sortingSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sortingSelect.tag = 5;
        sortingSelect.frame = CGRectMake(130, 270, 190, 40);
        [sortingSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sortingSelect];
        [self.view addSubview:sortingSortLabel];
        [self.view addSubview:sorting];

        //テーブル
        self.tablelVIew = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height)];
        self.tablelVIew.delegate = self;
        self.tablelVIew.dataSource = self;
        self.tablelVIew.alpha = 0.0;
        self.tablelVIew.backgroundColor = [UIColor grayColor];
        [self.view addSubview:self.tablelVIew];
        
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)selectSort:(UIButton *)b{
    selectedType = b.tag;
    switch (b.tag) {
        case 0:
            self.tableList = self.versionList;
            break;
        case 1:
            self.tableList = self.levelList;
            break;
        case 2:
            self.tableList = self.clearList;
            break;
        case 3:
            self.tableList = self.playStyleList;
            break;
        case 4:
            self.tableList = self.playRankList;
            break;
        case 5:
            self.tableList = self.sortingList;
            break;
        default:
            break;
    }
    [self.tablelVIew reloadData];
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.tablelVIew.frame = CGRectMake((self.view.bounds.size.width / 2) -30, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height);
        self.tablelVIew.alpha = 1.0;
        resultButton.alpha = 0.0;
        buttonLabel.alpha = 0.0;
        cancelButton.alpha = 1.0;
        cancelLabel.alpha = 1.0;
    }];
}

- (void)showResult:(UIButton *)b{
    DetailViewController *detail = [[DetailViewController alloc] init];
    detail.versionSortType = versionSortType;
    detail.levelSortType = levelSortType;
    detail.clearSortType = clearSortType;
    detail.playRankSortType = playRankSortType;
    detail.playStyleSortType = playStyleSortType;
    detail.sortingType = sortingType;
    
    [detail setTableData];
    [detail setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)cancel:(UIButton *)b{
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.tablelVIew.frame = CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height);
        self.tablelVIew.alpha = 0.0;
        resultButton.alpha = 1.0;
        buttonLabel.alpha = 1.0;
        cancelButton.alpha = 0.0;
        cancelLabel.alpha = 0.0;
    }];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.font = DEFAULT_FONT;
    cell.textLabel.text = [self.tableList objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}


-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.tablelVIew.frame = CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height);
        self.tablelVIew.alpha = 0.0;
        resultButton.alpha = 1.0;
        buttonLabel.alpha = 1.0;
        cancelButton.alpha = 0.0;
        cancelLabel.alpha = 0.0;
        switch (selectedType) {
            case 0:
                versionSortLabel.text = [self.versionList objectAtIndex:indexPath.row];
                versionSortType = indexPath.row;
                break;
            case 1:
                levelSortLabel.text = [self.levelList objectAtIndex:indexPath.row];
                levelSortType = indexPath.row;
                break;
            case 2:
                clearSortLabel.text = [self.clearList objectAtIndex:indexPath.row];
                clearSortType = indexPath.row;
                break;
            case 3:
                playStyleSortLabel.text = [self.playStyleList objectAtIndex:indexPath.row];
                playStyleSortType = indexPath.row;
                break;
            case 4:
                playRankSortLabel.text = [self.playRankList objectAtIndex:indexPath.row];
                playRankSortType = indexPath.row;
                break;
            case 5:
                sortingSortLabel.text = [self.sortingList objectAtIndex:indexPath.row];
                sortingType = indexPath.row;
                break;
            default:
                break;
        }
    }];
    
    NSLog(@"\n %@ \n %@ \n %@ \n %@ \n %@ \n %@",
          [self.versionList objectAtIndex:versionSortType],
          [self.levelList objectAtIndex:levelSortType],
          [self.clearList objectAtIndex:clearSortType],
          [self.playStyleList objectAtIndex:playStyleSortType],
          [self.playRankList objectAtIndex:playRankSortType],
          [self.sortingList objectAtIndex:sortingType]);
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
