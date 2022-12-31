//
//  UIImagePickerController-Fix.m
//  QRCode
//
//  Created by MartyAirLin on 9/7/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//

#import "OrientationFix.h"

@implementation UIImagePickerController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM()  == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
    else{
        return YES;
    }
}

- (BOOL)shouldAutorotate {
    
    if (UI_USER_INTERFACE_IDIOM()  == UIUserInterfaceIdiomPhone) {
        return NO;
    }
    else{
        return YES;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM()  == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else{
        return UIInterfaceOrientationMaskAll;
    }
    
}


@end
