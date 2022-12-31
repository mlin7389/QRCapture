//
//  Barcode.h
//  EInvoices
//
//  Created by MartyLin on 1/26/14.
//  Copyright (c) 2014 SpotWorks. All rights reserved.
//

@import AVFoundation;
@import QuartzCore;
#import <Foundation/Foundation.h>

@interface Barcode : NSObject
@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
@property (nonatomic, strong) UIBezierPath *cornersPath;
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;
@property CGRect codeRect;
@property UIColor *fillColor;
@property (nonatomic, strong) NSString *type;
@property BOOL isInserted;
@end
