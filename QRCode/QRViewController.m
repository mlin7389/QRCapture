//
//  QRViewController.m
//  QRCode
//
//  Created by MartyAirLin on 9/4/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
@import AVFoundation;

#import "SQLiteHandler.h"
#import "ScanningCode.h"
#import "ZBarReaderController.h"
#import "QRSegue.h"
#import "QRViewController.h"
#import "QRCodeViewController.h"
#import "ImageShowViewController.h"
#import "ScanningCode.h"
@interface QRViewController () <UIBarPositioningDelegate,QRViewControllerDelegate,ZBarReaderDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic,weak) IBOutlet UIView *PictureBackView;
@property (nonatomic,weak) IBOutlet UIButton *ScanButton;
@property (nonatomic,weak) IBOutlet UITextView *ResultTextView;
@property (nonatomic,weak) IBOutlet UIImageView *ResultImageView;
@property (nonatomic,weak) IBOutlet UINavigationBar *TitleNavigationBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *ShareBarButtonItem ;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *FromAlbumBarButtonItem;
@property (nonatomic,weak) IBOutlet UIButton *ShowImageFullViewButton;
@property (weak, nonatomic) IBOutlet UILabel *CodeTypeLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *TitleNavigationItem;
- (IBAction)SelectSourceBarButtonTap:(id)sender;
- (IBAction)ShareBarButtonItemTap:(id)sender;
- (IBAction)ScanButtonTap:(id)sender;
- (IBAction)ShowImageFullViewButtonTap:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ScanButtonSpace;
@end



@implementation QRViewController {
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


-(void)handleOpenURL:(NSURL *)url{
    NSData * imageData = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    [self FromImage:image];
}

-(void) FromImage:(UIImage *)image {

    if (image != nil)
    {
        UIImage *_image = image;
        CGImageRef cgimage = _image.CGImage;
        
        ZBarImage *zimg =
        [[ZBarImage alloc]
         initWithCGImage:cgimage];
        
        CGSize size = zimg.size;
        zimg.crop = CGRectMake(0,0,size.width,size.height);
        
        ZBarImageScanner *scanner = [ZBarImageScanner new];
        NSInteger nsyms = [scanner scanImage:zimg];
        NSLog(@"scan image: %@ crop=%@ nsyms=%ld",
              NSStringFromCGSize(size), NSStringFromCGRect(zimg.crop), (long)nsyms);
        
        if(nsyms > 0) {
            ZBarSymbolSet *syms = scanner.results;
            for (ZBarSymbol *symbol in syms)
            {
                self.ResultTextView.text = [self FixZBarDecodingScanResult:symbol.data];
                self.CodeTypeLabel.text = symbol.typeName;
                self.ResultImageView.image = _image;
                ScanningCode *_ResultCode = [ScanningCode new];
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
                _ResultCode.insertDate = [df stringFromDate:[NSDate date]];
                _ResultCode.codeType = symbol.typeName;
                _ResultCode.codeString = self.ResultTextView.text;
                _ResultCode.codePhoto = self.ResultImageView.image;
                [[SQLiteHandler shareSQLiteHandler] insertCode:_ResultCode];
            }
        }
        else {
            self.ResultImageView.image = _image;
            self.ResultTextView.text = @"";
            self.CodeTypeLabel.text = @"";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Failed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"NoImage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
        [alert show];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    UIColor *c1 = [UIColor colorWithRed:250.0f/255.0f green:133.0f/255.0f blue:160.0f/255.0f alpha:1.0f];
    UIColor *c2 = [UIColor colorWithRed:248.0f/255.0f green:92.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    for (id obj in self.view.subviews) {
        if ([obj isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *bar = (UINavigationBar *)obj;
            [bar setBarTintColor:c1];
            [bar setTintColor:[UIColor whiteColor]];
        }
    }
    
    [self.tabBarController.tabBar setBarTintColor:c1];
   // [self.tabBarController.tabBar setTranslucent:YES];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    //[self.tabBarController.tabBar setSelectedImageTintColor:[UIColor purpleColor]];
*/
    
   
    
    self.FromAlbumBarButtonItem.title = NSLocalizedString(@"Photo", nil);
    self.TitleNavigationItem.title = NSLocalizedString(@"ScanCode", nil);
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



-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",(long)buttonIndex);
    if (buttonIndex == 0) {
        [self FromAlbum];
    }
    else if (buttonIndex == 1) {
        [self FromImage:[UIPasteboard generalPasteboard].image];
    }
}
-(void) FromAlbum {
    if([ZBarReaderController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        ZBarReaderController *reader = [ZBarReaderController new];
        reader.readerDelegate = self;
        reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [reader.scanner setSymbology: ZBAR_I25
                              config: ZBAR_CFG_ENABLE
                                  to: 0];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            reader.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popPC = reader.popoverPresentationController;
            popPC.barButtonItem = self.FromAlbumBarButtonItem;
            popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
            [self showViewController:reader sender:self];
        }
        else {
             [self presentViewController:reader animated:YES completion:nil];
        }
    }
}

- (IBAction)SelectSourceBarButtonTap:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Source", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Album",nil),NSLocalizedString(@"Pasteboard",nil), nil];
    [sheet showInView:self.view];
}

- (IBAction)ShareBarButtonItemTap:(id)sender {

    if (self.ResultImageView.image != nil) {
        UIImage *happyImage = self.ResultImageView.image;
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:self.ResultTextView.text, happyImage, nil] applicationActivities:nil];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            avc.popoverPresentationController.barButtonItem = self.ShareBarButtonItem;
        }
        [self presentViewController:avc animated:YES completion:nil];
    }
}



