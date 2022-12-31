//
//  BarCodeViewController.h
//  EInvoiceAuthor
//
//  Created by MartyAirLin on 2014/2/18.
//  Copyright (c) 2014年 con.ptc-nec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanningCode.h"
@protocol QRViewControllerDelegate <NSObject>

-(void) CaptureDone:(ScanningCode *) ResultCode;

@end

@interface QRCodeViewController : UIViewController <UINavigationBarDelegate>
@property (nonatomic,assign) id<QRViewControllerDelegate> delegate;
@end
