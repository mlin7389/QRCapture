//
//  GenViewController.m
//  QRCode
//
//  Created by MartyAirLin on 9/6/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "ScanningCode.h"
#import "GenViewController.h"
#import "ImageShowViewController.h"
#import "QRSegue.h"
#import "SQLiteHandler.h"
#import "UIActivityIndicatorStatusView.h"
#import "NKDCode39Barcode.h"
#import "NKDExtendedCode39Barcode.h"
#import "NKDEAN13Barcode.h"
#import "NKDCode128Barcode.h"
#import "NKDUPCEBarcode.h"
#import "NKDEAN8Barcode.h"
#import "NKDUPCABarcode.h"
#import "UIImage-NKDBarcode.h"

typedef enum {
    QRCodeLevel_L,
    QRCodeLevel_M,
    QRCodeLevel_Q,
    QRCodeLevel_H
}QRCodeLevel;

typedef enum {
    EAN_8,
    ISBN,
    UPC_A,
    EAN_13,
    EAN_14,
    Code39
}BarCodeType;

@interface GenViewController () <UIBarPositioningDelegate,UIActionSheetDelegate>
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) IBOutlet UITextView *EnterTextView;
@property (nonatomic,weak) IBOutlet UIView *PictureBackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorStatusView *acv;
@property (weak, nonatomic) IBOutlet UINavigationItem *TitleNavigationItem;
@property (nonatomic,weak) IBOutlet UIButton *CloseButton;
@end

