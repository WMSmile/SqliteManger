//
//  W_MySqlite.h
//  SqliteManger
//
//  Created by Mac on 16/4/29.
//  Copyright © 2016年 WuMeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface W_MySqlite : NSObject
/**
 *	@brief	单例化数据库对象
 *
 *	@return	数据库操作单例
 */
+ (W_MySqlite *)ShareInstance;

/**
 *	@brief	打开数据库操作，只执行一次，执行成功后，再次调用方法不做任何操作
 *
 *	@param 	dbFilePath 	数据库路径
 *
 *	@return	打开数据库是否成功
 */
- (BOOL)openDbWithFilePath:(NSString *)dbFilePath;

/**
 *	@brief	执行数据库操作
 *
 *	@param 	sqlCmd 	操作语句
 *
 *	@return	操作是否成功
 */
- (BOOL)excuteSQLWithCmd:(NSString *)sqlCmd;
/**
 *	@brief	关闭数据库
 */
- (void)closeDb;

/**
 *	@brief	开始事务
 *
 *	@return	是否成功
 */
- (BOOL)beginTransaction;

/**
 *	@brief	提交操作
 *
 *	@return	返回提交是否成功
 */
- (BOOL)commit;

/**
 *	@brief	取消操作
 *
 *	@return	取消是否成功
 */
- (BOOL)rollback;
/**
 *	@brief	执行数据库查询
 *
 *	@param 	sqlStatement 	查询语句
 *
 *	@return	查询结果 数组中的一个元素为一行的数据 包含在一个字典里面可以按照列明取得
 */
- (NSArray *)queryWithSqlStatement:(NSString *)sqlStatement;

//重置数据库
- (BOOL)resetDB ;
@end