- (IBAction)ScanButtonTap:(id)sender {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"CameraDenied", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Go", nil), nil];
        alert.tag = 2;
        [alert show];
        
    }
    else {
        [self performSegueWithIdentifier:[QRSegue QRCODE_SACN_SEGUE] sender:self];
    }
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            
        }
        else if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

- (IBAction)ShowImageFullViewButtonTap:(id)sender {
    if (self.ResultImageView.image != nil) {
        [self performSegueWithIdentifier:[QRSegue SHOW_FULL_IMAGE_SEGUE] sender:self];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:[QRSegue QRCODE_SACN_SEGUE]]) {
        QRCodeViewController *vc = (QRCodeViewController *)segue.destinationViewController;
        [vc setDelegate:self];
    }
    else if ([[segue identifier] isEqualToString:[QRSegue SHOW_FULL_IMAGE_SEGUE]]) {
        ImageShowViewController *vc = (ImageShowViewController *)segue.destinationViewController;
        [vc setImage:self.ResultImageView.image];
    }
}

#pragma mark - 
#pragma mark Delegate
#pragma mark -

-(void) CaptureDone:(ScanningCode *)ResultCode {
    

    self.ResultImageView.image = ResultCode.codePhoto;
    //iOS 7 Bug - fix
    self.ResultTextView.selectable = NO;
    self.ResultTextView.selectable = YES;
    self.ResultTextView.text = nil;
    self.ResultTextView.text = ResultCode.codeString;
    self.CodeTypeLabel.text = [NSString stringWithFormat:@" %@",ResultCode.codeType];
    //self.ScanButtonSpace.constant = (self.PictureBackView.frame.size.width/2 - self.ScanButton.frame.size.width/2) * -1;

    [UIView animateWithDuration:0.5f animations:^(void){
        
      //  [self.ScanButton layoutIfNeeded];
    }];
    
}


- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
  
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol* symbol = nil;
    for (symbol in results)
    {
        // grab first barcode
        break;
    }
    self.ResultImageView.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    int index = 0;
    for (symbol in results)
    {
        index ++;
        //iOS 7 Bug - fix
        self.ResultTextView.selectable = NO;
        self.ResultTextView.selectable = YES;
        self.ResultTextView.text = nil;
        self.ResultTextView.text = [self FixZBarDecodingScanResult:symbol.data];
        [self.ResultTextView layoutIfNeeded];
        ScanningCode *_ResultCode = [ScanningCode new];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
        _ResultCode.insertDate = [df stringFromDate:[NSDate date]];
        _ResultCode.codeType = symbol.typeName;
        _ResultCode.codeString = self.ResultTextView.text;
        _ResultCode.codePhoto = [info objectForKey: UIImagePickerControllerOriginalImage];
        [[SQLiteHandler shareSQLiteHandler] insertCode:_ResultCode];
    }
   
    [reader dismissViewControllerAnimated:YES completion:^(void){
        NSString *msg = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Identify", nil),index];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:msg
                              message:nil
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
        [alert show];
        [self.CodeTypeLabel setText:@""];
    }];
    
    
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Failed", nil)
                          message:nil
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
    [alert show];
}


-(NSString *)FixZBarDecodingScanResult:(NSString *)text
{
    NSString *tempStr;
    if ([text canBeConvertedToEncoding:NSShiftJISStringEncoding])
        
    {
        tempStr = [NSString stringWithCString:[text cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        if (tempStr == nil)
        {
            tempStr = [NSString stringWithCString:[text cStringUsingEncoding:NSShiftJISStringEncoding] encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        }
        if (tempStr == nil)
        {
            tempStr = [NSString stringWithCString:[text cStringUsingEncoding:NSShiftJISStringEncoding] encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
        }
        if (tempStr == nil)
        {
            tempStr = text;
        }
    }
    return tempStr;
    
}
@end
