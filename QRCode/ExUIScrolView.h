//
//  ExUIScrolView.h
//  SDPadPOS
//
//  Created by Marty on 11/7/28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollDelegate

-(void) tapOne;

@end

@interface ExUIScrolView : UIScrollView {

}
@property (nonatomic,assign) id<ScrollDelegate> Exdelegate;
@end
