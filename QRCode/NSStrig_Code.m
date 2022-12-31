//
//  NSStrig-Code.m
//  QRCode
//
//  Created by MartyAirLin on 9/6/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//

#import "NSStrig_Code.h"

@implementation NSString (NSStrig_Code)
- (int)intForDigitAt:(NSUInteger)index {
    unichar ch = [self characterAtIndex:index];
    if (ch >= '0' && ch <= '9') {
        return ch - '0';
    } else
        return 0;
}
@end
