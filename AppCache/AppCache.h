//
//  AppCache.h
//  SwiftLOL
//
//  Created by wangJiaJia on 16/4/29.
//  Copyright © 2016年 SwiftLOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"


////////////////////////////////////////////////////////////////////////////////
//NSString 分类  用于将字符串转化为NSDate
///////////////////////////////////////////////////////////////////////////////////

@interface NSString (ToNSDate)

-(nullable NSDate *)stringToDate;

@end


///////////////////////////////////////////////////////////////////////////////////
//NSDate 分类    用于将NSDate转化为字符串
///////////////////////////////////////////////////////////////////////////////////

@interface NSDate (ToNSString)

-(nullable NSString *)dateToString;

@end



///////////////////////////////////////////////////////////////////////////////////
//APPCache中创建的table,都是按照AppCacheItem模型创建的。
///////////////////////////////////////////////////////////////////////////////////

@interface AppCacheItem : NSObject
//存储的数据的id
@property(nonatomic,strong,nullable)NSString *itemId;
//存储数据的内容
@property(nonatomic,strong,nullable)id  itemContent;
//存储数据创建的时间
@property(nonatomic,strong,nullable)NSDate *itemCreateTime;
//存储数据的时间戳－－－》有效期
@property(nonatomic,assign)NSInteger itemTimestamp;
//存储数据的校验和－－－》用于传给服务器 判断数据是否发生变化 类似于http 304
@property(nonatomic,strong,nullable) NSString *checksum;
//存储数据的类型
@property(nonatomic,strong,nullable) NSString *type;


//存储数据是否过期
-(BOOL)isInExpirationdate;

@end




//////////////////////////////////////////////////////////////////////////////////////////
//AppCache是基于FMDB的key-value式的存储方式。
/*它比coreData、NSCoding、NSUserDefaults、FMDB的好处是，不需要为每个想存储的数据创建各种sql语句、
 不需要使用繁杂的coreData api、不需要实现NSCoding协议归档数据、不需要关心数据结构的变更，以及可以像使用NSUserDefaults的同时，对数据进行分类管理（将相关数据存储在同一个table中）,方便对数据进行统一管理，比如存储时统一加密、读取时统一解密，或者不需要的时候统一清除。
*/
//////////////////////////////////////////////////////////////////////////////////////////


typedef   NSData * _Nullable  (^HandleData)( NSData * _Nullable);



@interface AppCache : NSObject
//暴露给外部 执行sql语句的接口
@property(nonatomic,strong,nonnull)FMDatabaseQueue *dataBaseQueue;
//加密block
@property(nonatomic,strong,nullable) HandleData  encryptionBlock;
//解密block
@property(nonatomic,strong,nullable) HandleData   decryptionBlock;

//配置路径
+(nullable instancetype)initialCacheWithPath:(nullable NSString *)path;

//单例
+(nullable instancetype)shareInstance;

//创建表
-(void)createTable:(nonnull NSString *)tableName;

//清空表中的数据
-(void)cleanTable:(nonnull NSString *)tableName;

//插入、修改数据，如果object为nil 则视为删除数据  object为NSNumber、NSString、NSArray、NSDictionary、NSDate、NSData
-(void)setObject:(nonnull id)object intoTable:(nonnull NSString *)tableName byId:(nonnull NSString *)objectId;

//插入、修改数据，如果object为nil 则视为删除数据
-(void)setObject:(nonnull id)object intoTable:(nonnull NSString *)tableName byId:(nonnull NSString *)objectId timestamp:(NSInteger)timestamp checkSum:(nullable NSString *)checksum;

//获取数据
-(nullable AppCacheItem *)getObjectFormTable:(nonnull NSString *)tableName byObjectId:(nonnull NSString *)objectId;

//获取表中的所有数据
-(nullable NSArray <__kindof AppCacheItem *>  *)getAllObjectFromTable:(nonnull NSString *)tableName;


@end


