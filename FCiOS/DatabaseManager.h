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
- (BOOL)updateDatabase:(NSDictionary *)dictionary;
- (void)setDatabaseVersion:(float)version;
+ (BOOL)updateDatabase;

- (void)customSortSelecter:(int)style;

+ (NSString *)SQLVersionString:(int)type;
+ (NSString *)SQLLevelString:(int)type;
+ (NSString *)SQLPlayStyleString:(int)type;
+ (NSString *)SQLPlayRankString:(int)type;
+ (NSString *)SQLClearLampString:(int)type;
+ (NSString *)SQLSortTypeString:(int)type;

@end
