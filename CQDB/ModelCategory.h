//
//  ModelCategory.h
//  CQDB
//
//  Created by coderqi on 16/2/23.
//  Copyright © 2016年 coderqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ModelCategory : NSObject

//convert object to sqlite
-(NSInteger)saveToSQLite:(NSString *)dataFilePath;
//get object from sqlite
-(NSArray *)getObjectsFromDataFile:(NSString * _Nullable)filePath;

@end
