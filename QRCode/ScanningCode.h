//
//  ScanningCode.h
//  QRCode
//
//  Created by 林光昇 林光昇 on 12/1/27.
//  Copyright (c) 2012年 PTC. All rights reserved.
//

@interface ScanningCode : NSObject

@property int codeID;
@property (nonatomic,retain) NSString *insertDate;
@property (nonatomic,retain) NSString *codeType;
@property (nonatomic,retain) NSString *codeString;
@property (nonatomic,retain) UIImage *codePhoto;
@end
