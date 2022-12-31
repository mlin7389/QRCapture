//
//  QRTableViewCell.h
//  QRCode
//
//  Created by MartyAirLin on 9/5/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *TitleLabel;
@property (nonatomic,strong) IBOutlet UILabel *ContentLabel;
@property (nonatomic,strong) IBOutlet UIImageView *img;
@end
