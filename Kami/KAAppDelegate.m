//
//  KAAppDelegate.m
//  Kami
//
//  Created by Ray Hilton on 7/10/2013.
//  Copyright (c) 2013 Wirestorm Pty Ltd. All rights reserved.
//

#import "KAAppDelegate.h"
#import "KATrackListViewController.h"
#import <UIColor-Utilities/UIColor+Expanded.h>
#import <TestFlightSDK/TestFlight.h>

@implementation KAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"e9191b92-45a2-4cd3-a619-53e76851cf40"];

    KATrackListViewController *trackListController = [[KATrackListViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:trackListController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor colorWithRGBHex:0xFF5200];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
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

@end
