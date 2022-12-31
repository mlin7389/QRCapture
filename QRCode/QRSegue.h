//
//  QRSegue.h
//  QRCode
//
//  Created by MartyAirLin on 9/6/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//


@interface QRSegue : NSObject {

}
+(NSString *) QRCODE_SACN_SEGUE;
+(NSString *) SHOW_FULL_IMAGE_SEGUE;
+(NSString *) SHOW_DETAIL_SEGUE;
+(NSString *) MODIFY_CONTENT_NOTIFICATION;
+(NSString *) MODIFY_CONTENT_NOTIFICATION2;
+(NSString *) Code_39;
+(NSString *) Extended_Code_39;
+(NSString *) EAN_13;
+(NSString *) Code_128;
+(NSString *) UPC_E;
+(NSString *) EAN_8;
+(NSString *) UPC_A;
@end
