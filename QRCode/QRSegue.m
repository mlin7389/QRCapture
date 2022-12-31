//
//  QR.m
//  QRCode
//
//  Created by MartyAirLin on 9/6/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//

#import "QRSegue.h"

@implementation QRSegue

+(NSString *) QRCODE_SACN_SEGUE {
    return @"QRCodeScanSegue";
}
+(NSString *) SHOW_FULL_IMAGE_SEGUE {
    return @"ShowFullImageSegue";
}
+(NSString *) SHOW_DETAIL_SEGUE {
    return @"ShowDetailSegue";
}
+(NSString *) MODIFY_CONTENT_NOTIFICATION {
    return @"ModifiedContentNotification";
}
+(NSString *) MODIFY_CONTENT_NOTIFICATION2 {
    return @"ModifiedContentNotification2";
}
+(NSString *) Code_39{
    return @"Code-39";
}
+(NSString *) Extended_Code_39{
    return @"Extended-Code-39";
}
+(NSString *) EAN_13{
    return @"EAN-13";
}
+(NSString *) Code_128{
    return @"Code-128";
}
+(NSString *) UPC_E{
    return @"UPC-E";
}
+(NSString *) EAN_8{
    return @"EAN-8";
}
+(NSString *) UPC_A{
    return @"UPC-A";
}
@end
