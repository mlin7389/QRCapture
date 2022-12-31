//
//  ImageShowViewController.m
//  QRCode
//
//  Created by MartyAirLin on 9/5/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "ExUIScrolView.h"
#import "ImageShowViewController.h"

@interface ImageShowViewController () <UIBarPositioningDelegate,UIScrollViewDelegate>
@property (nonatomic,weak) IBOutlet ExUIScrolView *ImageScrollView;
@property (nonatomic,weak) IBOutlet UIImageView *ShowImageView;
@property (nonatomic,weak) IBOutlet UIButton *ClearButton;
@end

@implementation ImageShowViewController

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ShowImageView.image = self.image;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
       self.ImageScrollView.minimumZoomScale = 0.5;
    }
    self.ImageScrollView.zoomScale = 1.0f;
    self.ShowImageView.layer.magnificationFilter = kCAFilterNearest;
    self.ShowImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)CloseBarButtonItemTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.ShowImageView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
