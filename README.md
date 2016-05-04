# APPCache
##基于SQLite的key-value式的存储器
>AppCache采用了基于SQLite的key-value式的存储方式。
写APPCache的初衷是，只想使用一种技术来做各种本地缓存的需求。在实践中发现，真正需要进行比较复杂的查询业务的model很少，很多app在本地基本没有什么分页查询、like查询等等。大多本地cache只是进行简单的读和写。为了满足这种需求、简化数据库的使用、对数据进行统一的管理，于是写了一个key-value式，类似NSUSerDefault的基于sqlite的APPCache。由于项目中也有个别的model需要进行复杂的sql查询语句，于是也暴露了FMDatabaseQueue接口，以便满足这不多的需求。               


>AppCache比coreData、NSCoding、NSUserDefaults的好处是:不需要为每个想存储的数据都创建各种sql语句、不需要使用繁杂的coreData api、不需要实现NSCoding协议归档数据，以及可以像使用NSUserDefaults的同时，对数据进行分类管理（将相关数据存储在同一个table中）,方便对数据进行统一管理，比如存储时统一加密、读取时统一解密，或者不需要的时候统一清除。

#使用


    ／／此处只是作为演示，完全可以建立user模型，创建user表，使用第三方工具先将model转化为json、NSDictionary后.按照userId存储user信息。
    
    
    
      //配置路径 创建数据库
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [AppCache initialCacheWithPath:[NSString stringWithFormat:@"%@/%@",path,@"cache.sqlite"]];



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
    
    
    //清除user表
    [[AppCache shareInstance] cleanTable:@"user"];
