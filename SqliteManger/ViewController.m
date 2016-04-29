//
//  ViewController.m
//  SqliteManger
//
//  Created by Mac on 16/4/29.
//  Copyright © 2016年 WuMeng. All rights reserved.
//

#import "ViewController.h"
#import "W_MySqlite.h"
#import "W_SqliteManger.h"
#import "MsgInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *list = [[NSMutableArray alloc]initWithCapacity:0];
    for(int i = 0 ;i<10;i++)
    {
        MsgInfo *info = [[MsgInfo alloc]init];
        info.msg = [NSString stringWithFormat:@"消息信息+%d",i];
        info.time = [NSString stringWithFormat:@"2015-02-01"];
        info.userid = [NSString stringWithFormat:@"%d",i];
        info.isNew = [NSString stringWithFormat:@"%d",arc4random()%(2)];
    
        [list addObject:info];
    }
    
    NSLog(@"list--->%@",list);
    [[W_SqliteManger ShareInstance]  insertSystemInfosToTable:list];
    NSLog(@"list----%@,count---->%d",[[W_SqliteManger ShareInstance] getSystemInfoListWith:0 pageSize:100],[[W_SqliteManger ShareInstance] getSystemInfoIsNewCount]);
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
