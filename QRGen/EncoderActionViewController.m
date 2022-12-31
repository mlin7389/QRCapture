//
//  ActionViewController.m
//  QRDeCode
//
//  Created by MartyAirLin on 9/17/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "ZBarImageScanner.h"
#import "ZBarImage.h"
#import "EncoderActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScanningCode.h"
@interface EncoderActionViewController () <UINavigationControllerDelegate,UIDocumentInteractionControllerDelegate,UIScrollViewDelegate>

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *ResultTextView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *ResultLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acv;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SaveBarButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navgationItem;


@property (weak, nonatomic) IBOutlet UILabel *infoTitle;
@property (weak, nonatomic) IBOutlet UILabel *infoMessage;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation EncoderActionViewController {
    BOOL TextFound;
    BOOL imageFound;
}


- (IBAction)SaveButtonTap:(id)sender {
    if (self.imageView.image != nil) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
        self.infoTitle.text = NSLocalizedString(@"showInfomationTitle", nil);
        self.infoMessage.text = NSLocalizedString(@"Save Done", nil);
        [self.infoButton setTitle:NSLocalizedString(@"Got it!",nil) forState:UIControlStateNormal];
        [UIView animateWithDuration:0.6f animations:^(void){
            [self.infoView setAlpha:1.0f];
        }];

    }
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoView.layer.cornerRadius = 8.0f;
    self.infoView.alpha = 0.0f;
    
    TextFound = NO;
    imageFound = NO;
    
    self.bgView.layer.borderWidth = 1.0f;
    self.bgView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.bgView.layer.cornerRadius = 6.0f;
    
    self.ResultTextView.layer.borderWidth = 1.0f;
    self.ResultTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.ResultTextView.layer.cornerRadius = 6.0f;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.acv startAnimating];
    [self.BarButton setTitle:NSLocalizedString(@"Done", nil)];
    [self.SaveBarButton setTitle:NSLocalizedString(@"Save", nil)];
    [self.navgationItem setTitle:NSLocalizedString(@"QREncoder", nil)];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                __weak UITextView *textview = self.ResultTextView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url,NSError *error){
                    if(url) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            textview.text = [url absoluteString];
                        }];
                    }
                    TextFound = YES;
                }];
                
                break;
            }
            else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
                __weak UITextView *textview = self.ResultTextView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePlainText options:nil completionHandler:^(NSMutableString *string, NSError *error) {
                    if (string) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            textview.text = [NSString stringWithFormat:@"%@",string];
                        }];
                        TextFound = YES;
                    }
                }];
                
                break;
            }
            else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                __weak UITextView *textview = self.ResultTextView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(NSAttributedString *string, NSError *error) {
                    if (string) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            textview.text = [NSString stringWithFormat:@"%@",[string string]];
                        }];
                        TextFound = YES;
                    }
                }];
                
                break;
            }
        }
        
        if (imageFound) {
            break;
        }
        if (TextFound) {
            break;
        }
    }
    
}
-(void) viewWillAppear:(BOOL)animated {
    if (TextFound != YES) {
        self.navgationItem.leftBarButtonItem = nil;
    }
}
-(void) viewDidAppear:(BOOL)animated {
    if (imageFound == YES) {
        UIImage *_image = self.imageView.image;
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
            for (ZBarSymbol *symbol in syms){
                self.ResultTextView.text = [self FixZBarDecodingScanResult:symbol.data];
                self.ResultLabel.text = symbol.typeName;
                break;
            }
        }
        else {
            self.ResultLabel.text = NSLocalizedString(@"A_Failed", nil);
            self.ResultLabel.textColor = [UIColor redColor];
        }
        [self.acv stopAnimating];
    }
    else if (TextFound == YES) {
        self.ResultLabel.text = @"QRCode";
        [self EnCoder:self.ResultTextView.text];
    }
    else {
        [self.acv stopAnimating];
        self.ResultLabel.text = NSLocalizedString(@"noValue", nil);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

-(void) EnCoder:(NSString *) qrString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        CIFilter *ciFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [ciFilter setDefaults];
        
        NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
        [ciFilter setValue:data forKey:@"inputMessage"];
        [ciFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
        
        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgimg =
        [ciContext createCGImage:[ciFilter outputImage]
                        fromRect:[[ciFilter outputImage] extent]];
        UIImage *image = [UIImage imageWithCGImage:cgimg scale:1.0f
                                       orientation:UIImageOrientationUp];
        CGImageRelease(cgimg);
        
        UIGraphicsBeginImageContext(CGSizeMake(300, 300));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        
        [image drawInRect:CGRectMake(0, 0, 300,300)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
            UIImage *img = [UIImage imageWithData:imageData];
            self.imageView.image = img;
            self.imageView.layer.magnificationFilter = kCAFilterNearest;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.acv stopAnimating];
            if (img != nil) {
                
                NSUserDefaults *userDef = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.martylin.QRCode"];
                
                NSArray *na = (NSArray *)[userDef objectForKey:@"QRCodeExtension"];
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                if (na != nil) {
                    arr = [[NSMutableArray alloc] initWithArray:na];
                }
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                NSData *imageData = UIImageJPEGRepresentation(img, 1);
                NSString *imgBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                
                [dic setObject:imgBase64 forKey:@"image"];
                
                [dic setObject:qrString forKey:@"result"];
                
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
                NSString *time = [df stringFromDate:[NSDate date]];
                [dic setObject:time forKey:@"time"];
                
                [arr addObject:dic];
                [userDef setObject:arr forKey:@"QRCodeExtension"];
                [userDef synchronize];
                //UIImageWriteToSavedPhotosAlbum(CurrentImage, nil, nil, nil);
                
                //        self.infoTitle.text = NSLocalizedString(@"showInfomationTitle", nil);
                //        self.infoMessage.text = NSLocalizedString(@"Save Done", nil);
                //        [self.infoButton setTitle:NSLocalizedString(@"Got it!",nil) forState:UIControlStateNormal];
                //        [UIView animateWithDuration:0.6f animations:^(void){
                //            [self.infoView setAlpha:1.0f];
                //        }];
            }
        });
        
        
        
    });
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

-(IBAction)HideInfo:(id)sender  {
    [UIView animateWithDuration:0.5f animations:^(void){
        [self.infoView setAlpha:0.0f];
    }];
}

@end
