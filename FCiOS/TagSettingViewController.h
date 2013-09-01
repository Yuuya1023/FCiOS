//
//  TagSettingViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/09/01.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EDIT_TYPE_EDIT = 0,
    EDIT_TYPE_ADD
}EDIT_TYPE;

typedef enum {
    EDIT_TARGET_SP = 0,
    EDIT_TARGET_DP
}EDIT_TARGET;

@interface TagSettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>{
    
    UITableView *tableView_;
    NSMutableDictionary *spTagList_;
    NSMutableDictionary *dpTagList_;
    
    int spTagListLastKey_;
    int dpTagListLastKey_;
    
    int spRowCount_;
    int dpRowCount_;
    
    UIView *grayView_;
    UITextField *tagNameField_;
    
    UILabel *tagName_;
    
    UIButton *cancelButton_;
    UIButton *deleteButton_;
    UIButton *okButton_;
    
    int editingIndex_;

}

@property (nonatomic ,retain) UITableView *tableView;
@property (nonatomic ,retain) NSMutableDictionary *spTagList;
@property (nonatomic ,retain) NSMutableDictionary *dpTagList;

@end
