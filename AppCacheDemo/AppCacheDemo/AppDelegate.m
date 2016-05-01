//
//  AppDelegate.m
//  AppCacheDemo
//
//  Created by wangJiaJia on 16/4/30.
//  Copyright © 2016年 SwiftLOL. All rights reserved.
//

#import "AppDelegate.h"
#import "AppCache.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *viewController=[[UIViewController alloc] init];
    viewController.view.backgroundColor=[UIColor whiteColor];
    [self.window setRootViewController:viewController];
    [self.window makeKeyAndVisible];
    
    
    [[AppCache shareInstance] setEncryptionBlock:^(NSData * data){
        //在此可以对data进行加密，此处只做演示，直接返回data
        return data;
    }];

    [[AppCache shareInstance] setDecryptionBlock:^(NSData * data){
        //在此可以对data进行解密，此处只做演示，直接返回data
        return  data;
    }];
    
    //创建表
    [[AppCache shareInstance] createTable:@"user"];

    //存储number
    NSNumber *number = [NSNumber numberWithInt:10];
    [[AppCache shareInstance] setObject:number intoTable:@"user" byId:@"userAge"];
    AppCacheItem *item1 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userAge"];
    NSLog(@"%@",item1.itemContent);
    
    //存储日期
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:200000];
    [[AppCache shareInstance] setObject:date intoTable:@"user" byId:@"userBirthday"];
    AppCacheItem *item2 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userBirthday"];
    NSLog(@"%@",item2.itemContent);
    
    
    //存储字符串
    NSString *name = @"swiftLOL";
    [[AppCache shareInstance] setObject:name intoTable:@"user" byId:@"userName"];
    AppCacheItem *item3 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userName"];
    NSLog(@"%@",item3.itemContent);
    
    
    //存储数组
    NSArray *clothes = @[@"adidas",@"jack"];
    [[AppCache shareInstance] setObject:clothes intoTable:@"user" byId:@"userClothes"];
    AppCacheItem *item4 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userClothes"];
    NSLog(@"%@",item4.itemContent);
    
    
    //存储辞典
    NSDictionary *dic = @{@"EnglishTeacher":@"MR Wang"};
    [[AppCache shareInstance] setObject:dic intoTable:@"user" byId:@"userTeachers"];
    AppCacheItem *item5 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userTeachers"];
    NSLog(@"%@",item5.itemContent);
    
    
    //存储json 设置有效期
    NSArray *array=[NSArray arrayWithObject:dic];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [[AppCache shareInstance] setObject:json intoTable:@"user" byId:@"userResponse" timestamp:1300000000 checkSum:nil];
    AppCacheItem *item6 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userResponse"];
    //判断是否过期
    if(!item6.isInExpirationdate)
    {
        NSLog(@"数据过期");
    }
    NSLog(@"%@",item6.itemContent);
    
    //清除user表
    [[AppCache shareInstance] cleanTable:@"user"];
    
    return YES;
}



@end
