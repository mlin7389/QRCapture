//
//  UIActivityIndicatorStatusView.m
//  AmoPortableOrder
//
//  Created by MartyAirLin on 5/13/14.
//  Copyright (c) 2014 PTC. All rights reserved.
//

#import "UIActivityIndicatorStatusView.h"

@implementation UIActivityIndicatorStatusView {
    BOOL _Status;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) startAnimating {
    [super startAnimating];
    _Status = YES;
}

-(void) stopAnimating {
    [super stopAnimating];
    _Status = NO;
}

-(BOOL) IsAnimating {
    return _Status;
}
@end
