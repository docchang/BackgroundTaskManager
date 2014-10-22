//
//  BackgroundTaskManager.m
//  PhotoKharma
//
//  Created by Lee Hasiuk on 10/17/14.
//  Copyright (c) 2014 Idealab. All rights reserved.
//

#import "BackgroundTaskManager.h"
#import "Timer.h"
#import "AppDelegate.h"

#define kSessionID @"com.backgroundtaskmanager"

#define kDownloadSource @"https://v2.photokharma.io/heartbeat"


#define kWatchdogInterval 20

#define kMinBackgroundTimeRemaining 60

@interface BackgroundTaskManager () <NSURLSessionDelegate>
{
    NSUInteger _count;
    UIBackgroundTaskIdentifier _bgTaskId;
    NSURLRequest *_downloadRequest;
}
@end

@implementation BackgroundTaskManager

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static BackgroundTaskManager *sharedManager;
    dispatch_once(&once, ^
    {
        sharedManager = [self new];
    });
    return sharedManager;
}

- (id)init
{
    if ((self = [super init]) != nil)
    {
        _bgTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)cancelBackgroundTask
{
    if (_bgTaskId != UIBackgroundTaskInvalid)
    {
        NSLog(@"ending background task with id %lu", (unsigned long)_bgTaskId);
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }
}

- (void)createBackgroundTask
{
    UIApplication *app = [UIApplication sharedApplication];
    
    if (_bgTaskId != UIBackgroundTaskInvalid)
    {
        NSLog(@"time left on background task %g", app.backgroundTimeRemaining);
    }
    else
    {
        NSLog(@"Starting background task.");
    }
    
    UIBackgroundTaskIdentifier taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        DebugLog(@"background task expired, %g", [UIApplication sharedApplication].backgroundTimeRemaining);
        
        //start URLSession
        [self startURLSession];
        
        //cancel Background Task
        [self cancelBackgroundTask];
    }];
    
    NSLog(@"background task id was %lu, is now %lu", (unsigned long)_bgTaskId, (unsigned long)taskId);
    
    if (taskId != UIBackgroundTaskInvalid)
    {
        if (_bgTaskId != UIBackgroundTaskInvalid)
        {
            //started a new thread:
            //An array of backgroundTaskID is needed to organize all the background threads
            [app endBackgroundTask:_bgTaskId];
        }
        _bgTaskId = taskId;
    }
}

- (void)beginBackgroundTask
{
    NSAssert([NSThread isMainThread], @"Must be called from main thread.");
    if (_count++ == 0)
    {
        [self createBackgroundTask];
    }
    NSLog(@"beginBackgroundTask task count is now %lu", (unsigned long)_count);
}

+ (void)beginBackgroundTaskWithLocalCounter:(NSUInteger *)localCounter
{
    ++*localCounter;
    [[self sharedManager] beginBackgroundTask];
}

+ (void)beginBackgroundTask
{
    [[BackgroundTaskManager sharedManager] beginBackgroundTask];
}

- (void)endBackgroundTask
{
    NSAssert([NSThread isMainThread], @"Must be called from main thread.");
    NSAssert(_count != 0, @"Count must be > 0.");
    if (--_count == 0)
        [self cancelBackgroundTask];
    NSLog(@"endBackgroundTask task count is now %lu", (unsigned long)_count);
}

+ (void)endBackgroundTaskWithLocalCounter:(NSUInteger *)localCounter
{
    NSAssert(*localCounter != 0, @"Local count must be > 0.");
    --*localCounter;
    [[self sharedManager] endBackgroundTask];
}

+ (void)endBackgroundTask
{
    [[BackgroundTaskManager sharedManager] endBackgroundTask];
}


- (NSURLSession *)backgroundURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kSessionID];
                      sessionConfig.timeoutIntervalForRequest = 2.0;
                      sessionConfig.timeoutIntervalForResource = 2.0;
                      session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:self
                                                         delegateQueue:[NSOperationQueue mainQueue]];
                  });
    return session;
}

- (NSURLRequest *)downloadRequest
{
    if (_downloadRequest == nil)
    {
        _downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kDownloadSource]];
    }
    return _downloadRequest;
}

- (void)startURLSession
{
    NSURLSessionDownloadTask *downloadTask = [[self backgroundURLSession] downloadTaskWithRequest:self.downloadRequest];
    [downloadTask resume];
}

#pragma mark - NSURLSession Delegate method implementation

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    // Check if all download tasks have been finished.
    [[self backgroundURLSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks)
     {
         if ([downloadTasks count] == 0)
         {
             AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
             [appDelegate callCompletionHandlerForSession:kSessionID];
         }
     }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Download finished successfully.");
    }
    
    [self createBackgroundTask];
}

@end
