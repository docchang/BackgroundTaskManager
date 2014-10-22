//
//  AppDelegate.m
//  BackgroundTaskManager
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Dominic Chang. All rights reserved.
//

#import "AppDelegate.h"
#import "MultitaskingManager.h"

@interface AppDelegate()
@property (nonatomic , strong) NSMutableDictionary *completionHandlerDictionary;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    DebugMethod;
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DebugMethod;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DebugMethod;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // You must re-establish a reference to the background session,
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session. See backgroundURLSession above.
    
    NSLog(@"Rejoining session with identifier %@ %@", identifier, [[MultitaskingManager sharedInstance] backgroundURLSession]);
    
    [self addCompletionHandler:completionHandler forSession:identifier];
}

- (void)addCompletionHandler:(void_block_t)handler forSession:(NSString *)identifier
{
    if (![self.completionHandlerDictionary isKindOfClass:[NSMutableDictionary class]])
    {
        self.completionHandlerDictionary = [NSMutableDictionary dictionary];
    }
    
    if ([self.completionHandlerDictionary objectForKey:identifier])
    {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession: (NSString *)identifier
{
    void_block_t handler = [self.completionHandlerDictionary objectForKey: identifier];
    
    if (handler)
    {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
        
        handler();
    }
}


@end
