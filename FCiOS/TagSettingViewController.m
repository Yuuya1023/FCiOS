//
//  TagSettingViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/09/01.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "TagSettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DatabaseManager.h"

@interface TagSettingViewController ()

@end

@implementation TagSettingViewController
@synthesize tableView = tableView_;
@synthesize spTagList = spTagList_;
@synthesize dpTagList = dpTagList_;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Tag Setting";
        
        // リスト
        spTagList_ = [[USER_DEFAULT objectForKey:SP_TAG_LIST_KEY] mutableCopy];
        if (!spTagList_) {
            spTagList_ = [[NSMutableDictionary alloc] init];
        }
        NSLog(@"%@",spTagList_);
        
        dpTagList_ = [[USER_DEFAULT objectForKey:DP_TAG_LIST_KEY] mutableCopy];
        if (!dpTagList_) {
            dpTagList_ = [[NSMutableDictionary alloc] init];
        }
        NSLog(@"%@",dpTagList_);
        
        spTagListLastKey_ = [USER_DEFAULT integerForKey:SP_TAG_LIST_LAST_KEY];
        dpTagListLastKey_ = [USER_DEFAULT integerForKey:DP_TAG_LIST_LAST_KEY];
        
        NSLog(@"%d",spTagListLastKey_);
        
        
        // テーブル
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 72) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.view addSubview:self.tableView];
        
        //更新ボタン
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"削除"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:NSSelectorFromString(@"delete:")];
        self.navigationItem.rightBarButtonItem = button;
        
        
        
        // 編集画面
        grayView_ = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        grayView_.backgroundColor = [UIColor blackColor];
        grayView_.alpha = 0.0;
        
        tagName_ = [[UILabel alloc] init];
        tagName_.frame = CGRectMake(10, 100, 100, 50);
        tagName_.text = @"Tag Name";
        tagName_.font = DEFAULT_FONT;
        tagName_.textColor = [UIColor whiteColor];
        tagName_.backgroundColor = [UIColor clearColor];
        [grayView_ addSubview:tagName_];
        
        tagNameField_ = [[UITextField alloc] initWithFrame:CGRectMake(10, 150, 300, 40)];
        tagNameField_.delegate = self;
        tagNameField_.borderStyle = UITextBorderStyleBezel;
        tagNameField_.font = DEFAULT_FONT;
        tagNameField_.alpha = 0.0;
        tagNameField_.backgroundColor = [UIColor whiteColor];
        tagNameField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tagNameField_.returnKeyType = UIReturnKeyDone;
        [grayView_ addSubview:tagNameField_];
        
        
        // 削除ボタン
