//
//  DetailViewController.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController{
    int versionSortType_;
    int levelSortType_;
    int playStyleSortType_;
    int playRankSortType_;
    int sortingType_;
}

@property (nonatomic, assign) int versionSortType;
@property (nonatomic, assign) int levelSortType;
@property (nonatomic, assign) int playStyleSortType;
@property (nonatomic, assign) int playRankSortType;
@property (nonatomic, assign) int sortingType;

@end
