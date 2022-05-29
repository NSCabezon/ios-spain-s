#import <Foundation/Foundation.h>
#import <SQLCipher/sqlite3.h>

@interface SqliteV2Manager : NSObject

- (int)sqlite3_key_v2_helper:(sqlite3 *)db zDb:(const char *)zDb pKey:(const void *)pKey nKey:(int)nKey;

@end
