#import "SqliteV2Manager.h"
#import <SQLCipher/sqlite3.h>

@implementation SqliteV2Manager

- (int)sqlite3_key_v2_helper:(sqlite3 *)db zDb:(const char *)zDb pKey:(const void *)pKey nKey:(int)nKey {
    return sqlite3_key_v2(db, zDb, pKey, nKey);
}

@end
