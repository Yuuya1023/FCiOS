//
//  SettingViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/17.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "SettingViewController.h"
#import "TableSources.h"

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
        self.title = @"Setting";
        self.tabBarItem.image = [UIImage imageNamed:@"setting"];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.tableList = [[NSArray alloc] init];
        TableSources *tableSources = [[TableSources alloc] init];
        self.defaultSort = tableSources.sortSetting;
        self.customSPList = tableSources.clearSortList;
        self.customDPList = tableSources.clearList;
        
        //キャンセルボタン
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(15, 320, 100, 40);
        [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = DEFAULT_FONT;
        cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cancelButton.alpha = 0.0;
        
        [cancelButton addTarget:self action:NSSelectorFromString(@"cancel:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];

        //アプリバージョン
        appVersion = [[UILabel alloc] initWithFrame:CGRectMake(15, 28, 100, 20)];
        appVersion.text = @"App Version";
        appVersion.font = DEFAULT_FONT;
        [self.view addSubview:appVersion];
        
        appVersionText = [[UILabel alloc] initWithFrame:CGRectMake(190, 20, 50, 40)];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        appVersionText.text = [NSString stringWithFormat:@"%.2f",[version floatValue]];
        appVersionText.font = DEFAULT_FONT;
        appVersionText.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:appVersionText];
        
        //DBバージョン
        dataVersion = [[UILabel alloc] initWithFrame:CGRectMake(15, 78, 100, 20)];
        dataVersion.text = @"DB Version";
        dataVersion.font = DEFAULT_FONT;
        [self.view addSubview:dataVersion];
        
        dataVersionText = [[UILabel alloc] initWithFrame:CGRectMake(190, 70, 50, 40)];
        dataVersionText.text = [NSString stringWithFormat:@"%.2f",[USER_DEFAULT floatForKey:DATABSEVERSION_KEY]];
        dataVersionText.font = DEFAULT_FONT;
        dataVersionText.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:dataVersionText];
        
        //ソーティング
        defaultSort = [[UILabel alloc] initWithFrame:CGRectMake(15, 148, 100, 20)];
        defaultSort.text = @"Default Sort";
        defaultSort.font = DEFAULT_FONT;
        
        defaultSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 140, 190, 40)];
        defaultSortLabel.text = @"NAME";
        defaultSortLabel.font = DEFAULT_FONT;
        defaultSortLabel.textAlignment = NSTextAlignmentRight;
        defaultSortLabel.backgroundColor = [UIColor clearColor];
        
        defaultSortButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        defaultSortButton.tag = 0;
        defaultSortButton.frame = CGRectMake(125, 140, 190, 40);
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
        custom_SP.tag = 1;
        custom_SP.frame = CGRectMake(125, 200, 190, 40);
        [custom_SP addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:custom_SP];
        [self.view addSubview:customLabelSP];
        
        //DP
        customLabelDP = [[UILabel alloc] initWithFrame:CGRectMake(115, 250, 190, 40)];
        customLabelDP.text = @"DP";
        customLabelDP.font = DEFAULT_FONT;
        customLabelDP.textAlignment = NSTextAlignmentRight;
        customLabelDP.backgroundColor = [UIColor clearColor];
        
        custom_DP = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        custom_DP.tag = 2;
        custom_DP.frame = CGRectMake(125, 250, 190, 40);
        [custom_DP addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:custom_DP];
        [self.view addSubview:customLabelDP];
        
        
        //テーブル
        self.tablelView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height)];
        self.tablelView.delegate = self;
        self.tablelView.dataSource = self;
        self.tablelView.alpha = 0.0;
        self.tablelView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.tablelView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
        self.tablelView.frame = CGRectMake((self.view.bounds.size.width / 2) -40, 0, (self.view.bounds.size.width / 2) + 40, self.view.bounds.size.height);
        [self setAlpha:YES tag:b.tag];
    }];
}

- (void)cancel:(UIButton *)b{
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.tablelView.frame = CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 40, self.view.bounds.size.height);
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
        cancelButton.alpha = 1.0;
        if (tag != 0) {
            defaultSort.alpha = 0.2;
        }
        if (tag != 1 && tag != 2) {
            custom.alpha = 0.2;
        }
    }
    else{
        self.tablelView.alpha = 0.0;
        cancelButton.alpha = 0.0;
        
        defaultSort.alpha = 1.0;
        custom.alpha = 1.0;
    }
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.tablelView.frame = CGRectMake(self.view.bounds.size.width, 0, (self.view.bounds.size.width / 2) + 30, self.view.bounds.size.height);
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
