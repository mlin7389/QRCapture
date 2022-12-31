//
//  QRTeachingViewController.m
//  QRCode
//
//  Created by MartyAirLin on 9/15/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "QRTeachingCollectionViewCell.h"
#import "QRTeachingViewController.h"

#import <MessageUI/MessageUI.h>
@interface QRTeachingViewController () <UINavigationControllerDelegate,UICollectionViewDataSource,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *feedbackItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starItem;

@property (weak, nonatomic) IBOutlet UINavigationItem *titleInfo;
@end

@implementation QRTeachingViewController {
    NSArray *_CodeNames;
    NSDictionary *_CodeInfoDic;
    NSMutableDictionary *_CodeImageDic;
}


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
    [self.feedbackItem setTitle:NSLocalizedString(@"feedback", nil)];
    [self.starItem setTitle:NSLocalizedString(@"starItem", nil)];
    self.titleInfo.title = NSLocalizedString(@"SupportCode", nil);
    NSString *codenamePath = [[NSBundle mainBundle] pathForResource:@"CodeName" ofType:@"plist"];
    NSString *codeinfoPath = [[NSBundle mainBundle] pathForResource:@"Codes" ofType:@"plist"];
    
    _CodeNames = [[NSArray alloc] initWithContentsOfFile:codenamePath];
    _CodeInfoDic = [[NSDictionary alloc] initWithContentsOfFile:codeinfoPath];
    _CodeImageDic = [[NSMutableDictionary alloc] init];
    for (NSString *name in _CodeNames) {
        UIImage *img = [UIImage imageNamed:name];
        if (img != nil) {
            [_CodeImageDic setObject:img forKey:name];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_CodeNames count];
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    QRTeachingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSString *CodeName = [_CodeNames objectAtIndex:indexPath.row];
    cell.label.text = [NSString stringWithFormat:@"%@ - %@",CodeName,[_CodeInfoDic objectForKey:CodeName]];
    cell.imageView.image = [_CodeImageDic objectForKey:CodeName];
    return cell;
    
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)feedback:(id)sender {
    NSArray *toAddress = [NSArray arrayWithObject:@"servicespot@icloud.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"QRCature"];
    [mc setToRecipients:toAddress];
    [mc setMessageBody:@"" isHTML:NO];
    [self presentViewController:mc animated:YES completion:NULL];
}
- (IBAction)starButtonTap:(id)sender {
    NSString *productid = @"498473371";
    [[UIApplication sharedApplication] openURL:([NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", productid]])];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *msg = @"";
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = NSLocalizedString(@"Cancel",nil);
            break;
        case MFMailComposeResultSaved:
            msg = NSLocalizedString(@"SaveDone",nil);
            break;
        case MFMailComposeResultSent:
            msg = NSLocalizedString(@"SendDone",nil);
            break;
        case MFMailComposeResultFailed:
            msg = NSLocalizedString(@"SendFailed",nil);
            break;
        default:
            msg = NSLocalizedString(@"Error",nil);
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm",nil) otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
