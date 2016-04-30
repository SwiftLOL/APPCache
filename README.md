# APPCache
基于FMDB的key-value式的存储器
//AppCache是基于FMDB的key-value式的存储方式。
/*它比coreData、NSCoding、NSUserDefaults、FMDB的好处是，不需要为每个想存储的数据创建各种sql语句、
 不需要使用繁杂的coreData api、不需要实现NSCoding协议归档数据、不需要关心数据结构的变更，以及可以像使用NSUserDefaults的同时，对数据进行分类管理（将相关数据存储在同一个table中）,方便对数据进行统一管理，比如存储时统一加密、读取时统一解密，或者不需要的时候统一清除。
