//
//  MainViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSources.h"

@interface MainViewController : UITableViewController{
    
    NSArray *clearList_;
    NSArray *levelList_;
    NSArray *versionList_;
}

@property (nonatomic ,retain)NSArray *clearList;
@property (nonatomic ,retain)NSArray *levelList;
@property (nonatomic ,retain)NSArray *versionList;

@end
