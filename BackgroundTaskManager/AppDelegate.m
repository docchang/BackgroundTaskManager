//
//  AppDelegate.m
//  BackgroundTaskManager
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Dominic Chang. All rights reserved.
//

#import "AppDelegate.h"
#import "BackgroundTaskManager.h"

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

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    // You must re-establish a reference to the background session,
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session. See backgroundURLSession above.
    
    NSURLSession * backgroundSession = [[BackgroundTaskManager sharedManager] backgroundURLSession];
    [backgroundSession configuration];
    
    NSLog(@"Rejoining session %@ with identifier %@", backgroundSession, identifier);
    
    [self addCompletionHandler:completionHandler forSession:identifier];
}

- (void)addCompletionHandler:(void_block_t)handler forSession:(NSString *)identifier
{
    if (![self.completionHandlerDictionary isKindOfClass:[NSMutableDictionary class]])
    {
        self.completionHandlerDictionary = [NSMutableDictionary dictionary];
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession: (NSString *)identifier
{
    void_block_t handler = [self.completionHandlerDictionary objectForKey:identifier];
    
    if (handler)
    {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
        handler();
    }
}


@end
