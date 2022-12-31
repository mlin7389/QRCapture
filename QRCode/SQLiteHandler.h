//
//  SQLiteHandler.h
//  QRCode
//
//  Created by 林光昇 林光昇 on 12/1/27.
//  Copyright (c) 2012年 PTC. All rights reserved.
//
#import "ScanningCode.h"

@interface SQLiteHandler : NSObject
-(void) insertCode:(ScanningCode *)ResultCode;
-(BOOL) UpdateCode:(NSString *)insertDate CodeID:(int)codeID;
-(BOOL) deleteCode:(int)codeId;
+(SQLiteHandler *) shareSQLiteHandler;
-(NSMutableArray *) loadCodeRecord;
-(BOOL) clearAll;
-(UIImage *) loadCodeRecordImageWithCodeID:(int) codeID;
@end
