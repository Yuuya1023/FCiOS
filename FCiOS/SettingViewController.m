//
//  SettingViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/17.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "SettingViewController.h"
#import "TableSources.h"
#import "CustomSettingViewController.h"
#import "TagSettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize tablelView = tableView_;
@synthesize defaultSort = defaultSort_;
@synthesize customSPList = customSPList_;
@synthesize customDPList = customDPList_;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"Setting";
        titleLabel.font = DEFAULT_FONT_TITLE;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleLabel;
        self.title = @"Setting";
        self.tabBarItem.image = [UIImage imageNamed:@"setting"];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.tableList = [[NSArray alloc] init];
        TableSources *tableSources = [[TableSources alloc] init];
        self.defaultSort = tableSources.sortSetting;
        self.customSPList = tableSources.clearSortList;
        self.customDPList = tableSources.clearList;
        
//        //背景
//        UIView *infoBg = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 300, 80)];
//        infoBg.backgroundColor = [UIColor lightGrayColor];
//        [self.view addSubview:infoBg];
        
        //info
        infomation = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
        infomation.text = @"information";
        infomation.font = DEFAULT_FONT_ITALIC;
        [self.view addSubview:infomation];
        
        //アイコン
        appStore = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-72"]];
        appStore.frame = CGRectMake(25, 33, 72, 72);
        [self.view addSubview:appStore];
        
        //ロゴ
        logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        logo.frame = CGRectMake(125, 28, 100, 41);
        logo.backgroundColor = [UIColor clearColor];
        [self.view addSubview:logo];
        
        //アプリバージョン
        appVersion = [[UILabel alloc] initWithFrame:CGRectMake(127, 66, 120, 20)];
        appVersion.text = @"App Version :";
        appVersion.font = DEFAULT_FONT;
        [self.view addSubview:appVersion];
        
        appVersionText = [[UILabel alloc] initWithFrame:CGRectMake(245, 66, 50, 20)];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        appVersionText.text = [NSString stringWithFormat:@"%@",version];
        appVersionText.font = DEFAULT_FONT;
        appVersionText.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:appVersionText];


        //DBバージョン
        dataVersion = [[UILabel alloc] initWithFrame:CGRectMake(127, 83, 120, 20)];
        dataVersion.text = @"DB Version :";
        dataVersion.font = DEFAULT_FONT;
        dataVersion.backgroundColor = [UIColor clearColor];
        [self.view addSubview:dataVersion];
        
        dataVersionText = [[UILabel alloc] initWithFrame:CGRectMake(245, 83, 50, 20)];
//        dataVersionText.text = [NSString stringWithFormat:@"%@",[USER_DEFAULT objectForKey:DATABSEVERSION_KEY]];
        dataVersionText.font = DEFAULT_FONT;
        dataVersionText.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:dataVersionText];
        
        //other
        settings = [[UILabel alloc] initWithFrame:CGRectMake(10, 123, 100, 20)];
        settings.text = @"setting";
        settings.font = DEFAULT_FONT_ITALIC;
        [self.view addSubview:settings];

        
        //デフォルトソート
        defaultSort = [[UILabel alloc] initWithFrame:CGRectMake(15, 153, 100, 20)];
        defaultSort.text = @"Default Sort";
        defaultSort.font = DEFAULT_FONT;
        
        defaultSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 145, 190, 40)];
