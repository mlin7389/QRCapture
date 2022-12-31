//
//  CodeListViewController.m
//  QRCode
//
//  Created by MartyAirLin on 9/5/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "QRSegue.h"
#import "CodeDeatilViewController.h"
#import "QRTableViewCell.h"
#import "SQLiteHandler.h"
#import "CodeListViewController.h"
#import "ScanningCode.h"
@interface CodeListViewController () <UITableViewDataSource,UITableViewDelegate,UIBarPositioningDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tb;
@property (weak, nonatomic) IBOutlet UINavigationItem *TitleNavigationItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acv;
@end

@implementation CodeListViewController {
    NSMutableArray *_CodeArr;
    BOOL _ShouldReloadData;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ModifiedTitle) name:[QRSegue MODIFY_CONTENT_NOTIFICATION] object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MODIFY_CONTENT_NOTIFICATION2) name:[QRSegue MODIFY_CONTENT_NOTIFICATION2] object:nil];
    
    _ShouldReloadData = YES;
    self.TitleNavigationItem.title = NSLocalizedString(@"ScanRecord", nil);
}

-(void) viewDidAppear:(BOOL)animated {
    if (_ShouldReloadData == YES) {
        _ShouldReloadData = NO;
        _CodeArr = [[SQLiteHandler shareSQLiteHandler] loadCodeRecord];
        [self.tb reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:[QRSegue SHOW_DETAIL_SEGUE]]) {
        CodeDeatilViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tb indexPathForCell:sender];
        [vc setScanningCode:[_CodeArr objectAtIndex:indexPath.row]];
    }
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CodeCell"];
    ScanningCode *code = [_CodeArr objectAtIndex:indexPath.row];
    cell.TitleLabel.text = code.insertDate;
    cell.ContentLabel.text = code.codeString;
    NSString *file = [NSString stringWithFormat:@"%@\%d.png",NSTemporaryDirectory(),code.codeID];
    NSFileManager *def = [NSFileManager defaultManager];
    if ([def fileExistsAtPath:file]) {
        cell.img.image = [UIImage imageWithContentsOfFile:file];
    }
    else {
        int currentIndex = (int)indexPath.row;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            UIImage *img1 = [[SQLiteHandler shareSQLiteHandler] loadCodeRecordImageWithCodeID:code.codeID];
            UIImage *img2 = [self resizeImage:img1 withMaxDimension:160];
            
            [UIImagePNGRepresentation(img2) writeToFile:file atomically:YES];
            dispatch_sync(dispatch_get_main_queue(), ^{
                QRTableViewCell *currentCell = (QRTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
                currentCell.img.image = img2;
                [currentCell setNeedsLayout];
            });
        });
    }
    return cell;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_CodeArr count];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( [self.acv isAnimating]) {
        return;
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ScanningCode *code = [_CodeArr objectAtIndex:indexPath.row];
        [_CodeArr removeObject:code];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [[SQLiteHandler shareSQLiteHandler] deleteCode:code.codeID];
            NSString *file = [NSString stringWithFormat:@"%@\%d.png",NSTemporaryDirectory(),code.codeID];
            NSFileManager *def = [NSFileManager defaultManager];
            if ([def fileExistsAtPath:file]) {
                [def removeItemAtPath:file error:nil];
            }
        });
        [self.tb deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void) MODIFY_CONTENT_NOTIFICATION2 {
    _ShouldReloadData = NO;
    _CodeArr = [[SQLiteHandler shareSQLiteHandler] loadCodeRecord];
    [self.tb reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) ModifiedTitle {
    _ShouldReloadData = YES;
}
- (IBAction)ClearAllContentTap:(id)sender {
    if ( [self.acv isAnimating]) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Warning", nil)
                          message:NSLocalizedString(@"Warning01", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([[[[alertView textFieldAtIndex:0] text] uppercaseString] isEqualToString:@"OK"]) {
            [self.acv startAnimating];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [[SQLiteHandler shareSQLiteHandler] clearAll];
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    [self.acv stopAnimating];
                    [_CodeArr removeAllObjects];
                    [self.tb reloadData];
                });
            });
        }
    }
}

- (UIImage *)resizeImage:(UIImage *)image
        withMaxDimension:(CGFloat)maxDimension
{
    if (fmax(image.size.width, image.size.height) <= maxDimension) {
        return image;
    }
    
    CGFloat aspect = image.size.width / image.size.height;
    CGSize newSize;
    
    if (image.size.width > image.size.height) {
        newSize = CGSizeMake(maxDimension, maxDimension / aspect);
    } else {
        newSize = CGSizeMake(maxDimension * aspect, maxDimension);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    CGRect newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
    [image drawInRect:newImageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
