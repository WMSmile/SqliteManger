//
//  W_MySqlite.m
//  SqliteManger
//
//  Created by Mac on 16/4/29.
//  Copyright © 2016年 WuMeng. All rights reserved.
//

#import "W_MySqlite.h"

#define W_PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface W_MySqlite()
@property (nonatomic,assign) sqlite3  *dataBase;
@end

static W_MySqlite* instance = nil;

@implementation W_MySqlite

+ (W_MySqlite *)ShareInstance {
    static W_MySqlite *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance resetDB];
    });
    return instance;
}
- (NSString *)getCurrentUserDbPath {
    NSString *dbPath = [NSString stringWithFormat:@"%@/d%@b", W_PATH_OF_DOCUMENT,@"mySqlite"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dbPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dbPath;
}

- (BOOL)resetDB {
    [self closeDb];
    NSString *dbFullPath = [NSString stringWithFormat:@"%@/data",[self getCurrentUserDbPath]];
    return [self openDbWithFilePath:dbFullPath];
}
- (BOOL)openDbWithFilePath:(NSString *)dbFilePath {
    
    //如果数据库打开返
    if (_dataBase) return NO;
    
    const char* fileName = [dbFilePath UTF8String];
    
    int state = sqlite3_open(fileName,&_dataBase);
    if (state == SQLITE_OK) {
        NSLog(@"数据库打开成功");
        return YES;
    }
    else {
        NSLog(@"数据库打开失败");
        return NO;
    }
}

- (BOOL)excuteSQLWithCmd:(NSString *)sqlCmd
{
    if (!_dataBase) {
        NSLog(@"未打开数据库文件");
        BOOL isok =[self resetDB];
        if (!isok) {
            return NO;
        }
    }
    
    char * errorMsg;
    //    NSLog(@"%@",sqlCmd);
    int state = sqlite3_exec(_dataBase, [sqlCmd UTF8String], NULL, NULL, &errorMsg);
    if (state == SQLITE_OK) {
        NSLog(@" >> Succeed to %@",sqlCmd);
    }
    else {
        NSLog(@" >> Failed to %@. Error: %@",
              sqlCmd,
              [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
        
        sqlite3_free(errorMsg);
    }
    
    return (state == SQLITE_OK);
}

- (void)closeDb {
    sqlite3_close(_dataBase);
    _dataBase = nil;
}

- (NSArray *)queryWithSqlStatement:(NSString *)sqlStatement{
    if (!_dataBase) {
        NSLog(@"未打开数据库文件");
        BOOL isok =[self resetDB];
        if (!isok) {
            return @[];
        }
    }
    
    NSMutableArray *rs = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement=nil ;
    NSLog(@"%p,sss",_dataBase);
    int state = sqlite3_prepare_v2(_dataBase, [sqlStatement UTF8String], -1, &statement, nil);
    if (state == SQLITE_OK) {
        NSLog(@" >> Succeed to prepare statement. %@",sqlStatement);
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        // get raw data from statement
        int colCountInRow =sqlite3_data_count(statement);
        NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
        
        for (int i = 0;i < colCountInRow;i++) {
            int rowType = sqlite3_column_type(statement, i);
            if (rowType == SQLITE_INTEGER) {
                int colData = sqlite3_column_int(statement, i);
                NSString *colDataStr = [NSString stringWithFormat:@"%d",colData];
                
                const char *colNameC = sqlite3_column_name(statement, i);
                NSString *colName = [NSString stringWithFormat:@"%s",colNameC];
                [rowData setObject:colDataStr forKey:colName];
            }
            else if (rowType == SQLITE_FLOAT) {
                float colData = sqlite3_column_double(statement, i);
                NSString *colDataStr = [NSString stringWithFormat:@"%f",colData];
                
                const char *colNameC = sqlite3_column_name(statement, i);
                NSString *colName = [NSString stringWithFormat:@"%s",colNameC];
                [rowData setObject:colDataStr forKey:colName];
            }
            else if (rowType == SQLITE_TEXT) {
                char* colData = (char*)sqlite3_column_text(statement, i);
                NSString *colDataStr = [NSString stringWithCString:colData encoding:NSUTF8StringEncoding];
                
                const char *colNameC = sqlite3_column_name(statement, i);
                NSString *colName = [NSString stringWithFormat:@"%s",colNameC];
                [rowData setObject:colDataStr forKey:colName];
            }
        }
        
        [rs addObject:rowData];
    }
    sqlite3_finalize(statement);
    [self closeDb];
    return (NSArray *)rs;
}
- (NSArray *)queryWithTableName:(NSString *)sqlStatement{
    if (!_dataBase) {
        NSLog(@"未打开数据库文件");
        BOOL isok =[self resetDB];
        if (!isok) {
            return @[];
        }
    }
    NSMutableArray *rs = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = nil;
    NSLog(@"%p,sss",_dataBase);
    int state = sqlite3_prepare_v2(_dataBase, [sqlStatement UTF8String], -1, &statement, nil);
    if (state == SQLITE_OK) {
        NSLog(@" >> Succeed to prepare statement. %@",sqlStatement);
    }

    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *nameData = (char *)sqlite3_column_text(statement, 1);
        NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
        [rs addObject:columnName];
        NSLog(@"columnName:%@",columnName);
    }

    sqlite3_finalize(statement);

    return (NSArray *)rs;
}
- (BOOL)beginTransaction
{
    return [self excuteSQLWithCmd:@"BEGIN EXCLUSIVE TRANSACTION;"];
}
- (BOOL)commit
{
    return [self excuteSQLWithCmd:@"COMMIT TRANSACTION;"];
}
- (BOOL)rollback
{
    return [self excuteSQLWithCmd:@"ROLLBACK TRANSACTION;"];
}
@end
