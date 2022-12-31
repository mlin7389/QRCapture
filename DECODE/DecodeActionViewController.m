//
//  ActionViewController.m
//  QRDeCode
//
//  Created by MartyAirLin on 9/17/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//

#import "ZBarImageScanner.h"
#import "ZBarImage.h"
#import "DecodeActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScanningCode.h"
@interface DecodeActionViewController () <UINavigationControllerDelegate,UIDocumentInteractionControllerDelegate,UIScrollViewDelegate,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *ResultTextView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *ResultLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acv;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DoneButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navgationItem;
@property (weak, nonatomic) IBOutlet UIWebView *webQRcode;
@property (weak, nonatomic) IBOutlet UIButton *IdenitifyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SaveBarButton;

@property (weak, nonatomic) IBOutlet UILabel *infoTitle;
@property (weak, nonatomic) IBOutlet UILabel *infoMessage;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@end


const float zoomSc = 12.0;

@implementation DecodeActionViewController {
    BOOL TextFound;
    BOOL imageFound;
    UIImage *CurrentImage;
    BOOL isShowed;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    if (scale > zoomSc)
    {
        scrollView.zoomScale= zoomSc;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

    [self.acv stopAnimating];
    //restrict zoomscale by adding javascript code
    //make changes to only maximum-scale value as i have set it to 10.0.
    NSString* js =
    @"var meta = document.createElement('meta'); "
    "meta.setAttribute( 'name', 'viewport' ); "
    "meta.setAttribute( 'content', 'width = device-width' ); "
    "document.getElementsByTagName('head')[0].appendChild(meta)";
    
    [webView stringByEvaluatingJavaScriptFromString: js];
    
    if (imageFound) {
       [self.IdenitifyButton setHidden:YES];
    }
    else if (TextFound) {
        if (isShowed == NO) {
            isShowed = YES;
             [self showInfomation];
        }
       
        self.ResultLabel.text = @"";
        [self.IdenitifyButton setHidden:NO];
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
    
    
    [self.IdenitifyButton setHidden:YES];
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
    [self.DoneButton setTitle:NSLocalizedString(@"Done", nil)];
    [self.SaveBarButton setTitle:NSLocalizedString(@"Save", nil)];
    [self.navgationItem setTitle:NSLocalizedString(@"QRDecode", nil)];
    [self.IdenitifyButton setTitle:NSLocalizedString(@"Idenitify", nil) forState:UIControlStateNormal];
    
    [self.acv startAnimating];
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {

                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            CurrentImage = image;
                        }];
                    }
                }];
                imageFound = YES;
                break;
            }
            else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                __weak UIWebView *webView = self.webQRcode;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url,NSError *error){
                    if(url) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
                            [webView loadRequest:requestObj];
                            NSLog(@"url:%@",url);
                            
                        }];
                    }
                     TextFound = YES;
                }];
               
                break;
            }
        }
        
        if (imageFound) {
            self.ResultLabel.text = @"";
            break;
        }
        else if (TextFound) {
            
            break;
        }
    }
    
}
-(void) viewWillAppear:(BOOL)animated {
   
}

-(void) viewDidAppear:(BOOL)animated {
    if (imageFound == YES) {
        CGImageRef cgimage = CurrentImage.CGImage;
        
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
        
        NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.jpg"];
        [UIImageJPEGRepresentation(CurrentImage, 1.0) writeToFile:imagePath atomically:YES];
        NSURL *url = [NSURL URLWithString:imagePath];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.webQRcode loadRequest:requestObj];
     
        
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
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

- (IBAction)IdenitifyTap:(id)sender {
    
    [self.acv startAnimating];
    UIGraphicsBeginImageContextWithOptions(self.bgView.bounds.size, self.bgView.opaque, 0.0);
    [self.bgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
 
    CurrentImage = img;
    CGImageRef cgimage = CurrentImage.CGImage;
    
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
        if (CurrentImage != nil) {
            
            NSUserDefaults *userDef = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.martylin.QRCode"];
            
            NSArray *na = (NSArray *)[userDef objectForKey:@"QRCodeExtension"];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            if (na != nil) {
                arr = [[NSMutableArray alloc] initWithArray:na];
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSData *imageData = UIImageJPEGRepresentation(CurrentImage, 1);
            NSString *imgBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            [dic setObject:imgBase64 forKey:@"image"];
            
             [dic setObject:self.ResultTextView.text forKey:@"result"];
            
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
        self.ResultLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.ResultLabel.text = NSLocalizedString(@"A_Failed", nil);
        self.ResultLabel.textColor = [UIColor redColor];
    }

    [self.acv stopAnimating];
}



- (void) showInfomation {
    BOOL r = [[NSUserDefaults standardUserDefaults] boolForKey:@"showBefore"];
    if (r == NO) {
        self.infoTitle.text = NSLocalizedString(@"showInfomationTitle", nil);
        self.infoMessage.text = NSLocalizedString(@"showInfomation1", nil);
        [self.infoButton setTitle:NSLocalizedString(@"Got it!",nil) forState:UIControlStateNormal];
        [UIView animateWithDuration:0.6f animations:^(void){
            [self.infoView setAlpha:1.0f];
        }];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showBefore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}
- (IBAction)SaveButtonTap:(id)sender {
    
}
-(IBAction)HideInfo:(id)sender  {
    [UIView animateWithDuration:0.5f animations:^(void){
        [self.infoView setAlpha:0.0f];
    }];
}
@end
