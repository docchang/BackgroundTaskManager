//
//  AppDelegate.m
//  BackgroundTaskManager
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Dominic Chang. All rights reserved.
//

#import "AppDelegate.h"
#import "BackgroundTaskManager.h"

@interface AppDelegate ()
{
    void_block_t _completionHandler;
}
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // A reference to the background session must be re-established
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session. See backgroundURLSession above.
    NSURLSession * backgroundSession = [[BackgroundTaskManager sharedManager] backgroundURLSession];
    
    //calling configuration to avoid compiler unuse variable warnings
    [backgroundSession configuration];
    
    //assign completion handler
    _completionHandler = completionHandler;
}

- (void)callCompletionHandler
{
    if (_completionHandler)
    {
        _completionHandler();
        _completionHandler = nil;
    }
}

@end
