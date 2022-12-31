//
//  FileHandler.h
//  QRCode
//
//  Created by 林光昇 林光昇 on 12/1/27.
//  Copyright (c) 2012年 PTC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandler : NSObject
-(NSString *) documentsPath;
-(BOOL) isExistedFileWithDocument:(NSString *) LocalfileName;
-(NSString *) getFileFullPathWithDocument:(NSString *) fName;
-(NSString *) getFileFullPathWithTemp:(NSString *) fName;
-(NSString *) getDBfileFullPath;
-(void) initDatabase;
+(FileHandler *) shareFileHandler;
@end
