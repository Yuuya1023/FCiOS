//
//  DatabaseManager.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/10.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "DatabaseManager.h"

#define XXSerialQueueName "databaseManager.SerialQueue"

static DatabaseManager *sharedManager;
static dispatch_queue_t serialQueue;

@implementation DatabaseManager
@synthesize music_DB = music_DB_;

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create(XXSerialQueueName, NULL);
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
        }
    });
    return sharedManager;
}

+ (DatabaseManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DatabaseManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    id __block obj;
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            // configure instance here
            self.music_DB = [self dbConnect:@"musicMaster"];
        }
    });
    self = obj;
    return self;
}


-(id) dbConnect:(NSString *)dbName{
    BOOL success;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
    NSLog(@"%@",writableDBPath);
    success = [fm fileExistsAtPath:writableDBPath];
    if(!success){
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
        success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if(!success){
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    return db;
}


- (BOOL)updateDatabase:(NSDictionary *)dictionary{
//    NSLog(@"dic %@",dictionary);
    BOOL isSuccess = NO;
    if ([self.music_DB open]) {
        [self.music_DB beginTransaction];
        
        for (NSDictionary *key_sql in dictionary) {
//            NSLog(@"music ,%@",[key_sql objectForKey:@"music"]);
//            NSLog(@"user  ,%@",[key_sql objectForKey:@"user"]);
            NSString *music_id = [key_sql objectForKey:@"music_id"];
            NSString *masterSql = [key_sql objectForKey:@"music"];
            NSString *userSql = [NSString stringWithFormat:@"INSERT INTO userData (music_id) values (%@)",music_id];
            //更新処理
            [self.music_DB executeUpdate:masterSql ,music_id];
            [self.music_DB executeUpdate:userSql];
            
            
            //データが入っているか確認し入っていなかったらロールバックを行う
            NSString *confirmSql = [NSString stringWithFormat:@"SELECT count(music_id) FROM musicMaster WHERE music_id = %@",music_id];
            FMResultSet *rs_confirm = [self.music_DB executeQuery:confirmSql];
            while ([rs_confirm next]) {
                if ([rs_confirm intForColumn:@"count(music_id)"] == 0) {
                    [self.music_DB rollback];
                    return NO;
                }
            }
            
            NSString *confirmSql2 = [NSString stringWithFormat:@"SELECT count(music_id) FROM userData WHERE music_id = %@",music_id];
            FMResultSet *rs_confirm2 = [self.music_DB executeQuery:confirmSql2];
            while ([rs_confirm2 next]) {
                if ([rs_confirm2 intForColumn:@"count(music_id)"] == 0) {
                    [self.music_DB rollback];
                    return NO;
                }
            }
        }
        
        if ([self.music_DB hadError]) {
            [self.music_DB rollback];
            NSLog(@"update error");
        }
        else{
            [self.music_DB commit];
            NSLog(@"commit update");
            isSuccess = YES;
        }
        [self.music_DB close];
    }
    else{
        NSLog(@"Could not open db.");
    }
    return  isSuccess;
}

- (void)setDatabaseVersion:(float)version{
    [USER_DEFAULT setFloat:version forKey:DATABSEVERSION_KEY];
    [USER_DEFAULT synchronize];
}

@end
