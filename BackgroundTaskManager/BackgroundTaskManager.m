//
//  BackgroundTaskManager.m
//  PhotoKharma
//
//  Created by Lee Hasiuk on 10/17/14.
//  Copyright (c) 2014 Idealab. All rights reserved.
//

#import "BackgroundTaskManager.h"

#define kSessionID @"com.backgroundtaskmanager"
#define kDownloadSource @"https://v2.photokharma.io/heartbeat"

@interface BackgroundTaskManager () <NSURLSessionDelegate>
{
    NSUInteger _count;
    UIBackgroundTaskIdentifier _bgTaskId;
    NSURLRequest *_downloadRequest;
    void_block_t _completionHandler;
}

@end

@implementation BackgroundTaskManager

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static BackgroundTaskManager *sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (id)init
{
    if ((self = [super init]) != nil) {
        _bgTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)cancelBackgroundTask
{
    if (_bgTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }
}

- (void)createBackgroundTask
{
    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //start URLSession
        [self startURLSession];
        
        //cancel Background Task
        [self cancelBackgroundTask];
    }];
}

- (void)beginBackgroundTask
{
    NSAssert([NSThread isMainThread], @"Must be called from main thread.");
    if (_count++ == 0) {
        [self createBackgroundTask];
    }
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
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *sessionConfig = nil;
        //iOS8
        if ([[NSURLSessionConfiguration class] respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
            sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kSessionID];
        }
        //iOS7
        else {
            sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:kSessionID];
        }
        
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
    if (_downloadRequest == nil) {
        _downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kDownloadSource]];
    }
    return _downloadRequest;
}

- (void)startURLSession
{
    NSURLSessionDownloadTask *downloadTask = [[self backgroundURLSession] downloadTaskWithRequest:self.downloadRequest];
    [downloadTask resume];
}

+ (BOOL)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void_block_t)completionHandler
{
    return [[BackgroundTaskManager sharedManager] handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

- (BOOL)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void_block_t)completionHandler
{
    // A reference to the background session must be re-established
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session. See backgroundURLSession above.
    [self backgroundURLSession];
    
    if ([identifier isEqualToString:kSessionID]) {
        _completionHandler = completionHandler;
        return YES;
    }
    
    return NO;
}

#pragma mark - NSURLSession Delegate method implementation

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    // Check if all download tasks have been finished.
    [[self backgroundURLSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
         if ([downloadTasks count] == 0) {
             //calling completion handler
             if (_completionHandler) {
                 _completionHandler();
                 _completionHandler = nil;
             }
         }
     }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //create background task regardless if task completed with error or not
    [self createBackgroundTask];
}

@end
