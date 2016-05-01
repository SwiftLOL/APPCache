//
//  AppCache.m
//  SwiftLOL
//
//  Created by wangJiaJia on 16/4/29.
//  Copyright © 2016年 SwiftLOL. All rights reserved.
//

#import "AppCache.h"
#import "FMDB.h"


#pragma mark -- NSString and  NSDate transform

static NSString * const APPCACHE_DATE_FORMATTER = @"yyyy-MM-dd HH:mm:ss zzz";


@implementation  NSString (ToNSDate)

-(NSDate *)stringToDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:APPCACHE_DATE_FORMATTER];
    NSDate *date=[formatter dateFromString:self];
    return date;
}

@end



@implementation NSDate (ToNSString)

-(NSString *)dateToString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:APPCACHE_DATE_FORMATTER];
    
    NSString *string = [dateFormatter stringFromDate:self];
    
    return string;
}

@end




#pragma mark -- AppCache const variable

#define APPCACHE_DATABASE_PATH  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

static NSString * const APPCACHE_DATABASE_NAME = @"cache.sqlite";

static NSString * const APPCACHE_CREATE_TABLE_SQL = @"create table if not exists %@ \
(id text not null, \
content text not null, \
createdTime text not null, \
timestamp text , \
type text not null, \
checksum text, \
primary key(id))" ;


static NSString * const APPCACHE_INSERT_SQL = @"insert into %@ values (?, ?, ?, ?, ?, ?)" ;

static NSString * const APPCACHE_UPDATE_SQL = @"replace into %@ (id, content, createdTime,timestamp,type,checksum) values (?, ?, ?, ?, ?, ?)" ;

static NSString * const APPCACHE_DELETE_SQL = @"delete from %@ where id = ?";

static NSString * const APPCACHE_QUERY_SQL = @"select * from %@ where id = ?";

static NSString * const APPCACHE_QUERY_ALL_SQL = @"select  * from %@";

static NSString * const APPCACHE_CLEAN_TABLE_SQL = @"delete from %@";

//aes加密 秘钥
static NSString * const APPCACHE_AES_CODE  = @"";


#pragma mark -- AppCacheItem

@implementation AppCacheItem

-(id)init
{
    self=[super init];
    if(self)
    {
        self.itemId=nil;
        self.itemContent=nil;
        self.itemCreateTime=nil;
        self.itemTimestamp=0;
        self.checksum=nil;
    }
    return self;
}


-(BOOL)isInExpirationdate
{
    BOOL flag = NO;
    if(self.itemTimestamp>0)
    {
        NSDate *date=[NSDate date];
        NSTimeZone *zone = [NSTimeZone defaultTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:date];
        NSDate *localeDate = [[NSDate date] dateByAddingTimeInterval:interval];
        NSTimeInterval timeInterval2 = [localeDate timeIntervalSince1970];
        if(timeInterval2<self.itemTimestamp)
            flag=YES;
    }
    
    return flag;
}
@end






#pragma mark -- AppCache

@interface AppCache ()

@property(nonatomic,strong,nonnull)NSString *path;
@property(nonatomic,strong,nonnull)FMDatabaseQueue *dataBaseQueue;

@end


@implementation AppCache


+(nullable instancetype)shareInstance
{
    static AppCache *cache=nil;
    static dispatch_once_t precidate;
    dispatch_once(&precidate, ^{
        cache = [[AppCache alloc] init];
    });
    return cache;
}



-(instancetype)init
{
    self=[super init];
    if(self)
    {
       self.path=[NSString stringWithFormat:@"%@/%@",APPCACHE_DATABASE_PATH,APPCACHE_DATABASE_NAME];
        self.dataBaseQueue=[FMDatabaseQueue databaseQueueWithPath:self.path];
        self.encryptionBlock=nil;
        self.decryptionBlock=nil;
    }
    return self;
}



-(void)createTable:(NSString *)tableName
{
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db executeStatements:[NSString stringWithFormat:APPCACHE_CREATE_TABLE_SQL,tableName]];
    }];
}





-(void)cleanTable:(nonnull NSString *)tableName
{
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:APPCACHE_CLEAN_TABLE_SQL,tableName]];
    }];
}




-(void)setObject:(nonnull id)object intoTable:(nonnull NSString *)tableName byId:(nonnull NSString *)objectId
{
    [self setObject:object intoTable:tableName byId:objectId timestamp:0 checkSum:nil];
}




