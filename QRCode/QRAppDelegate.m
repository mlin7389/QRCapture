//
//  QRAppDelegate.m
//  QRCode
//
//  Created by MartyAirLin on 9/4/14.
//  Copyright (c) 2014 MySpot. All rights reserved.
//
#import "SQLiteHandler.h"
#import "QRAppDelegate.h"
#import "QRViewController.h"
#import "QRSegue.h"
@interface QRAppDelegate() <UIAlertViewDelegate>


@end

@implementation QRAppDelegate


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"didFinishLaunchingWithOptions  sourceApplication");
    
    if (url != nil && [url isFileURL]) {
        UITabBarController *tbVC = (UITabBarController *)self.window.rootViewController;
        for (UIViewController *vc in tbVC.viewControllers)
        {
            if ([vc isKindOfClass:[QRViewController class]])
            {
                [tbVC setSelectedIndex:0];
                QRViewController *qVC =(QRViewController *)vc;
                [qVC handleOpenURL:url];
            }
        }

    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    [self reloadImages];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
    // Create a background task identifier
    __block UIBackgroundTaskIdentifier task;
    task = [application beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"System terminated background task early");
        [application endBackgroundTask:task];
    }];
    
    // If the system refuses to allow the task return
    if (task == UIBackgroundTaskInvalid)
    {
        NSLog(@"System refuses to allow background task");
        return;
    }
    
    // Do the task
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *pastboardContents = nil;
        
        for (int i = 0; i < 1000; i++)
        {
            if (![pastboardContents isEqualToString:[UIPasteboard generalPasteboard].string])
            {
                pastboardContents = [UIPasteboard generalPasteboard].string;
                NSLog(@"Pasteboard Contents: %@", pastboardContents);
                if ([UIPasteboard generalPasteboard].image != nil) {
                    NSLog(@"Image Contents: %@",[UIPasteboard generalPasteboard].image);
                    ScanningCode *code = [ScanningCode new];
                    code.codePhoto = [UIPasteboard generalPasteboard].image;
                    code.codeString = @"test";
                    code.codeType = @"test";
                    code.insertDate = @"PLay";
                    [[SQLiteHandler shareSQLiteHandler] insertCode:code];
                    
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
                    notification.alertBody = @"New Image";
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            }
            else {
                NSLog(@"Waiting new copy...%d",i);
            }
            // Wait some time before going to the beginning of the loop
            [NSThread sleepForTimeInterval:1];
        }
        
        // End the task
        [application endBackgroundTask:task];
    });*/
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            NSString *productid = @"498473371";
            [[UIApplication sharedApplication] openURL:([NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", productid]])];
        }
        else if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DoNotShowReview"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    BOOL DoNotShowReview = [[NSUserDefaults standardUserDefaults] boolForKey:@"DoNotShowReview"];
    if (DoNotShowReview == NO) {
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"RunIndex"];
        if (index % 5 == 0 && index != 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Review1",nil) message:NSLocalizedString(@"Review2",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Review3",nil) otherButtonTitles:NSLocalizedString(@"Review4",nil),NSLocalizedString(@"Review5",nil), nil];
            [alert setDelegate:self];
            alert.tag = 2;
            [alert show];
        }
        index += 1;
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"RunIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self reloadImages];
    
   
    
    
    
//    if ( [view isMemberOfClass: [CodeListViewController class]] == YES ) {
//        CodeListViewController *vc = (CodeListViewController *) view;
//        [vc viewDidAppear:YES];
//        NSLog(@" [vc viewDidAppear:YES];");
//    }

   
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) reloadImages {
    NSUserDefaults *userDef = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.martylin.QRCode"];
    @try {
        
        NSArray *na = (NSArray *)[userDef objectForKey:@"QRCodeExtension"];
        if (na != nil) {
            for (NSDictionary *dic in na) {
                ScanningCode *code = [[ScanningCode alloc] init];
                code.codeType = @"";
                code.codeString = [dic objectForKey:@"result"];
                code.insertDate = [dic objectForKey:@"time"];
                NSString *base64Encoded = [dic objectForKey:@"image"];
                
                if (code.codeString == nil) {
                    continue;
                }
                if (code.insertDate == nil) {
                    continue;
                }
                if (base64Encoded == nil) {
                    continue;
                }
                
                if (code.codeString.length == 0) {
                    continue;
                }
                if (code.insertDate.length == 0) {
                    continue;
                }
                if (base64Encoded.length == 0) {
                    continue;
                }
                
                
                NSData *da = [[NSData alloc] initWithBase64EncodedString:base64Encoded options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *img = [[UIImage alloc] initWithData:da];
                
                code.codePhoto = img;
                
                [[SQLiteHandler shareSQLiteHandler] insertCode:code];
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:[QRSegue MODIFY_CONTENT_NOTIFICATION2] object:nil];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [userDef setObject:[[NSArray alloc] init] forKey:@"QRCodeExtension"];
        [userDef synchronize];
    }
}
@end
