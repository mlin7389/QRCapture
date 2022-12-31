//
//  CodeDeatilViewController.m
//  QRCode
//
//  Created by MartyAirLin on 9/6/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "QRSegue.h"
#import "SQLiteHandler.h"
#import "CodeDeatilViewController.h"
#import "ImageShowViewController.h"
@interface CodeDeatilViewController ()
@property (weak, nonatomic) IBOutlet UITextView *TitleTextView;

@property (nonatomic,weak) IBOutlet UIView *PictureBackView;
@property (nonatomic,weak) IBOutlet UITextView *ResultTextView;
@property (nonatomic,weak) IBOutlet UIImageView *ResultImageView;
@property (nonatomic,weak) IBOutlet UIButton *ShowImageFullViewButton;
@property (weak, nonatomic) IBOutlet UILabel *CodeTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *SaveButton;
@end



@implementation CodeDeatilViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.SaveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
//    //iOS 7 Bug - fix
//    self.TitleTextView.selectable = NO;
//    self.TitleTextView.selectable = YES;
//    self.TitleTextView.text = nil;
    
    self.TitleTextView.text = self.scanningCode.insertDate;
    self.CodeTypeLabel.text = self.scanningCode.codeType;
    
//    //iOS 7 Bug - fix
//    self.ResultTextView.selectable = NO;
//    self.ResultTextView.selectable = YES;
//    self.ResultTextView.text = nil;
    
    self.ResultTextView.text = self.scanningCode.codeString;
    self.ResultImageView.image = [[SQLiteHandler shareSQLiteHandler] loadCodeRecordImageWithCodeID:self.scanningCode.codeID];
    self.PictureBackView.layer.borderWidth = 1.0f;
    self.PictureBackView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.PictureBackView.layer.cornerRadius = 6.0f;
    self.ResultTextView.layer.borderWidth = 1.0f;
    self.ResultTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.ResultTextView.layer.cornerRadius = 6.0f;
    self.CodeTypeLabel.layer.cornerRadius = 4.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:[QRSegue SHOW_FULL_IMAGE_SEGUE]]) {
        ImageShowViewController *vc = (ImageShowViewController *)segue.destinationViewController;
        [vc setImage:self.ResultImageView.image];
    }
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TitleTextView resignFirstResponder];
}

- (IBAction)SaveBarButtonItemTap:(id)sender {
    [[SQLiteHandler shareSQLiteHandler] UpdateCode:self.TitleTextView.text CodeID:self.scanningCode.codeID];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)ShareButtonTap:(id)sender {
    if (self.ResultImageView.image != nil) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        UIImage *happyImage = self.ResultImageView.image;
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:self.ResultTextView.text, happyImage, nil] applicationActivities:nil];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            avc.popoverPresentationController.barButtonItem = btn;
           // avc.popoverPresentationController.sourceRect = btn.bounds;
        }
        [self presentViewController:avc animated:YES completion:nil];
    }
}


@end