-(void)setObject:(nonnull id)object intoTable:(nonnull NSString *)tableName byId:(nonnull NSString *)objectId timestamp:(NSInteger)timestamp checkSum:(nullable NSString *)checksum
{
    if(!object)
    {
        [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:APPCACHE_DELETE_SQL,tableName,objectId];
        }];
    }else
    {
        
        NSString *type =nil;
        
        if([object isKindOfClass:[NSString class]])
            type=NSStringFromClass([NSString class]);
        
        if([object isKindOfClass:[NSNumber class]])
        {
            type=NSStringFromClass([NSNumber class]);
            
            NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle=NSNumberFormatterDecimalStyle;
            object=[formatter stringFromNumber:object];
        }
        
        if([object isKindOfClass:[NSDate class]])
        {
            type=NSStringFromClass([NSDate class]);
            object=[NSString stringWithFormat:@"%@",object];
        }
        
        if([object isKindOfClass:[NSData class]])
        {
            type=NSStringFromClass([NSData class]);
            object=[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        }
        
        if([object isKindOfClass:[NSArray class]])
        {
            type =NSStringFromClass([NSArray class]);
            object=[NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
            object=[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        }
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            type =NSStringFromClass([NSDictionary class]);
            object=[NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
            object=[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        }
        
        
        if(self.encryptionBlock)
        {
            object=[object dataUsingEncoding:NSUTF8StringEncoding];
            object=self.encryptionBlock(object);
            object=[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        }
        
        
        if(![self getObjectFormTable:tableName byObjectId:objectId])
        {
            [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:[NSString stringWithFormat:APPCACHE_INSERT_SQL,tableName],objectId,object,[[NSDate date] dateToString],[[NSNumber numberWithInteger:timestamp] stringValue],type,checksum];
            }];
        }else
        {
            [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:[NSString stringWithFormat:APPCACHE_UPDATE_SQL,tableName],objectId,object,[[NSDate date] dateToString],[[NSNumber numberWithInteger:timestamp] stringValue],type,checksum];
            }];
        }

    }
    
}





-(AppCacheItem *)getObjectFormTable:(NSString *)tableName byObjectId:(NSString *)objectId
{
   __block AppCacheItem * item = nil;
    __block FMResultSet * result;
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
       result =[db executeQuery:[NSString stringWithFormat:APPCACHE_QUERY_SQL,tableName],objectId];
        
        if([result next]) {
            item=[self appCacheItemFromFMResultSet:result];
        }
        
        [result close];
    }];

    
    return item;
}





-(nullable NSArray <__kindof AppCacheItem *> *)getAllObjectFromTable:(nonnull NSString *)tableName
{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block FMResultSet * result = nil;
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
       result = [db executeQuery:[NSString stringWithFormat:APPCACHE_QUERY_ALL_SQL,tableName]];
             while ([result next]) {
            [array addObject:[self appCacheItemFromFMResultSet:result]];
        }
        
        [result close];
    }];
    
    if(array.count==0)
        array = nil;
    
    return array;
}




-(AppCacheItem *)appCacheItemFromFMResultSet:(FMResultSet *)result
{
    AppCacheItem *item = [[AppCacheItem alloc] init];
    
        item.itemId=[result stringForColumn:@"id"];
        item.itemContent=[result stringForColumn:@"content"];
        item.itemCreateTime=[[result stringForColumn:@"createdTime"] stringToDate];
        item.itemTimestamp=[[result stringForColumn:@"timestamp"] integerValue];
        item.checksum=[result stringForColumn:@"checksum"];
        item.type=[result stringForColumn:@"type"];
    
        if(self.decryptionBlock)
        {
            item.itemContent=[item.itemContent dataUsingEncoding:NSUTF8StringEncoding];
            item.itemContent=self.decryptionBlock(item.itemContent);
            item.itemContent=[[NSString alloc] initWithData:item.itemContent encoding:NSUTF8StringEncoding];
        }
    
    
    
        if([item.type isEqualToString:NSStringFromClass([NSNumber class])])
        {
            NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle=NSNumberFormatterDecimalStyle;
            item.itemContent=[formatter numberFromString:item.itemContent];
        }
        
        if([item.type isEqualToString:NSStringFromClass([NSDate class])])
        {
            item.itemContent=[item.itemContent stringToDate];
        }
        
        if([item.type isEqualToString:NSStringFromClass([NSData class])])
        {
            item.itemContent=[item.itemContent dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if([item.type isEqualToString:NSStringFromClass([NSArray class])]||
           [item.type isEqualToString:NSStringFromClass([NSDictionary class])])
        {
            item.itemContent=[item.itemContent dataUsingEncoding:NSUTF8StringEncoding];
            item.itemContent=[NSJSONSerialization JSONObjectWithData:item.itemContent options:NSJSONReadingAllowFragments error:nil];
        }
    return item;
}

@end
