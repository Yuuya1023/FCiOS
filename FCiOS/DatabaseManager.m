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
    
#ifdef DEBUG
    NSString *path = [[NSBundle mainBundle] pathForResource:@"update" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
#else
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
        
#endif
    
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
        
        NSString *playStyleSql = [DatabaseManager SQLPlayStyleString:style];
        
        
        for (int i = 1; i <= 5; i++) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULT objectForKey:[NSString stringWithFormat:@"%@%d",key,i]]];
            if ([[dic objectForKey:@"active"] isEqualToString:@"0"]) {
                NSLog(@"custom%d not active.",i);
            }
            else{
                int resultSum = 0;
                int min = -1;
                
                NSString *versionSql = [DatabaseManager SQLVersionString:[[dic objectForKey:@"version"] intValue]];
                NSString *playRankSql = [DatabaseManager SQLPlayRankString:[[dic objectForKey:@"playRank"] intValue]];
                NSString *clearLampSql = [DatabaseManager SQLClearLampString:[[dic objectForKey:@"clearLamp"] intValue]];
                NSString *levelSql = [DatabaseManager SQLLevelString:[[dic objectForKey:@"difficulity"] intValue]];
            
                NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT status,count(music_id) FROM ( SELECT tblResults.* FROM("];
                if ([playRankSql isEqualToString:@"UNION_ALL"]) {
                    [sql appendFormat:@"SELECT music_id,%@_Normal_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND %@_Normal_Level != 0 AND version%@ AND %@_Normal_Level%@ AND %@_Normal_Status%@",
                     playStyleSql,
                     playStyleSql,
                     versionSql,
                     playStyleSql,
                     levelSql,
                     playStyleSql,
                     clearLampSql];
                
                    [sql appendFormat:@" UNION ALL "];
                    [sql appendFormat:@"SELECT music_id,%@_Hyper_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND %@_Hyper_Level != 0 AND version%@ AND %@_Hyper_Level%@ AND %@_Hyper_Status%@",
                     playStyleSql,
                     playStyleSql,
                     versionSql,
                     playStyleSql,
                     levelSql,
                     playStyleSql,
                     clearLampSql];
                
                    [sql appendFormat:@" UNION ALL "];
                    [sql appendFormat:@"SELECT music_id,%@_Another_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND %@_Another_Level != 0 AND version%@ AND %@_Another_Level%@ AND %@_Another_Status%@",
                     playStyleSql,
                     playStyleSql,
                     versionSql,
                     playStyleSql,
                     levelSql,
                     playStyleSql,
                     clearLampSql];
                }
                else{
                    [sql appendFormat:@"SELECT music_id,%@_%@_Status AS status FROM musicMaster JOIN userData USING(music_id) WHERE deleteFlg = 0 AND %@_%@_Level != 0 AND version%@ AND %@_%@_Level%@ AND %@_%@_Status%@",
                     playStyleSql,
                     playRankSql,
                     playStyleSql,
                     playRankSql,
                     versionSql,
                     playStyleSql,
                     playRankSql,
                     levelSql,
                     playStyleSql,
                     playRankSql,
                     clearLampSql];
                }
                [sql appendFormat:@") AS tblResults) GROUP BY status"];
                NSLog(@"\n%@",sql);
            
                FMResultSet *rs_lamp = [self.music_DB executeQuery:sql];
                while ([rs_lamp next]) {
                    int status = [rs_lamp intForColumn:@"status"];
                    int count =  [rs_lamp intForColumn:@"count(music_id)"];
                    resultSum += count;
                    
                    if (min == -1 && count > 0) {
                        min = status;
                    }
                }
                NSLog(@"result%d %d",min,resultSum);
                [dic setObject:[NSString stringWithFormat:@"%d",resultSum] forKey:@"count"];
                if (min == -1) {
                    min = 0;
                }
                [dic setObject:[NSString stringWithFormat:@"%d",min] forKey:@"min"];
                [USER_DEFAULT setObject:dic forKey:[NSString stringWithFormat:@"%@%d",key,i]];
                [USER_DEFAULT synchronize];
            }
        }
        
    }
    else{
        NSLog(@"Could not open db.");
    }
}






