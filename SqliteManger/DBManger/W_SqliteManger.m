//
//  W_SqliteManger.m
//  SqliteManger
//
//  Created by Mac on 16/4/29.
//  Copyright © 2016年 WuMeng. All rights reserved.
//

#import "W_SqliteManger.h"
#import "W_MySqlite.h"

@implementation W_SqliteManger
static W_SqliteManger *instance = nil;

+ (W_SqliteManger *)ShareInstance {
    
    static W_SqliteManger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
    });
    return instance;
}
/**
 *  在某个表中是否存在某个字段
 */
-(BOOL)isExistTableName:(NSString *)tableName ByWithTableColumnName:(NSString *)TableColumnName
{
    NSString *sqlComd = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    NSArray * rs =[[W_MySqlite ShareInstance] queryWithSqlStatement:sqlComd];
    for (int i = 0;i < [rs count];i++) {
        NSDictionary *dict = [rs objectAtIndex:i];
        NSString *tableNameStr = dict[@"name"];
        if ([tableNameStr isEqualToString:TableColumnName]) {
            return YES;
        }
    }
    return NO;
    
}

/**
 *  在某个表中插入字段
 *
 */
-(BOOL)insertBytableName:(NSString *)tableName InfoColumn:(NSString *)ColumnStr
{
    
    [[W_MySqlite ShareInstance] beginTransaction];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ TEXT",tableName,ColumnStr];
    
    BOOL isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
    if (isSuccess) {
        [[W_MySqlite ShareInstance] commit];
    }
    else {
        [[W_MySqlite ShareInstance] rollback];
    }
    [[W_MySqlite ShareInstance] closeDb];
    
    return isSuccess;
    
}
//查看表是否存在
- (BOOL)checkTableExisit:(NSString *)tableName {
    W_MySqlite *sqlite = [W_MySqlite ShareInstance];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"SELECT COUNT(*)  as CNT FROM sqlite_master where type='table' and name='%@'",tableName];
    NSLog(@"======>>>>>>>%@",sqlCmd);
    
    NSArray *rs = [sqlite queryWithSqlStatement:sqlCmd];
    
    BOOL isExisit = NO;
    
    if (rs && [rs count] != 0) {
        NSDictionary *dic = [rs objectAtIndex:0];
        if (dic) {
            NSString *count = [dic objectForKey:@"CNT"];
            if ([count isEqualToString:@"1"]) {
                isExisit = YES;
            }
        }
    }
    
    return isExisit;
}
/**
 *  初始化并创建表数据
 */
-(void)initCreateTable
{
    //创建系统信息表数据
    BOOL tableExisit = [self checkTableExisit:@"systemInfo"];
    if (tableExisit) {
//        没有该字段插入该字段
        if (![self isExistTableName:@"systemInfo" ByWithTableColumnName:@"time"]) {
            [self insertBytableName:@"systemInfo" InfoColumn:@"time"];
        }
    }
    else {
        [self createSystemInfoTable];
    }
    
    
}
#pragma mark - 创建数据库
//创建系统信息表
- (BOOL)createSystemInfoTable {
    BOOL isSuccess = NO;
    [[W_MySqlite ShareInstance] beginTransaction];
    
    NSString *sqlCmd = @"create table if not exists systemInfo \
    (id integer primary key autoincrement,\
    msg text,\
    time text,\
    userid text,\
    isNew text)";
    isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
    if (isSuccess) {
        [[W_MySqlite ShareInstance] commit];
    }
    else {
        [[W_MySqlite ShareInstance] rollback];
    }
    [[W_MySqlite ShareInstance] closeDb];
    
    return isSuccess;
}

