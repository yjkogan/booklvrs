//
//  BKAppDelegate.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKAppDelegate.h"
#import "Leanplum.h"

#import "BKNavViewController.h"
#import "BKMainViewController.h"
#import "GROAuth.h"
#import "apiKeys.h"

@implementation BKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //We've inserted your API keys here for you :)
    #ifdef DEBUG
        [Leanplum setAppId:@"i5ECf21LqATDWsHPy3vJi3WswiVWidfvHw6OSCXNcTo" withDevelopmentKey:@"gPzGeVsJPABIOVo0OSyJVVZsWyF1txq9rNjhA5xxSQU"];
    #else
        [Leanplum setAppId:@"i5ECf21LqATDWsHPy3vJi3WswiVWidfvHw6OSCXNcTo" withProductionKey:@"nqMlZfaWstBf5sLuD7trxwOockxH7rpNhKcA18LRDwk"];
    #endif

    // Syncs all the files between your main bundle and Leanplum.
    // This allows you to swap out and A/B test any resource file
    // in your project in realtime.
    [Leanplum syncResources];
                      
    // Starts a new session and updates the app from Leanplum.
    [Leanplum start];
    

    [Parse setApplicationId:PARSE_APP_ID
                  clientKey:PARSE_CLIENT_KEY];
    [PFFacebookUtils initializeFacebook];
    [GROAuth setGoodreadsOAuthWithConsumerKey:GOODREADS_CONSUMER_KEY secret:GOODREADS_CONSUMER_SECRET];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
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
