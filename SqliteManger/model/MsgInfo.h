//
//  MsgInfo.h
//  SqliteManger
//
//  Created by Mac on 16/4/29.
//  Copyright © 2016年 WuMeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgInfo : NSObject


@property (strong, nonatomic) NSString *msg;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSString *isNew; //1未读, 0已读
@end
