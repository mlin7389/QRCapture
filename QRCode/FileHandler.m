//
//  FileHandler.m
//  QRCode
//
//  Created by 林光昇 林光昇 on 12/1/27.
//  Copyright (c) 2012年 PTC. All rights reserved.
//

#import "FileHandler.h"
@implementation FileHandler


-(NSString *) documentsPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

-(BOOL) isExistedFileWithDocument:(NSString *) LocalfileName{
    NSString * filePath = [[self documentsPath] stringByAppendingPathComponent:LocalfileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

-(NSString *) getFileFullPathWithDocument:(NSString *) fName {
    NSString * filePath = [[self documentsPath] stringByAppendingPathComponent:fName];
    return filePath;
}

-(NSString *) getFileFullPathWithTemp:(NSString *) fName {
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fName];
    return filePath;
}

-(NSString *) getDBfileFullPath {
	NSString *mydbPath = [[self documentsPath] stringByAppendingPathComponent:@"qrcode.sqlite"];
	if ([self isExistedFileWithDocument:@"qrcode.sqlite"]) {
		return mydbPath;
	}
	else {
		[self initDatabase];
		return mydbPath;
	}
}

-(void) initDatabase {
	if ([self isExistedFileWithDocument:@"qrcode.sqlite"]) {
		return;
	}
	else {
		NSString *resPath = [[NSBundle mainBundle] pathForResource:@"qrcode" ofType:@"sqlite"];
		NSString *mydbPath = [self getFileFullPathWithDocument:@"qrcode.sqlite"];
		[[NSFileManager defaultManager] copyItemAtPath:resPath toPath:mydbPath error:nil];
	}
}

+(FileHandler *) shareFileHandler {
	static FileHandler *file = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		file = [[FileHandler alloc] init];
	});
	return file;
}
@end
