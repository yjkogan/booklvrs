//
//  BKAppDelegate.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKAppDelegate.h"
#import "BKNavViewController.h"
#import "BKMainViewController.h"
#import "GROAuth.h"

#import <Parse/Parse.h>

@implementation BKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"xmzp0RZewTe4mnrNEtSj9ASnu1C4826iCAQIwIsT"
                  clientKey:@"x1igbTLWGQyW5fsyAmruCa8uDYPIL4ABUrppHi59"];
    [PFFacebookUtils initializeFacebook];
    [GROAuth setGoodreadsOAuthWithConsumerKey:@"WRXqU6cCaApGQMXVZZtfrw" secret:@"29u9ztldefAWW6mFVZaP1CYO7gYiaK2XoBlY6ic49I"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    BKMainViewController *mainVC = [[BKMainViewController alloc] initWithNibName:nil bundle:nil];
    BKMainViewController *mainVC = (BKMainViewController *) self.window.rootViewController;
    NSLog(@"mainVC = %@", mainVC);
//    self.navController = [[BKNavViewController alloc] initWithRootViewController:mainVC];
//    self.window.rootViewController = self.navController;
//    [self.window makeKeyAndVisible];
    
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

@end
