//
//  TableSources.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableSources : NSObject{
    
    NSArray *clearList_;
    NSArray *levelList_;
    NSArray *versionList_;
    
    NSArray *sortingList_;
}

@property (nonatomic ,retain)NSArray *clearList;
@property (nonatomic ,retain)NSArray *levelList;
@property (nonatomic ,retain)NSArray *versionList;

@property (nonatomic ,retain)NSArray *sortingList;

@end