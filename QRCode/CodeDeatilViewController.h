//
//  CodeDeatilViewController.h
//  QRCode
//
//  Created by MartyAirLin on 9/6/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanningCode.h"

@interface CodeDeatilViewController : UIViewController
@property (nonatomic,strong) ScanningCode *scanningCode;
@end
