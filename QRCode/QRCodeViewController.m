//
//  MQRCodeViewController.m
//  EInvoices
//
//  Created by MartyLin on 1/26/14.
//  Copyright (c) 2014 SpotWorks. All rights reserved.
//

@import AVFoundation;
@import QuartzCore;
#import "SQLiteHandler.h"
#import "QRCodeViewController.h"
#import "Barcode.h"
#import "SQLiteHandler.h"
#import "FileHandler.h"
@interface QRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UISwitch *flishlightSW;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flishlightSWLabel;
@property (weak, nonatomic) IBOutlet UISwitch *ContinueScanSW;
@property BOOL isDone;
@property (weak, nonatomic) IBOutlet UINavigationBar *TitleUINavigationBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *CloseUIBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SerialScanUIBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextView *ResultTextView;
@property (weak, nonatomic) IBOutlet UILabel *CountLabel;
@end

@implementation QRCodeViewController {
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureMetadataOutput *_metadataOutput;
    BOOL _running;
    NSMutableDictionary *_barcodes;
    CGFloat _initialPinchZoom;
    AVCaptureStillImageOutput *StillImageOutput;
    UIImage *StillImage;
    int _count;
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dissView {
    if (self.ContinueScanSW.on == NO) {
        if ([_barcodes count] == 1 && self.isDone == NO) {
            self.isDone = YES;
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [_barcodes enumerateKeysAndObjectsUsingBlock:^(NSString *key,AVMetadataMachineReadableCodeObject *code,BOOL *STOP){
                [arr addObject:key];
            }];
            
            [self captureStillImage:^(void){
                Barcode *_BarCode = [_barcodes objectForKey:[arr firstObject]];
                ScanningCode *_ResultCode = [ScanningCode new];
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
                _ResultCode.insertDate = [df stringFromDate:[NSDate date]];
                _ResultCode.codeType = _BarCode.type;
                _ResultCode.codeString = [arr firstObject];
                _ResultCode.codePhoto = StillImage;
                if (self.delegate != nil) {
                    [self.delegate CaptureDone:_ResultCode];
                }
                [[SQLiteHandler shareSQLiteHandler] insertCode:_ResultCode];
    
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
	else {
        [_barcodes enumerateKeysAndObjectsUsingBlock:^(NSString *key,AVMetadataMachineReadableCodeObject *code,BOOL *STOP){
            Barcode *Code  = [_barcodes objectForKey:key];
            if (Code.isInserted == NO) {
                Code.isInserted = YES;
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                     self.ResultTextView.text = key;
                });
                [self captureStillImage:^(void){
                    Barcode *_BarCode = [_barcodes objectForKey:key];
                    ScanningCode *_ResultCode = [ScanningCode new];
                    NSDateFormatter *df = [NSDateFormatter new];
                    [df setDateFormat:@"yyyy/MM/dd HH:mm EEE"];
                    _ResultCode.insertDate = [df stringFromDate:[NSDate date]];
                    _ResultCode.codeType = _BarCode.type;
                    _ResultCode.codeString = key;
                    _ResultCode.codePhoto = StillImage;
                    if (self.delegate != nil) {
                        [self.delegate CaptureDone:_ResultCode];
                    }
                    [[SQLiteHandler shareSQLiteHandler] insertCode:_ResultCode];
                    _count+=1;
                    self.CountLabel.text = [NSString stringWithFormat:@"%d",_count];
                    
                    
                    
                }];
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 0;
    
    self.ResultTextView.layer.cornerRadius = 6.0f;
    self.ResultTextView.alpha = 0.0f;
    self.CountLabel.layer.cornerRadius = 6.0f;
    self.CountLabel.alpha = 0.0f;
    
    
    self.CloseUIBarButtonItem.title = NSLocalizedString(@"Close", nil);
    self.SerialScanUIBarButtonItem.title = NSLocalizedString(@"Continue", nil);
	[self.flishlightSW setOn:NO];
    [self.ContinueScanSW setOn:NO];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
		[self.flishlightSW setEnabled:NO];
        
        [self.flishlightSW setAlpha:0.0f];
        [self.flishlightSWLabel setTitle:@""];
	}
    else {
        [self.flishlightSWLabel setTitle:NSLocalizedString(@"LED", nil)];
    }
	
	self.isDone = NO;
	
    [self setupCaptureSession];

    
    
    [_previewView.layer addSublayer:_previewLayer];
	
    _barcodes = [NSMutableDictionary new];
    
    
	[_previewView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
  
}



-(void) turnOnLed:(bool)on
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
	if (on == YES) {
		[device setTorchMode: AVCaptureTorchModeOn];
	}
	else{
		[device setTorchMode: AVCaptureTorchModeOff];
	}
	[device unlockForConfiguration];
}


-(IBAction)onBtnOnOff:(id)sender
{
	[self turnOnLed:self.flishlightSW.on];
}

-(void) viewDidLayoutSubviews {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _previewLayer.frame = CGRectMake(0, 0, _previewView.frame.size.width, _previewView.frame.size.height);
    }
    else {
        _previewLayer.frame = _previewView.bounds;
    }

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
    
  
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}


#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}

- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}


#pragma mark - Actions

- (void)pinchDetected:(UIPinchGestureRecognizer*)recogniser {
    // 1
    if (!_videoDevice) return;
    
    // 2
    if (recogniser.state == UIGestureRecognizerStateBegan) {
        _initialPinchZoom = _videoDevice.videoZoomFactor;
    }
    
    // 3
    NSError *error = nil;
    [_videoDevice lockForConfiguration:&error];
    
    if (!error) {
        CGFloat zoomFactor;
        CGFloat scale = recogniser.scale;
        if (scale < 1.0f) {
            // 4
            zoomFactor = _initialPinchZoom - pow(_videoDevice.activeFormat.videoMaxZoomFactor, 1.0f - recogniser.scale);
        } else {
            // 5
            zoomFactor = _initialPinchZoom + pow(_videoDevice.activeFormat.videoMaxZoomFactor, (recogniser.scale - 1.0f) / 2.0f);
        }
        
        // 6
        zoomFactor = MIN(10.0f, zoomFactor);
        zoomFactor = MAX(1.0f, zoomFactor);
        
        // 7
        _videoDevice.videoZoomFactor = zoomFactor;
        
        // 8
        [_videoDevice unlockForConfiguration];
    }
}


#pragma mark - Video stuff

- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _running = YES;
}

- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    _running = NO;
}

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    
    // 2
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice) {
        NSLog(@"No video camera on this device!");
        return;
    }
    
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
       dispatch_queue_t metadataQueue = dispatch_queue_create("com.martylin.QRCode.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
    
    StillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [StillImageOutput setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [StillImageOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    [_captureSession addOutput:StillImageOutput];
}


#pragma mark -

- (Barcode*)processMetadataObject:(AVMetadataMachineReadableCodeObject*)code {
    // 1
    Barcode *barcode = [_barcodes objectForKey:code.stringValue];
    
    // 2
    if (!barcode) {
        barcode = [Barcode new];
        if (code.stringValue != nil) {
            if (self.ContinueScanSW.on == NO) {
                if ([_barcodes count] == 0){
                    [_barcodes setObject:barcode forKey:code.stringValue];
                }
                else {
                    barcode = nil;
                }
            }
            else {
                [_barcodes setObject:barcode forKey:code.stringValue];
            }
        }
    }
    
    // 3
    barcode.metadataObject = code;
    
    // Create the path joining code's corners
    
    // 4
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    
    // 5
    CGPoint point;
	
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[0], &point);
	
	barcode.codeRect = code.bounds;
	

    // 6
    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    
    // 7
    for (int i = 1; i < code.corners.count; i++) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
    }
    
    // 8
    CGPathCloseSubpath(cornersPath);
    
    // 9
    barcode.cornersPath = [UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    
    // Create the path for the code's bounding box
    
    // 10
    barcode.boundingBoxPath = [UIBezierPath bezierPathWithRect:code.bounds];
    
    // 11
    return barcode;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSMutableSet *foundBarcodes = [NSMutableSet new];
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
           
            Barcode *barcode = [self processMetadataObject:code];
            NSArray *arr = [code.type componentsSeparatedByString:@"."];
            if ([arr count] == 0) {
                barcode.type = code.type;
            }
            else{
                barcode.type = [arr lastObject];
            }
            if (barcode != nil) {
                [foundBarcodes addObject:barcode];
            }
            
        }
    }];
    [self dissView];
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *allSublayers = [_previewView.layer.sublayers copy];
        [allSublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
            if (layer != _previewLayer) {
                [layer removeFromSuperlayer];
            }
        }];
        [foundBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
            CAShapeLayer *cornersPathLayer = [CAShapeLayer new];
            cornersPathLayer.path = barcode.cornersPath.CGPath;
            cornersPathLayer.lineWidth = 2.0f;
            cornersPathLayer.strokeColor = [UIColor greenColor].CGColor;
            cornersPathLayer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f].CGColor;
            [_previewView.layer addSublayer:cornersPathLayer];
			
        }];
		
    });
}


