//
//  DatabaseManager.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/10.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

@interface DatabaseManager : NSObject{
    FMDatabase* music_DB_;
}

@property (nonatomic ,retain) FMDatabase *music_DB;

+ (DatabaseManager *)sharedInstance;

@end
