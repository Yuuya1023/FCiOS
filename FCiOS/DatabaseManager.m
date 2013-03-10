//
//  DatabaseManager.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/10.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "DatabaseManager.h"
#import "SBJson.h"

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



+ (BOOL)updateDatabase{
    NSURL *url = [NSURL URLWithString:UPDATE_JSON_PATH];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error
                    ];
    
    // error
    if (error != nil) {
        [Utilities showDefaultAlertWithTitle:@"更新情報の取得に失敗しました" message:@"お手数ですが時間をおいて再度お試しください。"];
        return NO;
    }
    
    //SBJson
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [jsonString JSONValue];
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    //リストが取れなかったとき
    if ([jsonArray count] < 1) {
        [Utilities showDefaultAlertWithTitle:@"更新情報の取得に失敗しました" message:@"お手数ですが時間をおいて再度お試しください。"];
        return NO;
    }
    
    NSMutableString *updateDescription = [[NSMutableString alloc] init];
    int updateCount = 0;
    for(NSDictionary *key in jsonArray){
//          NSLog(@"key = %@",key);
        
        //現在のバージョンより上だったらアップデート
//            NSLog(@"now version %f",[USER_DEFAULT floatForKey:DATABSEVERSION_KEY]);
        if ([[key objectForKey:@"version"] floatValue] > [USER_DEFAULT floatForKey:DATABSEVERSION_KEY]) {
//              NSLog(@"version %@",[key objectForKey:@"version"]);
//              NSLog(@"description %@",[key objectForKey:@"description"]);
            
            //sqlのdictionaryを渡し、アップデート
            if([dbManager updateDatabase:[key objectForKey:@"sql"]]){
                //成功
                updateCount++;
                [updateDescription appendFormat:@"version:%@\n",[key objectForKey:@"version"]];
                [updateDescription appendFormat:@"%@\n\n",[key objectForKey:@"description"]];
                [USER_DEFAULT setObject:[key objectForKey:@"version"] forKey:DATABSEVERSION_KEY];
                [USER_DEFAULT synchronize];
            }
            else{
                //失敗
                NSLog(@"update returned");
                if (updateCount > 0) {
                    [Utilities showDefaultAlertWithTitle:@"一部更新に失敗しました"
                                                 message:[NSString stringWithFormat:@"%@version:%@以降のデータの取得に失敗しました。お手数ですが時間をおいて再度お試しください。",updateDescription,[USER_DEFAULT objectForKey:DATABSEVERSION_KEY]]];
                    return YES;
                }
                else{
                    [Utilities showDefaultAlertWithTitle:@"更新失敗" message:@"お手数ですが時間をおいて再度お試しください。"];
                    return NO;
                }
            }
        }
        NSLog(@"update verion:%@",[key objectForKey:@"version"]);
    }
    if (updateCount == 0) {
        [Utilities showDefaultAlertWithTitle:@"" message:@"すでに最新バージョンです"];
    }
    else{
        [Utilities showDefaultAlertWithTitle:@"更新成功" message:[NSString stringWithFormat:@"%@",updateDescription]];
        return YES;
    }
    return NO;
}

- (void)setDatabaseVersion:(float)version{
    [USER_DEFAULT setFloat:version forKey:DATABSEVERSION_KEY];
    [USER_DEFAULT synchronize];
}