//插入数据到系统信息表
- (int)insertSystemInfosToTable:(NSArray *)infos {
    int insertCount = 0;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    [[W_MySqlite ShareInstance] beginTransaction];
    
    for (int i = 0; i < [infos count]; i++) {
        MsgInfo *info = [infos objectAtIndex:i];
        NSString *sqlCmd = @"insert into systemInfo (msg,\
        time,\
        userid,\
        isNew) ";
        
        NSString *values = [NSString stringWithFormat:@" values('%@','%@','%@','%@')"
                            ,info.msg,info.time,info.userid,info.isNew];
        values = [values stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        sqlCmd = [NSString stringWithFormat:@"%@%@",sqlCmd,values];
        
        BOOL isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
        
        if (isSuccess) {
            
            insertCount++;
        }
        else {
            
        }
    }
    
    [[W_MySqlite ShareInstance] commit];
    [[W_MySqlite ShareInstance] closeDb];
    
    return insertCount;
}

- (NSArray *)getSystemInfoListWith:(int)pageNumber pageSize:(int)pageSize {
    NSString *sqlComd =  [NSString stringWithFormat:@"SELECT * FROM systemInfo order by time asc limit %d,%d",pageNumber,pageSize];
    NSArray * rs =[[W_MySqlite ShareInstance] queryWithSqlStatement:sqlComd];
    
    NSMutableArray *systemInfos = [[NSMutableArray alloc] init];
    
    
    if (rs.count>0) {
        for (int i = 0; i<rs.count; i++) {
            NSDictionary *dict = rs[i];
            if (dict) {
                MsgInfo *info = [[MsgInfo alloc]init];
                [info setValuesForKeysWithDictionary:dict];
                [systemInfos addObject:info];
            }
        }
    }
    return systemInfos;
}
//删除系统信息
- (BOOL)deleteSystemInfoWithChatId:(NSString *)chatId {
    [[W_MySqlite ShareInstance] beginTransaction];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"delete from systemInfo where chatId = '%@'",chatId];
    
    BOOL isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
    
    if (isSuccess) {
        [[W_MySqlite ShareInstance] commit];
    }
    else {
        [[W_MySqlite ShareInstance] rollback];
    }
    [[W_MySqlite ShareInstance] closeDb];
    
    return isSuccess;
}

//清除系统信息表
- (BOOL)clearSystemInfo:(NSString *)chatId {
    [[W_MySqlite ShareInstance] beginTransaction];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"delete from systemInfo"];
    
    BOOL isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
    
    if (isSuccess) {
        [[W_MySqlite ShareInstance] commit];
    }
    else {
        [[W_MySqlite ShareInstance] rollback];
    }
    [[W_MySqlite ShareInstance] closeDb];
    
    return isSuccess;
}

//更新系统信息状态
- (BOOL)updateSystemInfoStatus:(NSString*)isNew withChatId:(NSString *)chatId {
    [[W_MySqlite ShareInstance] beginTransaction];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"update systemInfo set  isNew = '%@' where chatId = '%@'",isNew,chatId];
    
    BOOL isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
    if (isSuccess) {
        [[W_MySqlite ShareInstance] commit];
    }
    else {
        [[W_MySqlite ShareInstance] rollback];
    }
    [[W_MySqlite ShareInstance] closeDb];
    
    return isSuccess;
}

//取得新消息条数
- (int)getSystemInfoIsNewCount {
    int newCount = 0;
    
    W_MySqlite *sqlite = [W_MySqlite ShareInstance];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"SELECT COUNT(isNew)  as CNT FROM systemInfo where isNew = '1'"];
    NSArray *rs = [sqlite queryWithSqlStatement:sqlCmd];
    
    if (rs && [rs count] != 0) {
        NSDictionary *dic = [rs objectAtIndex:0];
        if (dic) {
            NSString *countStr = [dic objectForKey:@"CNT"];
            newCount = [countStr intValue];
        }
    }
    
    return newCount;
}

//关闭新活动消息状态
- (BOOL)updateActiveInfoNewStatusOff {
    [[W_MySqlite ShareInstance] beginTransaction];
    
    NSString *sqlCmd = [NSString stringWithFormat:@"update systemInfo set  isNew = '0' where type = '7' "];
    
    BOOL isSuccess = [[W_MySqlite ShareInstance] excuteSQLWithCmd:sqlCmd];
    if (isSuccess) {
        [[W_MySqlite ShareInstance] commit];
    }
    else {
        [[W_MySqlite ShareInstance] rollback];
    }
    [[W_MySqlite ShareInstance] closeDb];
    
    return isSuccess;
}

@end