//        deleteButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
//        deleteButton_.frame = CGRectMake(140, 100, 170, 40);
//        deleteButton_.titleLabel.font = DEFAULT_FONT;
//        [deleteButton_ setTitle:@"このタグを削除" forState:UIControlStateNormal];
//        [deleteButton_ setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [deleteButton_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//        
//        [[deleteButton_ layer] setBorderWidth:1.0f];
//        [[deleteButton_ layer] setBorderColor:[UIColor whiteColor].CGColor];
//        
//        [grayView_ addSubview:deleteButton_];
        
        // キャンセルボタン
        cancelButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton_.frame = CGRectMake(30, 300, 100, 40);
        cancelButton_.titleLabel.font = DEFAULT_FONT;
        [cancelButton_ setTitle:@"キャンセル" forState:UIControlStateNormal];
        [cancelButton_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [[cancelButton_ layer] setBorderWidth:1.0f];
        [[cancelButton_ layer] setBorderColor:[UIColor whiteColor].CGColor];
        [cancelButton_ addTarget:self action:NSSelectorFromString(@"cancel:") forControlEvents:UIControlEventTouchUpInside];
        
        [grayView_ addSubview:cancelButton_];
        
        // OKボタン
        okButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        okButton_.frame = CGRectMake(190, 300, 100, 40);
        okButton_.titleLabel.font = DEFAULT_FONT;
        [okButton_ setTitle:@"OK" forState:UIControlStateNormal];
        [okButton_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [[okButton_ layer] setBorderWidth:1.0f];
        [[okButton_ layer] setBorderColor:[UIColor whiteColor].CGColor];
        
        [grayView_ addSubview:okButton_];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}



- (BOOL)isAddCellWithSection:(NSInteger)section row:(NSInteger)row{
    
    int rowCount = -1;
    switch (section) {
        case 0:
            rowCount = spRowCount_ - 1;
            break;
        case 1:
            rowCount = dpRowCount_ - 1;
            break;
            
        default:
            break;
    }
    if (rowCount == row) {
        return YES;
    }

    return NO;
}



#pragma mark - Table view delegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return @"SP";
            break;
        case 1:
            return @"DP";
            break;
            
        default:
            break;
    }
    return @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int count = 1;
    switch (section) {
        case 0:
            if (tableView.editing) {
                count = [spTagList_ count];
            }
            else{
                count = [spTagList_ count] + 1;
            }
            spRowCount_ = count;
            break;
        case 1:
            if (tableView.editing) {
                count = [dpTagList_ count];
            }
            else{
                count = [dpTagList_ count] + 1;
            }
            dpRowCount_ = count;
            break;
            
        default:
            break;
    }
    
    return count;
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
    
    NSArray *values;
    int row = -1;
    switch (indexPath.section) {
        case 0:
            row = spRowCount_ - 1;
            values = [spTagList_ allValues];
            break;
        case 1:
            row = dpRowCount_ - 1;
            values = [dpTagList_ allValues];
            break;
            
        default:
            break;
    }
    if ([self isAddCellWithSection:indexPath.section row:indexPath.row] && !self.tableView.editing) {
        cell.textLabel.text = @"+ タグを追加";
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    else{
        cell.textLabel.text = [values objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
//    NSLog(@"%@ \n%@ \n %@",[spTagList_ allKeys],values,spTagList_);
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
    
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([self isAddCellWithSection:indexPath.section row:indexPath.row]) {
        NSLog(@"追加");
        [self showEditPopup:EDIT_TYPE_ADD target:indexPath.section];
    }
    else{
        NSLog(@"編集");
        // テキストフィールドに初期値をセット
        NSArray *keys;
        NSArray *values;
        switch (indexPath.section) {
            case EDIT_TARGET_SP:
                keys = [spTagList_ allKeys];
                values = [spTagList_ allValues];
                break;
            case EDIT_TARGET_DP:
                keys = [dpTagList_ allKeys];
                values = [dpTagList_ allValues];
                break;
                
            default:
                break;
        }
        
        editingIndex_ = [[keys objectAtIndex:indexPath.row] integerValue];
        [tagNameField_ setText:[values objectAtIndex:indexPath.row]];
        [self showEditPopup:EDIT_TYPE_EDIT target:indexPath.section];
    }



}



-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath{
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            NSLog(@"delete");
            switch (indexPath.section) {
                case EDIT_TARGET_SP:
                {
                    NSArray *keys = [spTagList_ allKeys];
                    [spTagList_ removeObjectForKey:[NSString stringWithFormat:@"%@",[keys objectAtIndex:indexPath.row]]];
                    [USER_DEFAULT setObject:spTagList_ forKey:SP_TAG_LIST_KEY];
                    [USER_DEFAULT setInteger:spTagListLastKey_ forKey:SP_TAG_LIST_LAST_KEY];
                    [USER_DEFAULT synchronize];
                    NSLog(@"%@",spTagList_);
                    
                    int tagId = [[keys objectAtIndex:indexPath.row] intValue];
                    [[DatabaseManager sharedInstance] removeTag:tagId playStyle:0];
                    [self.tableView reloadData];
                }
                    break;
                case EDIT_TARGET_DP:
                {
                    NSArray *keys = [dpTagList_ allKeys];
                    [dpTagList_ removeObjectForKey:[NSString stringWithFormat:@"%@",[keys objectAtIndex:indexPath.row]]];
                    [USER_DEFAULT setObject:dpTagList_ forKey:DP_TAG_LIST_KEY];
                    [USER_DEFAULT setInteger:dpTagListLastKey_ forKey:DP_TAG_LIST_LAST_KEY];
                    [USER_DEFAULT synchronize];
                    NSLog(@"%@",dpTagList_);
                    
                    int tagId = [[keys objectAtIndex:indexPath.row] intValue];
                    [[DatabaseManager sharedInstance] removeTag:tagId playStyle:1];
                    [self.tableView reloadData];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITextField delegate


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    [tagNameField_ resignFirstResponder];
    return YES;
}

#pragma mark -


- (void)showEditPopup:(int)editType target:(int)target{
    
    [self.navigationController.view addSubview:grayView_];
    
    [okButton_ setTag:target];
    [okButton_ removeTarget:self action:NSSelectorFromString(@"add:") forControlEvents:UIControlEventTouchUpInside];
    [okButton_ removeTarget:self action:NSSelectorFromString(@"ok:") forControlEvents:UIControlEventTouchUpInside];
    switch (editType) {
        case EDIT_TYPE_ADD:
            [okButton_ setTitle:@"ADD" forState:UIControlStateNormal];
            [okButton_ addTarget:self action:NSSelectorFromString(@"add:") forControlEvents:UIControlEventTouchUpInside];
            break;
        case EDIT_TYPE_EDIT:
        {
            [okButton_ setTitle:@"OK" forState:UIControlStateNormal];
            [okButton_ addTarget:self action:NSSelectorFromString(@"ok:") forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:0.3f animations:^(void) {
        grayView_.alpha = 0.9;
        tagNameField_.alpha = 1.0;
        cancelButton_.alpha = 1.0;
        okButton_.alpha = 1.0;
    }];
    
    
}



#pragma mark - UIButton

- (void)delete:(UIBarButtonItem *)b{
    
    [self.tableView setEditing:!self.tableView.editing];
    [self.tableView reloadData];
    
    if (self.tableView.editing) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"完了"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:NSSelectorFromString(@"delete:")];
        self.navigationItem.rightBarButtonItem = button;
    }
    else{
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"削除"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:NSSelectorFromString(@"delete:")];
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (void)cancel:(UIButton *)b{
    
    [self closeEditView];
}

- (void)add:(UIButton *)b{
    NSLog(@"%@",tagNameField_.text);
    if ([tagNameField_.text length] == 0) {
        [Utilities showDefaultAlertWithTitle:@"" message:@"タグ名を入力してください。"];
    }
    else{
        switch (b.tag) {
                // 保存
            case EDIT_TARGET_SP:
                if ([[spTagList_ allValues] containsObject:tagNameField_.text]) {
                    [Utilities showDefaultAlertWithTitle:@"" message:@"同じタグ名が存在します。"];
                    return;
                }
                spTagListLastKey_++;
                [spTagList_ setValue:tagNameField_.text forKey:[NSString stringWithFormat:@"%d",spTagListLastKey_]];
                [USER_DEFAULT setObject:spTagList_ forKey:SP_TAG_LIST_KEY];
                [USER_DEFAULT setInteger:spTagListLastKey_ forKey:SP_TAG_LIST_LAST_KEY];
                [USER_DEFAULT synchronize];
                NSLog(@"%@",spTagList_);
                break;
                
            case EDIT_TARGET_DP:
                if ([[dpTagList_ allValues] containsObject:tagNameField_.text]) {
                    [Utilities showDefaultAlertWithTitle:@"" message:@"同じタグ名が存在します。"];
                    return;
                }
                dpTagListLastKey_++;
                [dpTagList_ setValue:tagNameField_.text forKey:[NSString stringWithFormat:@"%d",dpTagListLastKey_]];
                [USER_DEFAULT setObject:dpTagList_ forKey:DP_TAG_LIST_KEY];
                [USER_DEFAULT setInteger:dpTagListLastKey_ forKey:DP_TAG_LIST_LAST_KEY];
                [USER_DEFAULT synchronize];
                NSLog(@"%@",dpTagList_);
                break;
                
            default:
                break;
        }
        
        
        [self.tableView reloadData];
        [self closeEditView];
    }
}


- (void)ok:(UIButton *)b{
    if ([tagNameField_.text length] == 0) {
        [Utilities showDefaultAlertWithTitle:@"" message:@"タグ名を入力してください。"];
    }
    else{
        switch (b.tag) {
            // 保存
            case EDIT_TARGET_SP:
                if ([[spTagList_ allValues] containsObject:tagNameField_.text]) {
                    [Utilities showDefaultAlertWithTitle:@"" message:@"同じタグ名が存在します。"];
                    return;
                }
                [spTagList_ setValue:tagNameField_.text forKey:[NSString stringWithFormat:@"%d",editingIndex_]];
                [USER_DEFAULT setObject:spTagList_ forKey:SP_TAG_LIST_KEY];
                [USER_DEFAULT setInteger:spTagListLastKey_ forKey:SP_TAG_LIST_LAST_KEY];
                NSLog(@"%@",spTagList_);
                break;
                
            case EDIT_TARGET_DP:
                if ([[dpTagList_ allValues] containsObject:tagNameField_.text]) {
                    [Utilities showDefaultAlertWithTitle:@"" message:@"同じタグ名が存在します。"];
                    return;
                }
                [dpTagList_ setValue:tagNameField_.text forKey:[NSString stringWithFormat:@"%d",editingIndex_]];
                [USER_DEFAULT setObject:dpTagList_ forKey:DP_TAG_LIST_KEY];
                [USER_DEFAULT setInteger:dpTagListLastKey_ forKey:DP_TAG_LIST_LAST_KEY];
                NSLog(@"%@",dpTagList_);
                break;
                
            default:
                break;
        }
        [USER_DEFAULT synchronize];
        
        [self.tableView reloadData];
        [self closeEditView];
    }
}

#pragma mark -

- (void)closeEditView{
    
    [UIView animateWithDuration:0.3f animations:^(void) {
        grayView_.alpha = 0.0;
        tagNameField_.alpha = 0.0;
        cancelButton_.alpha = 0.0;
        okButton_.alpha = 0.0;
    }];
    
    [tagNameField_ setText:@""];
}


#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        DatabaseManager *dbManager = [DatabaseManager sharedInstance];
        [dbManager tagSortSelecter:0];
        [dbManager tagSortSelecter:1];
    }
    [super viewWillDisappear:animated];
}

@end
