//
//  SQLiteHandler.m
//  QRCode
//
//  Created by 林光昇 林光昇 on 12/1/27.
//  Copyright (c) 2012年 PTC. All rights reserved.
//
#import "QRSegue.h"
#import "ScanningCode.h"
#import "FileHandler.h"
#import "SQLiteHandler.h"
#import <sqlite3.h>
@implementation SQLiteHandler

-(void) NotificationModified {
    [[NSNotificationCenter defaultCenter] postNotificationName:[QRSegue MODIFY_CONTENT_NOTIFICATION] object:nil];
}

-(BOOL) clearAll {
	BOOL res = NO;
	char *err_report;
	sqlite3 *database;
	NSString *databasePath = [[FileHandler shareFileHandler] getDBfileFullPath];
	if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		NSString *sql = [NSString stringWithFormat:@"DELETE FROM maintable;VACUUM;"];
		if (sqlite3_exec(database,[sql UTF8String],NULL,NULL,&err_report) == SQLITE_OK) {
			res = YES;
		}
		else {
			NSLog(@"\n insertCode_sqlite3_exec \n %s",err_report);
		}
	}
	else {
		NSLog(@"\n insertCode_open \n %s",sqlite3_errmsg(database));
	}
	sqlite3_close(database);
    [self NotificationModified];
	return res;
}

-(BOOL) UpdateCode:(NSString *)insertDate CodeID:(int)codeID {
	BOOL res = NO;
	sqlite3 *database;
	NSString *databasePath = [[FileHandler shareFileHandler] getDBfileFullPath];
	if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		sqlite3_stmt *stmt;
		NSString *sql = [NSString stringWithFormat:@"UPDATE maintable SET insertDate = '%@' where id = %d",insertDate,codeID];
		NSLog(@"%@",sql);
		if(sqlite3_prepare_v2(database,[sql UTF8String], -1, &stmt, NULL)==SQLITE_OK){
			sqlite3_step(stmt);
		}
		else {
			NSLog(@"\n updateCode_prepare \n %s",sqlite3_errmsg(database));
		}
	}
	else {
		NSLog(@"\n updateCode_open \n %s",sqlite3_errmsg(database));
	}
	sqlite3_close(database);
    [self NotificationModified];
	return res;
}


-(void) insertCode:(ScanningCode *)ResultCode {
	sqlite3 *database;
	NSString *databasePath = [[FileHandler shareFileHandler] getDBfileFullPath];
	if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		sqlite3_stmt *stmt;
		const char *sql="INSERT INTO maintable values (NULL,?,?,?,?)";
		if(sqlite3_prepare_v2(database,sql, -1, &stmt, NULL)==SQLITE_OK){
			sqlite3_bind_text(stmt, 1, [ResultCode.insertDate UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(stmt, 2, [ResultCode.codeType UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(stmt, 3, [ResultCode.codeString UTF8String], -1, SQLITE_TRANSIENT);
			NSData *imageData = UIImageJPEGRepresentation(ResultCode.codePhoto, 0.8);
			sqlite3_bind_blob(stmt, 4, [imageData bytes], (int)[imageData length], NULL);
			sqlite3_step(stmt);
		}
		else {
			NSLog(@"\n insertCode_prepare \n %s",sqlite3_errmsg(database));
		}
	}
	else {
		NSLog(@"\n insertCode_open \n %s",sqlite3_errmsg(database));
	}
	sqlite3_close(database);
    [self NotificationModified];
}

-(BOOL) deleteCode:(int)codeId {
	BOOL res = NO;
	char *err_report;
	sqlite3 *database;
	NSString *databasePath = [[FileHandler shareFileHandler] getDBfileFullPath];
	if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		NSString *sql = [NSString stringWithFormat:@"DELETE FROM maintable WHERE id = %d;VACUUM;",codeId];
		if (sqlite3_exec(database,[sql UTF8String],NULL,NULL,&err_report) == SQLITE_OK) {
			res = YES;
		}
		else {
			NSLog(@"\n insertCode_sqlite3_exec \n %s",err_report);
		}
	}
	else {
		NSLog(@"\n insertCode_open \n %s",sqlite3_errmsg(database));
	}
	sqlite3_close(database);
    [self NotificationModified];
	return res;
}

-(NSMutableArray *) loadCodeRecord {
	NSMutableArray *result = [[NSMutableArray alloc] init];
	sqlite3 *database;
	NSString *docPath = [[FileHandler shareFileHandler] getDBfileFullPath];
	if (sqlite3_open([docPath UTF8String], &database) == SQLITE_OK) {
		sqlite3_stmt *stmt;
		const char *sql = "SELECT id,insertDate,codeType,codeString FROM maintable order by id DESC";
        if (sqlite3_prepare_v2(database, sql , -1, &stmt,  NULL) == SQLITE_OK) {
			while (sqlite3_step(stmt) == SQLITE_ROW) {
				ScanningCode *code = [[ScanningCode alloc] init];
				code.codeID = sqlite3_column_int(stmt, 0);
				code.insertDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
				code.codeType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
				code.codeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
				//NSUInteger blobLength = sqlite3_column_bytes(stmt, 4);
				//NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(stmt, 4) length:blobLength];
				//code.codePhoto = [UIImage imageWithData:imageData];
				[result addObject:code];
			}
		}
		else {
			NSLog(@"\n loadCodeRecord_open \n %s",sqlite3_errmsg(database));
		}
		sqlite3_close(database);
	}
	else {
		NSLog(@"\n loadCodeRecord_open \n %s",sqlite3_errmsg(database));
	}
	return result;
}



-(UIImage *) loadCodeRecordImageWithCodeID:(int) codeID {
	UIImage *result = nil;
	sqlite3 *database;
	NSString *docPath = [[FileHandler shareFileHandler] getDBfileFullPath];
	if (sqlite3_open([docPath UTF8String], &database) == SQLITE_OK) {
		sqlite3_stmt *stmt;
		const char *sql = [[NSString stringWithFormat:@"SELECT * FROM maintable where id = %d",codeID] UTF8String];
        if (sqlite3_prepare_v2(database, sql , -1, &stmt,  NULL) == SQLITE_OK) {
			while (sqlite3_step(stmt) == SQLITE_ROW) {
				NSUInteger blobLength = sqlite3_column_bytes(stmt, 4);
				NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(stmt, 4) length:blobLength];
				result = [UIImage imageWithData:imageData];
			}
		}
		else {
			NSLog(@"\n loadCodeRecord_open \n %s",sqlite3_errmsg(database));
		}
		sqlite3_close(database);
	}
	else {
		NSLog(@"\n loadCodeRecord_open \n %s",sqlite3_errmsg(database));
	}
	return result;
}

+(SQLiteHandler *) shareSQLiteHandler {
	static SQLiteHandler *sql = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sql = [[SQLiteHandler alloc] init];
	});
	return sql;
}
@end