- (void)captureStillImage:(void(^)(void))completion
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [StillImageOutput connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}

  
    [StillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer,(CFStringRef)@"{Exif}" , NULL);
        if (exifAttachments) {
            NSLog(@"attachements: %@", exifAttachments);
        } else {
            NSLog(@"no attachments");
        }
        if (imageSampleBuffer != nil){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            StillImage = [[UIImage alloc] initWithData:imageData];
            
            
            //[imageData writeToFile:[[FileHandler shareFileHandler] getFileFullPathWithDocument:@"temp.jpg"] atomically:YES];
            
            //NSData* imageData = [NSData dataWithData:UIImageJPEGRepresentation(StillImage, 80)];
            //StillImage = [[UIImage alloc] initWithData:imageData];
        }
        completion();
    }];
}
- (IBAction)ContinueSWTap:(id)sender {
    if (self.ContinueScanSW.on == NO) {
        [_barcodes removeAllObjects];
        self.ResultTextView.selectable = NO;
        self.ResultTextView.text = @"";
        self.CountLabel.text = [NSString stringWithFormat:@"%d",_count];
        [UIView animateWithDuration:0.5f animations:^(void){
            self.ResultTextView.alpha = 0.0f;
            self.CountLabel.alpha = 0.0f;
        }];
    }
    else {
        self.ResultTextView.selectable = NO;
        self.ResultTextView.text = @"";
        self.CountLabel.text = [NSString stringWithFormat:@"%d",_count];
        [UIView animateWithDuration:0.5f animations:^(void){
           self.ResultTextView.alpha = 0.7f;
           self.CountLabel.alpha = 0.7f;
        }];
    }
}

@end

