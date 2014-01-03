//
//  CustomSettingPageView.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "CustomSettingPageView.h"
#import "TableSources.h"

@implementation CustomSettingPageView
@synthesize tableList = tableList_;
@synthesize clearList = clearList_;
@synthesize levelList = levelList_;
@synthesize versionList = versionList_;
@synthesize sortingList = sortingList_;
@synthesize playRankList = playRankList_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableList = [[NSArray alloc] init];
        TableSources *tableSources = [[TableSources alloc] init];
        self.clearList = tableSources.clearSortList;
        self.levelList = tableSources.levelSortList;
        self.versionList = tableSources.versionSortList;
        self.sortingList = tableSources.sortSetting;
        
        self.playRankList = [[NSArray alloc] initWithObjects:@"NORMAL",@"HYPER",@"ANOTHER",@"A+H",@"ALL", nil];
        
        //キャンセルボタン
//        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        cancelButton.frame = CGRectMake(15, 340, 100, 40);
//        [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
//        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        cancelButton.titleLabel.font = DEFAULT_FONT;
//        cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//        cancelButton.alpha = 0.0;
//        
//        [cancelButton addTarget:self action:NSSelectorFromString(@"cancel:") forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:cancelButton];

        //アクティブ
        active = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, 100, 20)];
        active.text = @"Active";
        active.font = DEFAULT_FONT;
        active.backgroundColor = [UIColor clearColor];
        
        activeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(185, 15, 70, 40)];
//        activeSwitch.on = NO;
        [activeSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:active];
        [self addSubview:activeSwitch];

        //タイトル
        title = [[UILabel alloc] initWithFrame:CGRectMake(15, 58, 100, 20)];
        title.text = @"Title";
        title.font = DEFAULT_FONT;
        title.backgroundColor = [UIColor clearColor];
        
        titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 50, 190, 40)];
        titleTextField.delegate = self;
        titleTextField.borderStyle = UITextBorderStyleRoundedRect;
        titleTextField.returnKeyType = UIReturnKeyDone;
        titleTextField.placeholder = @"タイトルを入力してください";
        titleTextField.font = DEFAULT_FONT_TEXTFILED;
        titleTextField.textAlignment = NSTextAlignmentRight;
        titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:title];
        [self addSubview:titleTextField];
        
        //バージョン
        version = [[UILabel alloc] initWithFrame:CGRectMake(15, 108, 100, 20)];
        version.text = @"Version";
        version.font = DEFAULT_FONT;
        version.backgroundColor = [UIColor clearColor];
        
        versionSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 100, 190, 40)];
//        versionSortLabel.text = @"20 tricoro";
        versionSortLabel.font = DEFAULT_FONT;
        versionSortLabel.textAlignment = NSTextAlignmentRight;
        versionSortLabel.backgroundColor = [UIColor clearColor];
        
        versionSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        versionSelect.tag = 0;
        versionSelect.frame = CGRectMake(125, 100, 190, 40);
        [versionSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:versionSelect];
        [self addSubview:versionSortLabel];
        [self addSubview:version];
        
        //難易度
        level = [[UILabel alloc] initWithFrame:CGRectMake(15, 158, 100, 20)];
        level.text = @"Difficulity";
        level.font = DEFAULT_FONT;
        level.backgroundColor = [UIColor clearColor];
        
        levelSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 150, 190, 40)];
//        levelSortLabel.text = @"ALL";
        levelSortLabel.font = DEFAULT_FONT;
        levelSortLabel.textAlignment = NSTextAlignmentRight;
        levelSortLabel.backgroundColor = [UIColor clearColor];
        
        levelSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        levelSelect.tag = 1;
        levelSelect.frame = CGRectMake(125, 150, 190, 40);
        [levelSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:levelSelect];
        [self addSubview:levelSortLabel];
        [self addSubview:level];
        
        //クリアランプ
        clear = [[UILabel alloc] initWithFrame:CGRectMake(15, 208, 100, 20)];
        clear.text = @"Clear Lamp";
        clear.font = DEFAULT_FONT;
        clear.backgroundColor = [UIColor clearColor];
        
        clearSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 200, 190, 40)];
//        clearSortLabel.text = @"ALL";
        clearSortLabel.font = DEFAULT_FONT;
        clearSortLabel.textAlignment = NSTextAlignmentRight;
        clearSortLabel.backgroundColor = [UIColor clearColor];
        
        clearSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        clearSelect.tag = 2;
        clearSelect.frame = CGRectMake(125, 200, 190, 40);
        [clearSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearSelect];
        [self addSubview:clearSortLabel];
        [self addSubview:clear];

        
        //プレイランク
        playRank = [[UILabel alloc] initWithFrame:CGRectMake(15, 258, 100, 20)];
        playRank.text = @"N/H/A";
        playRank.font = DEFAULT_FONT;
        
        playRankSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 250, 190, 40)];
