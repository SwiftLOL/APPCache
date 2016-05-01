# APPCache
##基于FMDB的key-value式的存储器
>AppCache采用了基于FMDB的key-value式的存储方式。
它比coreData、NSCoding、NSUserDefaults、FMDB的好处是:不需要为每个想存储的数据创建各种sql语句、不需要使用繁杂的coreData api、不需要实现NSCoding协议归档数据、不需要关心数据结构的变更，以及可以像使用NSUserDefaults的同时，对数据进行分类管理（将相关数据存储在同一个table中）,方便对数据进行统一管理，比如存储时统一加密、读取时统一解密，或者不需要的时候统一清除。
 
#使用

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
    [[AppCache shareInstance] setObject:json intoTable:@"user" byId:@"userResponse" timestamp:2462037226 checkSum:nil];
    AppCacheItem *item6 = [[AppCache shareInstance] getObjectFormTable:@"user" byObjectId:@"userResponse"];
    //判断是否过期
    if(!item6.isInExpirationdate)
    {
        NSLog(@"数据过期");
    }
    NSLog(@"%@",item6.itemContent);
    
    
    ／／如果想建表存储model，可以使用第三方工具先将model转化为json、NSDictionary.