//        defaultSortLabel.text = [self.defaultSort objectAtIndex:[USER_DEFAULT integerForKey:DEFAULT_SORT_KEY]];
        defaultSortLabel.font = DEFAULT_FONT;
        defaultSortLabel.textAlignment = NSTextAlignmentRight;
        defaultSortLabel.backgroundColor = [UIColor clearColor];
        
        defaultSortButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        defaultSortButton.tag = 0;
        defaultSortButton.frame = CGRectMake(125, 145, 190, 40);
        [defaultSortButton addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:defaultSort];
        [self.view addSubview:defaultSortButton];
        [self.view addSubview:defaultSortLabel];
        

        //カスタム
        custom = [[UILabel alloc] initWithFrame:CGRectMake(15, 208, 100, 20)];
        custom.text = @"Custom Sort";
        custom.font = DEFAULT_FONT;
        [self.view addSubview:custom];
        
        //SP
        customLabelSP = [[UILabel alloc] initWithFrame:CGRectMake(115, 200, 190, 40)];
        customLabelSP.text = @"SP";
        customLabelSP.font = DEFAULT_FONT;
        customLabelSP.textAlignment = NSTextAlignmentRight;
        customLabelSP.backgroundColor = [UIColor clearColor];
        
        custom_SP = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        custom_SP.tag = 0;
        custom_SP.frame = CGRectMake(125, 200, 190, 40);
        [custom_SP addTarget:self action:NSSelectorFromString(@"customSetting:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:custom_SP];
        [self.view addSubview:customLabelSP];
        
        //DP
        customLabelDP = [[UILabel alloc] initWithFrame:CGRectMake(115, 250, 190, 40)];
        customLabelDP.text = @"DP";
        customLabelDP.font = DEFAULT_FONT;
        customLabelDP.textAlignment = NSTextAlignmentRight;
        customLabelDP.backgroundColor = [UIColor clearColor];
        
        custom_DP = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        custom_DP.tag = 1;
        custom_DP.frame = CGRectMake(125, 250, 190, 40);
        [custom_DP addTarget:self action:NSSelectorFromString(@"customSetting:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:custom_DP];
        [self.view addSubview:customLabelDP];
        
        
        //タグ設定
        tagSetting = [[UILabel alloc] initWithFrame:CGRectMake(15, 298, 100, 40)];
        tagSetting.text = @"Tag";
        tagSetting.font = DEFAULT_FONT;
        tagSetting.textAlignment = NSTextAlignmentLeft;
        tagSetting.backgroundColor = [UIColor clearColor];
        
        tagSettingLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 298, 190, 40)];
        tagSettingLabel.text = @"Tag Setting";
        tagSettingLabel.font = DEFAULT_FONT;
        tagSettingLabel.textAlignment = NSTextAlignmentRight;
        tagSettingLabel.backgroundColor = [UIColor clearColor];
        
        tagSettingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        tagSettingButton.tag = 2;
        tagSettingButton.frame = CGRectMake(125, 300, 190, 40);
        [tagSettingButton addTarget:self action:NSSelectorFromString(@"tagSetting:") forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:tagSetting];
        [self.view addSubview:tagSettingButton];
        [self.view addSubview:tagSettingLabel];
        

        //キャンセルボタン
//        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        cancelButton.frame = CGRectMake(15, 320, 100, 40);
//        [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
//        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        cancelButton.titleLabel.font = DEFAULT_FONT;
//        cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//        cancelButton.alpha = 0.0;
//        
//        [cancelButton addTarget:self action:NSSelectorFromString(@"cancel:") forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:cancelButton];
        
        
        
        float positionX = (self.view.bounds.size.width / 2) - 40;
        pageSizeX = (self.view.bounds.size.width / 2) + 40;
        
        pageView = [[UIScrollView alloc] init];
        pageView.frame = CGRectMake(positionX, 0, pageSizeX, self.view.bounds.size.height);
        pageView.contentSize = CGSizeMake(pageSizeX * 2, self.view.bounds.size.height);
        pageView.delegate = self;
        pageView.pagingEnabled = YES;
        pageView.bounces = NO;
        pageView.showsHorizontalScrollIndicator = NO;
        pageView.alpha = 0.0;
        pageView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:pageView];
        
        
        //テーブル
        self.tablelView = [[UITableView alloc] initWithFrame:CGRectMake(pageSizeX, 0, (self.view.bounds.size.width / 2) + 40, self.view.bounds.size.height)];
        self.tablelView.delegate = self;
        self.tablelView.dataSource = self;
        self.tablelView.alpha = 1.0;
        self.tablelView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
        [pageView addSubview:self.tablelView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    dataVersionText.text = [NSString stringWithFormat:@"%@",[USER_DEFAULT objectForKey:DATABSEVERSION_KEY]];
    defaultSortLabel.text = [self.defaultSort objectAtIndex:[USER_DEFAULT integerForKey:DEFAULT_SORT_KEY]];
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float page = pageView.contentOffset.x / pageView.bounds.size.width;
//    NSLog(@"page %f",page);
    
    if (scrollView.alpha != 1.0) {
        return;
    }
    
    if (page == 0) {
        pageView.alpha = 0.0;
    }
    
    float alpha = 1 - (page * 0.8);
    
    infomation.alpha = alpha;
    appStore.alpha = alpha;
    settings.alpha = 1 - (page * 0.5);
    
    if (selectedType != 0) {
        defaultSort.alpha = alpha;
    }
    if (selectedType != 1 && selectedType != 2) {
        custom.alpha = alpha;
    }
    if (selectedType != 2) {
        tagSetting.alpha = alpha;
    }
}








- (void)selectSort:(UIButton *)b{
    selectedType = b.tag;
    switch (b.tag) {
        case 0:
            self.tableList = self.defaultSort;
            break;
        case 1:
            self.tableList = self.customSPList;
            break;
        case 2:
            self.tableList = self.customDPList;
            break;
        default:
            break;
    }
    [self.tablelView reloadData];
    [UIView animateWithDuration:0.5f animations:^(void) {
//        self.tablelView.frame = CGRectMake((self.view.bounds.size.width / 2) -40, 0, (self.view.bounds.size.width / 2) + 40, self.view.bounds.size.height);
        pageView.contentOffset = CGPointMake(pageSizeX, 0);
        pageView.alpha = 1.0;
        [self setAlpha:YES tag:b.tag];
    }];
}

- (void)customSetting:(UIButton *)b{
    CustomSettingViewController *customPage = [[CustomSettingViewController alloc] init];
    [customPage setPagesWithPlayStyle:b.tag];
    [customPage setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:customPage animated:YES];
}


- (void)tagSetting:(UIButton *)b{

    TagSettingViewController *tagSettingPage = [[TagSettingViewController alloc] init];
    [tagSettingPage setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tagSettingPage animated:YES];
    
}

- (void)cancel:(UIButton *)b{
    [UIView animateWithDuration:0.5f animations:^(void) {
//        self.tablelView.frame = CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 40, self.view.bounds.size.height);
        pageView.contentOffset = CGPointMake(0, 0);
        pageView.alpha = 0.0;
        [self setAlpha:NO tag:0];
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
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (void)setAlpha:(BOOL)isSelecting tag:(int)tag{
    if (isSelecting) {
        self.tablelView.alpha = 1.0;
//        cancelButton.alpha = 1.0;
        
        infomation.alpha = 0.2;
        appStore.alpha = 0.2;
        settings.alpha = 0.5;
        
        if (tag != 0) {
            defaultSort.alpha = 0.2;
        }
        if (tag != 1 && tag != 2) {
            custom.alpha = 0.2;
        }
        if (tag != 2) {
            tagSetting.alpha = 0.2;
        }
    }
    else{
        self.tablelView.alpha = 0.0;
//        cancelButton.alpha = 0.0;
        
        infomation.alpha = 1.0;
        appStore.alpha = 1.0;
        settings.alpha = 1.0;
        
        defaultSort.alpha = 1.0;
        custom.alpha = 1.0;
        tagSetting.alpha = 1.0;
    }
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [UIView animateWithDuration:0.5f animations:^(void) {
//        self.tablelView.frame = CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height);
        pageView.contentOffset = CGPointMake(0, 0);
        pageView.alpha = 0.0;
        [self setAlpha:NO tag:0];
        switch (selectedType) {
            case 0:
                defaultSortLabel.text = [self.defaultSort objectAtIndex:indexPath.row];
                [USER_DEFAULT setInteger:indexPath.row forKey:DEFAULT_SORT_KEY];
                [USER_DEFAULT synchronize];
                break;
            case 1:
//                levelSortLabel.text = [self.levelList objectAtIndex:indexPath.row];
//                levelSortType = indexPath.row;
                break;
            case 2:
//                clearSortLabel.text = [self.clearList objectAtIndex:indexPath.row];
//                clearSortType = indexPath.row;
                break;

            default:
                break;
        }
    }];    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