//        playRankSortLabel.text = @"ANOTHER";
        playRankSortLabel.font = DEFAULT_FONT;
        playRankSortLabel.textAlignment = NSTextAlignmentRight;
        playRankSortLabel.backgroundColor = [UIColor clearColor];
        
        playRankSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        playRankSelect.tag = 4;
        playRankSelect.frame = CGRectMake(125, 250, 190, 40);
        [playRankSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playRankSelect];
        [self addSubview:playRankSortLabel];
        [self addSubview:playRank];
        
        //ソートタイプ
        sorting = [[UILabel alloc] initWithFrame:CGRectMake(15, 308, 100, 20)];
        sorting.text = @"Sort Type";
        sorting.font = DEFAULT_FONT;
        
        sortingSortLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 300, 190, 40)];
//        sortingSortLabel.text = @"Difficulity (ASC)";
        sortingSortLabel.font = DEFAULT_FONT;
        sortingSortLabel.textAlignment = NSTextAlignmentRight;
        sortingSortLabel.backgroundColor = [UIColor clearColor];
        
        sortingSelect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sortingSelect.tag = 5;
        sortingSelect.frame = CGRectMake(125, 300, 190, 40);
        [sortingSelect addTarget:self action:NSSelectorFromString(@"selectSort:") forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sortingSelect];
        [self addSubview:sortingSortLabel];
        [self addSubview:sorting];
        

        float positionX = (self.bounds.size.width / 2) - 40;
        pageSizeX = (self.bounds.size.width / 2) + 40;
        
        pageView = [[UIScrollView alloc] init];
        pageView.frame = CGRectMake(positionX, 0, pageSizeX, self.bounds.size.height);
        pageView.contentSize = CGSizeMake(pageSizeX * 2, self.bounds.size.height);
        pageView.delegate = self;
        pageView.pagingEnabled = YES;
        pageView.bounces = NO;
        pageView.showsHorizontalScrollIndicator = NO;
        pageView.alpha = 0.0;
        pageView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:pageView];
        
        
        //テーブル
        self.tablelView = [[UITableView alloc] initWithFrame:CGRectMake(pageSizeX, 0, (self.bounds.size.width / 2) + 40, self.bounds.size.height)];
        self.tablelView.delegate = self;
        self.tablelView.dataSource = self;
        self.tablelView.alpha = 1.0;
        self.tablelView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
        [pageView addSubview:self.tablelView];
    }
    return self;
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
    
    active.alpha = alpha;
    title.alpha = alpha;
    if (selectedType != 0) {
        version.alpha = alpha;
    }
    if (selectedType != 1) {
        level.alpha = alpha;
    }
    if (selectedType != 2) {
        clear.alpha = alpha;
    }
    if (selectedType != 4) {
        playRank.alpha = alpha;
    }
    if (selectedType != 5) {
        sorting.alpha = alpha;
    }

}





- (void)setTextWithPage:(int)page style:(int)style{
    
    NSString *playStyle = @"";
    if (style == 0) {
        playStyle = @"sp";
    }
    else{
        playStyle = @"dp";
    }
    NSString *key = [NSString stringWithFormat:@"custom_%@%d",playStyle,page];
    NSDictionary *dic = [USER_DEFAULT objectForKey:key];
    currentCustomKey = key;
    
    if ([[dic objectForKey:@"active"] isEqualToString:@"0"]) {
        activeSwitch.on = NO;
    }
    else{
        activeSwitch.on = YES;
    }
    
    titleTextField.text = [dic objectForKey:@"title"];
    versionSortLabel.text = [self.versionList objectAtIndex:[[dic objectForKey:@"version"] intValue]];
    levelSortLabel.text = [self.levelList objectAtIndex:[[dic objectForKey:@"difficulity"] intValue]];
    clearSortLabel.text = [self.clearList objectAtIndex:[[dic objectForKey:@"clearLamp"] intValue]];
    playRankSortLabel.text = [self.playRankList objectAtIndex:[[dic objectForKey:@"playRank"] intValue]];
    sortingSortLabel.text = [self.sortingList objectAtIndex:[[dic objectForKey:@"sortType"] intValue]];
}