//+ (NSMutableString *)createSQLForDetail:(NSString *)playRankSql
//                           playStyleSql:(NSString *)playStyleSql
//                             versionSql:(NSString *)versionSql
//                               levelSql:(NSString *)levelSql
//                             statusSort:(NSString *)statusSort
//                            sortingType:(int)sortingType
//
//{
//    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT tblResults.* FROM("];
//    
//    //N/H/Aすべての結果を表示
//    if ([playRankSql isEqualToString:@"UNION_ALL"]) {
//        [sql appendFormat:@"SELECT music_id,name,version,%@Normal_Level AS level,%@Normal_Status AS status,selectType_Normal AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Normal_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//         playStyleSql,
//         playStyleSql,
//         versionSql,
//         playStyleSql,
//         levelSql,
//         statusSort];
//        
//        [sql appendFormat:@" UNION ALL "];
//        [sql appendFormat:@"SELECT music_id,name,version,%@Hyper_Level AS level,%@Hyper_Status AS status,selectType_Hyper AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@Hyper_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//         playStyleSql,
//         playStyleSql,
//         versionSql,
//         playStyleSql,
//         levelSql,
//         statusSort];
//        
//        [sql appendFormat:@" UNION ALL "];
//        [sql appendFormat:@"SELECT music_id,name,version,%@Another_Level AS level ,%@Another_Status AS status,selectType_Another AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND  %@Another_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//         playStyleSql,
//         playStyleSql,
//         versionSql,
//         playStyleSql,
//         levelSql,
//         statusSort];
//        
//    }
//    else{
//        //プレイランクを指定したとき
//        [sql appendFormat:@"SELECT music_id,name,version,%@%@_Level AS level,%@%@_Status AS status,selectType_%@ AS type FROM musicMaster JOIN userData USING(music_id) WHERE %@ AND %@%@_Level%@ %@ AND deleteFlg = 0 AND level != 0",
//         playStyleSql,
//         playRankSql,
//         playStyleSql,
//         playRankSql,
//         playRankSql,
//         versionSql,
//         playStyleSql,
//         playRankSql,
//         levelSql,
//         statusSort];
//    }    
//    
//    //ソート順
//    switch (sortingType) {
//        case 0:
//            [sql appendFormat:@") AS tblResults ORDER BY tblResults.level ASC,LOWER(tblResults.name) ASC"];
//            break;
//        case 1:
//            [sql appendFormat:@") AS tblResults ORDER BY tblResults.level DESC,LOWER(tblResults.name) ASC"];
//            break;
//        case 2:
//            [sql appendFormat:@") AS tblResults ORDER BY tblResults.status ASC,tblResults.level ASC,LOWER(tblResults.name) ASC"];
//            break;
//        case 3:
//            [sql appendFormat:@") AS tblResults ORDER BY tblResults.status DESC,tblResults.level ASC,LOWER(tblResults.name) ASC"];
//            break;
//        default:
//            break;
//    }
//    
//    return sql;
//}




- (void)addColumnUsersMemo{
    if ([self.music_DB open]) {
        
        NSString *searchSql = @"select memo from userData";
        FMResultSet *rs = [self.music_DB executeQuery:searchSql];
        while ([rs next]) {
            NSLog(@"memo isExist");
            return;
        }

        NSLog(@"update");
        NSString *addSql = @"ALTER TABLE userData ADD COLUMN memo TEXT";
        //更新処理
        [self.music_DB executeUpdate:addSql];
    }
    else{
        NSLog(@"Could not open db.");
    }
}

- (NSString *)getMemoWithMusicId:(NSString *)musicId{
    NSString *memo = @"";
    if ([self.music_DB open]) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT memo FROM userData WHERE music_id = %@",musicId];
        FMResultSet *rs = [self.music_DB executeQuery:sql];
        while ([rs next]) {
            memo = [DatabaseManager decodeString:[rs stringForColumn:@"memo"]];
            NSLog(@"memomo %@",memo);
        }
    }
    
    return memo;
}