@implementation GenViewController {
    NSArray *_arrCodeTypes;
    ScanningCode *_NewScanningCode;
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
    self.TitleNavigationItem.title = NSLocalizedString(@"GenCode", nil);
    self.EnterTextView.layer.borderWidth = 1.0f;
    self.EnterTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.EnterTextView.layer.cornerRadius = 6.0f;
    self.PictureBackView.layer.borderWidth = 1.0f;
    self.PictureBackView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.PictureBackView.layer.cornerRadius = 6.0f;
    self.CloseButton.layer.borderWidth = 1.0f;
    self.CloseButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.CloseButton.layer.cornerRadius = 6.0f;
    _arrCodeTypes = @[[QRSegue Code_39], [QRSegue Extended_Code_39], [QRSegue Code_128],[QRSegue EAN_8],[QRSegue EAN_13],[QRSegue UPC_A]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)QRCodeGenerate:(id)sender {
    if (![self.EnterTextView.text isEqualToString:@""]) {
        [self GenQRCodeWithQRCodeLevel:QRCodeLevel_L StringData:self.EnterTextView.text];
        [self.EnterTextView resignFirstResponder];
    }
}

- (void)GenQRCodeWithQRCodeLevel:(QRCodeLevel) level StringData:(NSString *) qrString{
    
    if ([self.acv isAnimating]) {
        return;
    }
    
    [self.acv startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        CIFilter *ciFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [ciFilter setDefaults];
        
        NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
        [ciFilter setValue:data forKey:@"inputMessage"];
        
        
        if (level == QRCodeLevel_L) {
            [ciFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
        }
        else if (level == QRCodeLevel_M){
            [ciFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        }
        else if (level == QRCodeLevel_Q){
            [ciFilter setValue:@"Q" forKey:@"inputCorrectionLevel"];
        }
        else {
            [ciFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
        }
        
        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgimg =
        [ciContext createCGImage:[ciFilter outputImage]
                        fromRect:[[ciFilter outputImage] extent]];
        UIImage *image = [UIImage imageWithCGImage:cgimg scale:1.0f
                                       orientation:UIImageOrientationUp];
        CGImageRelease(cgimg);
    
        // if (deviceOrientation is face up/down and interfaceOrientation is landscape)
        BOOL FaceUp =  [UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp;
        BOOL IsPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        BOOL IsPhone = !IsPad;
        BOOL IsLanpsacpe = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight;
        
        if ((FaceUp && IsPad && IsLanpsacpe) || (IsPad && IsLanpsacpe)) {
            UIGraphicsBeginImageContext(CGSizeMake(500, 500));
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetInterpolationQuality(context, kCGInterpolationNone);

            [image drawInRect:CGRectMake(0, 0, 500, 500)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if ((FaceUp && IsPhone) || IsPhone) {
            UIGraphicsBeginImageContext(CGSizeMake(500, 500));
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetInterpolationQuality(context, kCGInterpolationNone);
            
            [image drawInRect:CGRectMake(0, 0, 500, 500)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else{
            UIGraphicsBeginImageContext(self.imageView.frame.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetInterpolationQuality(context, kCGInterpolationNone);
            
            [image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.height, self.imageView.frame.size.width)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
          }
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
            UIImage *img = [UIImage imageWithData:imageData];
            self.imageView.image = img;
            self.imageView.layer.magnificationFilter = kCAFilterNearest;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            ScanningCode *_ResultCode = [ScanningCode new];
            NSDateFormatter *df = [NSDateFormatter new];
            [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
            _ResultCode.insertDate = [df stringFromDate:[NSDate date]];
            _ResultCode.codeType = @"QRCode";
            _ResultCode.codeString = self.EnterTextView.text;
            _ResultCode.codePhoto = self.imageView.image;
            [[SQLiteHandler shareSQLiteHandler] insertCode:_ResultCode];
            [self.acv stopAnimating];
        });

        
        
    });
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.EnterTextView resignFirstResponder];
}

- (IBAction)GenerateBarCodeTap:(id)sender {
    if (![self.EnterTextView.text isEqualToString:@""]) {
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                      destructiveButtonTitle:nil
                           otherButtonTitles:[_arrCodeTypes objectAtIndex:0],[_arrCodeTypes objectAtIndex:1],[_arrCodeTypes objectAtIndex:2],[_arrCodeTypes objectAtIndex:3],[_arrCodeTypes objectAtIndex:4],[_arrCodeTypes objectAtIndex:5], nil];
        [self.EnterTextView resignFirstResponder];
        [actionSheet showInView:self.PictureBackView];
    }
  
}
- (IBAction)ShowFullImageTap:(id)sender {
    if (self.imageView.image != nil) {
        [self performSegueWithIdentifier:[QRSegue SHOW_FULL_IMAGE_SEGUE] sender:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [actionSheet removeConstraints:actionSheet.constraints];
    if (buttonIndex >= [_arrCodeTypes count]) {
        return;
    }
    NSString *msg = nil;
    NSString *TypeString = [_arrCodeTypes objectAtIndex:buttonIndex];
    id barcode;
    
    if ([TypeString isEqualToString:[QRSegue Code_39]]) {
        self.EnterTextView.text = [self.EnterTextView.text uppercaseString];
        if ([self validBarcode:self.EnterTextView.text WithBarCodeType:Code39]) {
            barcode = [NKDCode39Barcode alloc];
        }
		else{
            msg = @"Code 39";
        }
		
	}
    else if ([TypeString isEqualToString:[QRSegue Extended_Code_39]]) {
		barcode = [NKDExtendedCode39Barcode alloc];
	}
	else if ([TypeString isEqualToString:[QRSegue EAN_13]]) {
        if ([self validBarcode:self.EnterTextView.text WithBarCodeType:EAN_13]) {
            barcode = [NKDEAN13Barcode alloc];
        }
		else{
            msg = @"EAN-13";
        }
	}
	else if ([TypeString isEqualToString:[QRSegue Code_128]]) {
		barcode = [NKDCode128Barcode alloc];
	}
	else if ([TypeString isEqualToString:[QRSegue EAN_8]]) {
        if ([self validBarcode:self.EnterTextView.text WithBarCodeType:EAN_8]) {
            barcode = [NKDEAN8Barcode alloc];
        }
		else{
            msg = @"EAN-8";
        }
	}
	else if ([TypeString isEqualToString:[QRSegue UPC_A]]){
        if ([self validBarcode:self.EnterTextView.text WithBarCodeType:UPC_A]) {
            barcode = [NKDUPCABarcode alloc];
        }
		else{
            msg = @"UPC";
        }
	}
    
    if (msg == nil) {
        barcode = [barcode initWithContent:self.EnterTextView.text printsCaption:0];
        [barcode calculateWidth];
        
        UIImage *image = [UIImage imageFromBarcode:barcode];
        //UIImage *theImage = [self rotateImage:[UIImage imageFromBarcode:barcode] onDegrees:90];
        UIImage *theImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
        
        self.imageView.image = theImage;
        self.imageView.layer.magnificationFilter = kCAFilterNearest;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        ScanningCode *_ResultCode = [ScanningCode new];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
        _ResultCode.insertDate = [df stringFromDate:[NSDate date]];
        _ResultCode.codeType = TypeString;
        _ResultCode.codeString = self.EnterTextView.text;
        _ResultCode.codePhoto = theImage;
        [[SQLiteHandler shareSQLiteHandler] insertCode:_ResultCode];
    }
    else {
        msg = [NSString stringWithFormat:@"%@ %@",msg,NSLocalizedString(@"Invalid", nil)];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:msg
                              message:nil
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:[QRSegue SHOW_FULL_IMAGE_SEGUE]]) {
        ImageShowViewController *vc = (ImageShowViewController *)segue.destinationViewController;
        NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.8);
        UIImage *img = [[UIImage alloc] initWithData:imageData];
        [vc setImage:img];
    }
}

-(IBAction)ClearButtonTap:(id)sender {
    self.EnterTextView.text = @"";
    self.imageView.image = nil;
}

-(BOOL) CheckAllNumber:(NSString *) code {
    if ([code rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        return YES;
    }
    else {
        return NO;
    }
}


- (BOOL)validBarcode:(NSString *)code WithBarCodeType:(BarCodeType) type{
    switch (type) {
        case Code39: // Code 39
        {
            if (code.length == 0) {
                return NO;
            }
            
            NSMutableCharacterSet *_alnum = [NSMutableCharacterSet characterSetWithCharactersInString:
                                             @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-.$/+% "];
            [_alnum formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
            if ([code rangeOfCharacterFromSet:[_alnum invertedSet]].location == NSNotFound) {
                return YES;
            }
            else {
                return NO;
            }
        }
        case EAN_8: // EAN-8
        {
            if (code.length != 8) {
                return NO;
            }
            if ([self CheckAllNumber:code] == NO) {
                return NO;
            }
            
            int check = [code intForDigitAt:7];
            int val = (10 -
                       (([code intForDigitAt:1] + [code intForDigitAt:3] + [code intForDigitAt:5] +
                         ([code intForDigitAt:0] + [code intForDigitAt:2] + [code intForDigitAt:4] + [code intForDigitAt:6]) *
                         3) % 10)) % 10;
            
            return check == val;
        }
        case ISBN: // ISBN
        {
            if ([self CheckAllNumber:code] == NO) {
                return NO;
            }
            
            int check = [code intForDigitAt:9];
            int sum = 0;
            for (int i = 0; i < 9; i++) {
                sum += [code intForDigitAt:i] * (i + 1);
            }
            int val = sum % 11;
            
            if (val == 10) {
                return [code characterAtIndex:9] == 'X' || [code characterAtIndex:9] == 'x';
            } else {
                return check == val;
            }
        }
        case UPC_A: // UPC
        {
            if (code.length != 12) {
                return NO;
            }
            if ([self CheckAllNumber:code] == NO) {
                return NO;
            }
            
            int check = [code intForDigitAt:11];
            int val = (10 -
                       (([code intForDigitAt:1] + [code intForDigitAt:3] + [code intForDigitAt:5] + [code intForDigitAt:7] + [code intForDigitAt:9] +
                         ([code intForDigitAt:0] + [code intForDigitAt:2] + [code intForDigitAt:4] + [code intForDigitAt:6] + [code intForDigitAt:8] + [code intForDigitAt:10]) *
                         3) % 10)) % 10;
            
            return check == val;
        }
        case EAN_13: // EAN-13
        {
            if (code.length != 13) {
                return NO;
            }
            if ([self CheckAllNumber:code] == NO) {
                return NO;
            }
            int check = [code intForDigitAt:12];
            int val = (10 -
                       (([code intForDigitAt:0] + [code intForDigitAt:2] + [code intForDigitAt:4] + [code intForDigitAt:6] + [code intForDigitAt:8] + [code intForDigitAt:10] +
                         ([code intForDigitAt:1] + [code intForDigitAt:3] + [code intForDigitAt:5] + [code intForDigitAt:7] + [code intForDigitAt:9] + [code intForDigitAt:11]) *
                         3) % 10)) % 10;
            
            return check == val;
            
        }
        case EAN_14: // EAN-14
        {
            if (code.length != 14) {
                return NO;
            }
            if ([self CheckAllNumber:code] == NO) {
                return NO;
            }
            int check = [code intForDigitAt:13];
            int val = (10 -
                       (([code intForDigitAt:1] + [code intForDigitAt:3] + [code intForDigitAt:5] + [code intForDigitAt:7] + [code intForDigitAt:9] + [code intForDigitAt:11] +
                         ([code intForDigitAt:0] + [code intForDigitAt:2] + [code intForDigitAt:4] + [code intForDigitAt:6] + [code intForDigitAt:8] + [code intForDigitAt:10] + [code intForDigitAt:12]) *
                         3) % 10)) % 10;
            
            return check == val;
            
        }
        default:
            return NO;
    }
}


@end