- (void)switchValueChanged:(UISwitch *)s{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULT objectForKey:currentCustomKey]];
    if (s.isOn) {
        [dic setObject:@"1" forKey:@"active"];
    }
    else{
        [dic setObject:@"0" forKey:@"active"];
    }
    [USER_DEFAULT setObject:dic forKey:currentCustomKey];
    [USER_DEFAULT synchronize];
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [self saveText:textField.text];
    [titleTextField resignFirstResponder];
    return YES;
}

- (void)saveText:(NSString *)text{
    NSLog(@"title %@",text);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULT objectForKey:currentCustomKey]];
    [dic setObject:text forKey:@"title"];
    [USER_DEFAULT setObject:dic forKey:currentCustomKey];
    [USER_DEFAULT synchronize];
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
        case 4:
            self.tableList = self.playRankList;
            break;
        case 5:
            self.tableList = self.sortingList;
            break;
        default:
            break;
    }
    [self.tablelView reloadData];
    [UIView animateWithDuration:0.5f animations:^(void) {
//        self.tablelView.frame = CGRectMake((self.bounds.size.width / 2) -40, 0, (self.bounds.size.width / 2) + 40, self.bounds.size.height);
        pageView.contentOffset = CGPointMake(pageSizeX, 0);
        pageView.alpha = 1.0;
        [titleTextField resignFirstResponder];
        [self setAlpha:YES tag:b.tag];
    }];
}

- (void)cancel:(UIButton *)b{
    [UIView animateWithDuration:0.5f animations:^(void) {
//        self.tablelView.frame = CGRectMake(self.bounds.size.width, 0, (self.bounds.size.width / 2) + 40, self.bounds.size.height);
        pageView.contentOffset = CGPointMake(0, 0);
        pageView.alpha = 0.0;
        [self setAlpha:NO tag:0];
    }];
}

- (void)hideTable{
    [UIView animateWithDuration:0.5f animations:^(void) {
        [self saveText:titleTextField.text];
        [titleTextField resignFirstResponder];
        [self setAlpha:NO tag:0];
    }completion:^(BOOL finished){
//        self.tablelView.frame = CGRectMake(self.bounds.size.width, 0, (self.bounds.size.width / 2) + 40, self.bounds.size.height);
        pageView.contentOffset = CGPointMake(0, 0);
        pageView.alpha = 0.0;
    }];
}

- (void)setAlpha:(BOOL)isSelecting tag:(int)tag{
    if (isSelecting) {
        self.tablelView.alpha = 1.0;
//        cancelButton.alpha = 1.0;
        active.alpha = 0.2;
        title.alpha = 0.2;
        if (tag != 0) {
            version.alpha = 0.2;
        }
        if (tag != 1) {
            level.alpha = 0.2;
        }
        if (tag != 2) {
            clear.alpha = 0.2;
        }
        if (tag != 4) {
            playRank.alpha = 0.2;
        }
        if (tag != 5) {
            sorting.alpha = 0.2;
        }
    }
    else{
        self.tablelView.alpha = 0.0;
//        cancelButton.alpha = 0.0;
        
        active.alpha = 1.0;
        title.alpha = 1.0;
        version.alpha = 1.0;
        level.alpha = 1.0;
        clear.alpha = 1.0;
        playRank.alpha = 1.0;
        sorting.alpha = 1.0;
    }
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

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULT objectForKey:currentCustomKey]];
    [UIView animateWithDuration:0.5f animations:^(void) {
//        self.tablelView.frame = CGRectMake(self.bounds.size.width, 0, (self.bounds.size.width / 2) + 30, self.bounds.size.height);
        pageView.contentOffset = CGPointMake(0, 0);
        pageView.alpha = 0.0;
        [self setAlpha:NO tag:0];
        switch (selectedType) {
            case 0:
                versionSortLabel.text = [self.versionList objectAtIndex:indexPath.row];
                [dic setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"version"];
                break;
            case 1:
                levelSortLabel.text = [self.levelList objectAtIndex:indexPath.row];
                [dic setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"difficulity"];
                break;
            case 2:
                clearSortLabel.text = [self.clearList objectAtIndex:indexPath.row];
                [dic setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"clearLamp"];
                break;
            case 4:
                playRankSortLabel.text = [self.playRankList objectAtIndex:indexPath.row];
                [dic setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"playRank"];
                break;
            case 5:
                sortingSortLabel.text = [self.sortingList objectAtIndex:indexPath.row];
                [dic setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"sortType"];
                break;
            default:
                break;
        }
        [USER_DEFAULT setObject:dic forKey:currentCustomKey];
        [USER_DEFAULT synchronize];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