- (void)customSortSelecter:(int)style{
    if ([self.music_DB open]) {
        
        NSString *key;
        if (style == 0) {
            key = @"custom_sp";
        }
        else{
            key = @"custom_dp";
        }
        
        NSString *playStyleSql = [self SQLPlayStyleString:style];
        
        
        for (int i = 1; i <= 5; i++) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULT objectForKey:[NSString stringWithFormat:@"%@%d",key,i]]];
            if ([[dic objectForKey:@"active"] isEqualToString:@"0"]) {
                NSLog(@"custom%d not active.",i);
            }
            else{
                NSString *versionSql = [self SQLVersionString:[[dic objectForKey:@"version"] intValue]];
                NSString *playRankSql = [self SQLPlayRankString:[[dic objectForKey:@"playRank"] intValue]];
                NSString *clearLampSql = [self SQLClearLampString:[[dic objectForKey:@"clearLamp"] intValue]];
                NSString *levelSql = [self SQLLevelString:[[dic objectForKey:@"difficulity"] intValue]];
            
                NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(music_id) FROM ( SELECT tblResults.* FROM("];
                if ([playRankSql isEqualToString:@"UNION_ALL"]) {
                    [sql appendFormat:@"SELECT music_id FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version%@ AND %@_Normal_Level%@ AND %@_Normal_Status%@",
                     versionSql,
                     playStyleSql,
                     levelSql,
                     playStyleSql,
                     clearLampSql];
                
                    [sql appendFormat:@" UNION ALL "];
                    [sql appendFormat:@"SELECT music_id FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version%@ AND %@_Hyper_Level%@ AND %@_Hyper_Status%@",
                     versionSql,
                     playStyleSql,
                     levelSql,
                     playStyleSql,
                     clearLampSql];
                
                    [sql appendFormat:@" UNION ALL "];
                    [sql appendFormat:@"SELECT music_id FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version%@ AND %@_Another_Level%@ AND %@_Another_Status%@",
                     versionSql,
                     playStyleSql,
                     levelSql,
                     playStyleSql,
                     clearLampSql];
                }
                else{
                    [sql appendFormat:@"SELECT music_id FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND version%@ AND %@_%@_Level%@ AND %@_%@_Status%@",
                     versionSql,
                     playStyleSql,
                     playRankSql,
                     levelSql,
                     playStyleSql,
                     playRankSql,
                     clearLampSql];
                }
                [sql appendFormat:@") AS tblResults)"];
                NSLog(@"\n%@",sql);
            
                FMResultSet *rs_lamp = [self.music_DB executeQuery:sql];
                while ([rs_lamp next]) {
                    int count =  [rs_lamp intForColumn:@"count(music_id)"];
                    NSLog(@"result%d %d",i,count);
                
                    [dic setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
                    [USER_DEFAULT setObject:dic forKey:[NSString stringWithFormat:@"%@%d",key,i]];
                    [USER_DEFAULT synchronize];
                }
            }
        }
        
    }
    else{
        NSLog(@"Could not open db.");
    }
}













- (NSString *)SQLVersionString:(int)type{
    NSString *sql;
    if (type == 0) {
        sql = @"< 21";
    }
    else{
        sql = [NSString stringWithFormat:@" = %d",type];
    }
    return sql;
}

- (NSString *)SQLLevelString:(int)type{
    NSString *sql;
    if (type == 0) {
        sql = @"< 13";
    }
    else{
        sql = [NSString stringWithFormat:@" = %d",type];
    }
    
    return sql;
}

- (NSString *)SQLPlayStyleString:(int)type{
    NSString *sql;
    if (type == 0) {
        sql = [NSString stringWithFormat:@"SP"];
    }
    else{
        sql = [NSString stringWithFormat:@"DP"];
    }
    return sql;
}

- (NSString *)SQLPlayRankString:(int)type{
    NSString *sql;
    switch (type) {
        case 0:
            sql = [NSString stringWithFormat:@"Normal"];
            break;
        case 1:
            sql = [NSString stringWithFormat:@"Hyper"];
            break;
        case 2:
            sql = [NSString stringWithFormat:@"Another"];
            break;
        default:
            sql = @"UNION_ALL";
            break;
    }
    return sql;
}

- (NSString *)SQLClearLampString:(int)type{
    NSString *sql;
    switch (type) {
        case 1:
            sql = @" = 7";
            break;
        case 2:
            sql = @" = 6";
            break;
        case 3:
            sql = @" = 5";
            break;
        case 4:
            sql = @" = 4";
            break;
        case 5:
            sql = @" = 3";
            break;
        case 6:
            sql = @" = 2";
            break;
        case 7:
            sql = @" = 1";
            break;
        case 8:
            sql = @" = 0";
            break;
        case 9:
            sql = @" < 7";
            break;
        case 10:
            sql = @" < 6";
            break;
        case 11:
            sql = @" < 5";
            break;
        case 12:
            sql = @" < 4";
            break;
        case 13:
            sql = @" < 3";
            break;
        default:
            sql = @" < 999";
            break;
    }
    return sql;
}

- (NSString *)SQLSortTypeString:(int)type{
    NSString *sql;
    switch (type) {
        case 0:
            sql = @") AS tblResults ORDER BY tblResults.level ASC,LOWER(tblResults.name) ASC";
            break;
        case 1:
            sql = @") AS tblResults ORDER BY tblResults.level DESC,LOWER(tblResults.name) ASC";
            break;
        case 2:
            sql = @") AS tblResults ORDER BY tblResults.status ASC,tblResults.level ASC,LOWER(tblResults.name) ASC";
            break;
        case 3:
            sql = @") AS tblResults ORDER BY tblResults.status DESC,tblResults.level ASC,LOWER(tblResults.name) ASC";
            break;
        default:
            break;
    }
    return sql;
}


@end
