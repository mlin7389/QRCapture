//
//  ExUIScrolView.m
//  SDPadPOS
//
//  Created by Marty on 11/7/28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ExUIScrolView.h"

@implementation ExUIScrolView
@synthesize Exdelegate;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = [touch tapCount];
    switch (tapCount) {
        case 2:
        {
			if(self.zoomScale == 1.0){
				[self setZoomScale:2.0 animated:YES];
			}
            else if(self.zoomScale == 2.0){
				[self setZoomScale:3.0 animated:YES];
			}
            else if(self.zoomScale == 3.0){
				[self setZoomScale:1.0 animated:YES];
			}
            else if(self.zoomScale >= 1.5){
				[self setZoomScale:3.0 animated:YES];
			}
			else {
				[self setZoomScale:1.0 animated:YES];
			}
            break;
        }
		case 1:
			if (Exdelegate != nil) {
				[Exdelegate tapOne];
			}
			break;
        default:
            break;
    }
}
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
