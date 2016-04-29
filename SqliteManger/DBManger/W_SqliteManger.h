//
//  W_SqliteManger.h
//  SqliteManger
//
//  Created by Mac on 16/4/29.
//  Copyright © 2016年 WuMeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgInfo.h"

@interface W_SqliteManger : NSObject
+ (W_SqliteManger *)ShareInstance;

/*!
 *  检查表存不存在
 *
 *  @param tablename
 *
 *  @return  yes 存在 no 不存在
 *
 */
- (BOOL)checkTableExisit:(NSString *)tableName;
/**
 *  在某个表中是否存在某个字段
 *
 *  @param tableName <#tableName description#>
 *  @param table     <#table description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)isExistTableName:(NSString *)tableName ByWithTableColumnName:(NSString *)TableColumnName;
/**
 *  在某个插入某个字段
 *
 *  @param tableName <#tableName description#>
 *  @param ColumnStr <#ColumnStr description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)insertBytableName:(NSString *)tableName InfoColumn:(NSString *)ColumnStr;

#pragma mark - 初始化表和数据

/**
 *  初始化并创建表数据
 */
-(void)initCreateTable;

/*!
 *  创建系统信息表
 *
 *  @param no
 *
 *  @return yes 创建成功 no 创建失败
 *
 */
- (BOOL)createSystemInfoTable;

/*!
 *  插入数据到系统信息表
 *
 *  @param infos 要插入的数据列表
 *
 *  @return int 实际插入的条数
 *
 */
- (int)insertSystemInfosToTable:(NSArray *)infos;

/*!
 *  取得系统列表
 *
 *  @param pageNumber 要取的页数
 *  @param pageSize   一页的条数
 */
- (NSArray *)getSystemInfoListWith:(int)pageNumber pageSize:(int)pageSize;


/*!
 *  删除系统信息
 *
 *  @param chatid 删除信息的chatid
 *
 *  @return yes 成功 no 失败
 *
 */
- (BOOL)deleteSystemInfoWithChatId:(NSString *)chatId;

/*!
 *  清除系统信息
 *
 *  @param no
 *
 *  @return yes 成功 no 失败
 *
 */
- (BOOL)clearSystemInfo:(NSString *)chatId;


/*!
 *  更新消息状态
 *
 *  @param chatid 消息唯一表示
 *
 *  @param isNew 消息状态
 *
 *  @return yes 成功 no 失败
 *
 */
- (BOOL)updateSystemInfoStatus:(NSString *)isNew withChatId:(NSString *)chatId;


/*!
 *  取得新的系统消息条数
 *
 *  @param no
 *
 *  @return 新的系统消息条数
 *
 */
- (int)getSystemInfoIsNewCount;

/*!
 *  取得新的活动消息条数
 *
 *  @param no
 *
 *  @return 新的活动消息条数
 *
 */
- (int)getActivityInfoIsNewCount;

/*!
 *  关闭新活动消息状态
 *
 *
 *  @return yes 成功 no 失败
 *
 */
- (BOOL)updateActiveInfoNewStatusOff;











@end
