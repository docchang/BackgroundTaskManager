//
//  AppDelegate.m
//  BackgroundTaskManager
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Dominic Chang. All rights reserved.
//

#import "AppDelegate.h"
#import "BackgroundTaskManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [BackgroundTaskManager handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

@end