- (BOOL)updateMemoWithMusicId:(int)musicId text:(NSString *)text{
    NSLog(@"updateMemoWithMusicId %d, text %@",musicId,text);
    BOOL isSuccess = NO;
    if ([self.music_DB open]) {
        [self.music_DB beginTransaction];
        NSString *sql = [NSString stringWithFormat:@"UPDATE userData SET memo = '%@' WHERE music_id = %d",
                         [DatabaseManager sqlSanitizing:text],
                         musicId];
        [self.music_DB executeUpdate:sql];
        
        
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


    return isSuccess;
}


+ (NSString *)sqlSanitizing:(NSString *)sql{
//    NSString *sqlTmp = sql;
    NSLog(@"before %@",sql);
    NSString *tmp = [sql stringByReplacingOccurrencesOfString:@"\"" withString:@"symbol9999"];
    NSString *tmp2 = [tmp stringByReplacingOccurrencesOfString:@"'" withString:@"symbol9998"];
    NSString *tmp3 = [tmp2 stringByReplacingOccurrencesOfString:@"-" withString:@"symbol9997"];
    NSString *tmp4 = [tmp3 stringByReplacingOccurrencesOfString:@"," withString:@"symbol9996"];
    NSString *tmp5 = [tmp4 stringByReplacingOccurrencesOfString:@"&" withString:@"symbol9995"];
    NSString *tmp6 = [tmp5 stringByReplacingOccurrencesOfString:@"+" withString:@"symbol9994"];
    NSString *tmp7 = [tmp6 stringByReplacingOccurrencesOfString:@"/" withString:@"symbol9993"];
    NSString *tmp8 = [tmp7 stringByReplacingOccurrencesOfString:@":" withString:@"symbol9992"];
    NSString *tmp9 = [tmp8 stringByReplacingOccurrencesOfString:@";" withString:@"symbol9991"];
    NSString *tmp10 = [tmp9 stringByReplacingOccurrencesOfString:@"<" withString:@"symbol9990"];
    NSString *tmp11 = [tmp10 stringByReplacingOccurrencesOfString:@">" withString:@"symbol9989"];
    NSString *tmp12 = [tmp11 stringByReplacingOccurrencesOfString:@"=" withString:@"symbol9988"];
    NSString *tmp13 = [tmp12 stringByReplacingOccurrencesOfString:@"*" withString:@"symbol9987"];
    NSString *tmp14 = [tmp13 stringByReplacingOccurrencesOfString:@"_" withString:@"symbol9986"];
    NSString *tmp15 = [tmp14 stringByReplacingOccurrencesOfString:@"?" withString:@"symbol9985"];
    NSString *tmp16 = [tmp15 stringByReplacingOccurrencesOfString:@"(" withString:@"symbol9984"];
    NSString *tmp17 = [tmp16 stringByReplacingOccurrencesOfString:@")" withString:@"symbol9983"];
    NSString *tmp18 = [tmp17 stringByReplacingOccurrencesOfString:@"!" withString:@"symbol9982"];
    NSString *tmp19 = [tmp18 stringByReplacingOccurrencesOfString:@")" withString:@"symbol9981"];
    NSString *tmp20 = [tmp19 stringByReplacingOccurrencesOfString:@"|" withString:@"symbol9980"];
    NSString *tmp21 = [tmp20 stringByReplacingOccurrencesOfString:@"¥" withString:@"symbol9979"];
    NSString *tmp22 = [tmp21 stringByReplacingOccurrencesOfString:@"@" withString:@"symbol9978"];
    NSString *tmp23 = [tmp22 stringByReplacingOccurrencesOfString:@"." withString:@"symbol9977"];
    NSString *tmp24 = [tmp23 stringByReplacingOccurrencesOfString:@"[" withString:@"symbol9976"];
    NSString *tmp25 = [tmp24 stringByReplacingOccurrencesOfString:@"]" withString:@"symbol9975"];
    NSString *tmp26 = [tmp25 stringByReplacingOccurrencesOfString:@"{" withString:@"symbol9974"];
    NSString *tmp27 = [tmp26 stringByReplacingOccurrencesOfString:@"}" withString:@"symbol9973"];
    NSString *tmp28 = [tmp27 stringByReplacingOccurrencesOfString:@"#" withString:@"symbol9972"];
    NSString *tmp29 = [tmp28 stringByReplacingOccurrencesOfString:@"%" withString:@"symbol9971"];
    NSString *tmp30 = [tmp29 stringByReplacingOccurrencesOfString:@"^" withString:@"symbol9970"];
    NSString *tmp31 = [tmp30 stringByReplacingOccurrencesOfString:@"•" withString:@"symbol9969"];
    NSString *tmp32 = [tmp31 stringByReplacingOccurrencesOfString:@"£" withString:@"symbol9968"];
    NSString *tmp33 = [tmp32 stringByReplacingOccurrencesOfString:@"€" withString:@"symbol9967"];
    NSString *tmp34 = [tmp33 stringByReplacingOccurrencesOfString:@"$" withString:@"symbol9966"];
    NSString *tmp35 = [tmp34 stringByReplacingOccurrencesOfString:@"~" withString:@"symbol9965"];
    NSString *tmp36 = [tmp35 stringByReplacingOccurrencesOfString:@"\\" withString:@"symbol9964"];
    
    NSLog(@"after %@",tmp36);
    return tmp36;
}


+ (NSString *)decodeString:(NSString *)str{
    NSLog(@"before %@",str);
    NSString *tmp = [str stringByReplacingOccurrencesOfString:@"symbol9999" withString:@"\""];
    NSString *tmp2 = [tmp stringByReplacingOccurrencesOfString:@"symbol9998" withString:@"'"];
    NSString *tmp3 = [tmp2 stringByReplacingOccurrencesOfString:@"symbol9997" withString:@"-"];
    NSString *tmp4 = [tmp3 stringByReplacingOccurrencesOfString:@"symbol9996" withString:@","];
    NSString *tmp5 = [tmp4 stringByReplacingOccurrencesOfString:@"symbol9995" withString:@"&"];
    NSString *tmp6 = [tmp5 stringByReplacingOccurrencesOfString:@"symbol9994" withString:@"+"];
    NSString *tmp7 = [tmp6 stringByReplacingOccurrencesOfString:@"symbol9993" withString:@"/"];
    NSString *tmp8 = [tmp7 stringByReplacingOccurrencesOfString:@"symbol9992" withString:@":"];
    NSString *tmp9 = [tmp8 stringByReplacingOccurrencesOfString:@"symbol9991" withString:@";"];
    NSString *tmp10 = [tmp9 stringByReplacingOccurrencesOfString:@"symbol9990" withString:@"<"];
    NSString *tmp11 = [tmp10 stringByReplacingOccurrencesOfString:@"symbol9989" withString:@">"];
    NSString *tmp12 = [tmp11 stringByReplacingOccurrencesOfString:@"symbol9988" withString:@"="];
    NSString *tmp13 = [tmp12 stringByReplacingOccurrencesOfString:@"symbol9987" withString:@"*"];
    NSString *tmp14 = [tmp13 stringByReplacingOccurrencesOfString:@"symbol9986" withString:@"_"];
    NSString *tmp15 = [tmp14 stringByReplacingOccurrencesOfString:@"symbol9985" withString:@"?"];
    NSString *tmp16 = [tmp15 stringByReplacingOccurrencesOfString:@"symbol9984" withString:@"("];
    NSString *tmp17 = [tmp16 stringByReplacingOccurrencesOfString:@"symbol9983" withString:@")"];
    NSString *tmp18 = [tmp17 stringByReplacingOccurrencesOfString:@"symbol9982" withString:@"!"];
    NSString *tmp19 = [tmp18 stringByReplacingOccurrencesOfString:@"symbol9981" withString:@")"];
    NSString *tmp20 = [tmp19 stringByReplacingOccurrencesOfString:@"symbol9980" withString:@"|"];
    NSString *tmp21 = [tmp20 stringByReplacingOccurrencesOfString:@"symbol9979" withString:@"¥"];
    NSString *tmp22 = [tmp21 stringByReplacingOccurrencesOfString:@"symbol9978" withString:@"@"];
    NSString *tmp23 = [tmp22 stringByReplacingOccurrencesOfString:@"symbol9977" withString:@"."];
    NSString *tmp24 = [tmp23 stringByReplacingOccurrencesOfString:@"symbol9976" withString:@"["];
    NSString *tmp25 = [tmp24 stringByReplacingOccurrencesOfString:@"symbol9975" withString:@"]"];
    NSString *tmp26 = [tmp25 stringByReplacingOccurrencesOfString:@"symbol9974" withString:@"{"];
    NSString *tmp27 = [tmp26 stringByReplacingOccurrencesOfString:@"symbol9973" withString:@"}"];
    NSString *tmp28 = [tmp27 stringByReplacingOccurrencesOfString:@"symbol9972" withString:@"#"];
    NSString *tmp29 = [tmp28 stringByReplacingOccurrencesOfString:@"symbol9971" withString:@"%"];
    NSString *tmp30 = [tmp29 stringByReplacingOccurrencesOfString:@"symbol9970" withString:@"^"];
    NSString *tmp31 = [tmp30 stringByReplacingOccurrencesOfString:@"symbol9969" withString:@"•"];
    NSString *tmp32 = [tmp31 stringByReplacingOccurrencesOfString:@"symbol9968" withString:@"£"];
    NSString *tmp33 = [tmp32 stringByReplacingOccurrencesOfString:@"symbol9967" withString:@"€"];
    NSString *tmp34 = [tmp33 stringByReplacingOccurrencesOfString:@"symbol9966" withString:@"$"];
    NSString *tmp35 = [tmp34 stringByReplacingOccurrencesOfString:@"symbol9965" withString:@"~"];
    NSString *tmp36 = [tmp35 stringByReplacingOccurrencesOfString:@"symbol9964" withString:@"\\"];
    
    NSLog(@"after %@",tmp36);
    return tmp36;
}




+ (NSString *)SQLVersionString:(int)type{
    NSString *sql;
    if (type == 0) {
        sql = @"< 21";
    }
    else{
        sql = [NSString stringWithFormat:@" = %d",type];
    }
    return sql;
}

+ (NSString *)SQLLevelString:(int)type{
    NSString *sql;
    if (type == 0) {
        sql = @"< 13";
    }
    else{
        sql = [NSString stringWithFormat:@" = %d",type];
    }
    
    return sql;
}

+ (NSString *)SQLPlayStyleString:(int)type{
    NSString *sql;
    if (type == 0) {
        sql = [NSString stringWithFormat:@"SP"];
    }
    else{
        sql = [NSString stringWithFormat:@"DP"];
    }
    return sql;
}

+ (NSString *)SQLPlayRankString:(int)type{
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

+ (NSString *)SQLClearLampString:(int)type{
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

+ (NSString *)SQLSortTypeString:(int)type{
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
