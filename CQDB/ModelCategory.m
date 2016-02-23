//
//  ModelCategory.m
//  CQDB
//
//  Created by coderqi on 16/2/23.
//  Copyright © 2016年 coderqi. All rights reserved.
//

#import "ModelCategory.h"

#import <sqlite3.h>
static sqlite3 *db = nil;

@implementation ModelCategory

-(BOOL)openDB:(NSString *)dataFileName{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.sqlite",docPath,dataFileName];
    int result = sqlite3_open(filePath.UTF8String, &db);
    if (result != SQLITE_OK) {
        @throw [NSException exceptionWithName:@"CQDataBaseFileError" reason:@"Tool can't open the file,please check the file Path is a right file Name" userInfo:nil];
        return NO;
    }
    NSLog(@"CQ ->  :打开数据库文件:%@",filePath);
    return YES;
}

-(BOOL)closeDB{
    int result = sqlite3_close(db);
    if (result != SQLITE_OK) {
        return NO;
    }
    db = nil;
    return  YES;
}
-(NSInteger)saveToSQLite:(NSString *)dataFileName{
    
    NSString * tableName = [[NSString stringWithUTF8String:class_getName(self.class)] lowercaseString];
    [self saveToSQLite:dataFileName withTableName:tableName];
    return 0;
}

-(NSInteger)saveToSQLite:(NSString *)dataFileName withTableName:(NSString *)tableName{
    //open DataBase
    [self openDB:dataFileName];
    NSMutableString *createSql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (tid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,",tableName];
    NSMutableString *savaSql = [NSMutableString stringWithFormat:@"INSERT INTO %@ VALUES((select max(tid) from %@) + 1, ",tableName,tableName];
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList(object_getClass(self), &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        Ivar var = vars[i];
        NSString *varName = [[NSString stringWithUTF8String:ivar_getName(var)] substringFromIndex:1];
        NSString *varType = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
        [createSql appendString:[NSString stringWithFormat:@" %@ %@,",[varName lowercaseString] , [self SQLiteTypeForTypeEncoding:varType]]];
        [savaSql appendString:[NSString stringWithFormat:@"'%@', ",[self valueForKey:varName]]];
    }
    createSql = [createSql substringToIndex:createSql.length-1].mutableCopy;
    savaSql = [savaSql substringToIndex:savaSql.length-2].mutableCopy;
    [createSql appendString:@");"];
    [savaSql appendString:@");"];
    //create table if not exist
    int result = sqlite3_exec(db, createSql.UTF8String, nil, nil, nil);
    if (result != SQLITE_OK) {
        @throw [NSException exceptionWithName:@"CQDataBaseTableError" reason:@"Tool can't create the table,please check the database is closed" userInfo:nil];
        return 2;
    }
    //insert the value of model.
    result =sqlite3_exec(db, savaSql.UTF8String, nil, nil, nil);
    if (result != SQLITE_OK) {
        @throw [NSException exceptionWithName:@"CQDataBaseDataError" reason:@"Tool can't insert the Model," userInfo:nil];
        return 3;
    }
    sqlite3_close(db);
    [self  closeDB];
    return 0;
}

-(NSArray *)getObjectsFromDataFile:(NSString * _Nullable)filePath{
    NSMutableArray *array = [NSMutableArray array];
    return array;
}

//
-(NSString *)SQLiteTypeForTypeEncoding:(NSString *)encodingType{
    NSString *type = @"id";
    if (encodingType.length > 2) {
        type = [encodingType substringWithRange:NSMakeRange(2, encodingType.length-3)];
    }else{
        type = encodingType;
    }
    //Affinity type for most type for model
    if([type isEqualToString:@"NSString"] | [type isEqualToString:@"*"]){
        type = nil;
        type = @"TEXT";
    }else if([type isEqualToString:@"NSInteger"] | [[type lowercaseString] isEqualToString:@"i"] | [[type lowercaseString] isEqualToString:@"q"] | [[type lowercaseString] isEqualToString:@"s"] | [[type lowercaseString] isEqualToString:@"l"]){
        type = nil;
        type = @"INTEGER";
    }else if ([type isEqualToString:@"UIImage"]){
        type = nil;
        type = @"NONE";
    }else if ([[type lowercaseString] isEqualToString:@"f"] | [[type lowercaseString] isEqualToString:@"d"]){
        type = nil;
        type = @"REAL";
    }else if([type isEqualToString:@"B"] ){
        type = nil;
        type = @"BOOL";
    }else{
        type = nil;
        type = @"NUMERIC";
    }
    return type;
}

@end
