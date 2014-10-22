//
//  MultitaskingManager.m
//  S3UploadExerciser
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Lee Hasiuk. All rights reserved.
//

#import "MultitaskingManager.h"
#import "BackgroundTaskManager.h"
#import "AppDelegate.h"

#define kSessionID @"com.backgroundtaskmanager"

#define kDownloadSource @"https://v2.photokharma.io/heartbeat"

@interface MultitaskingManager () <NSURLSessionDelegate>
{
    NSURLRequest *_downloadRequest;
}
@end


@implementation MultitaskingManager

+ (instancetype)sharedInstance
{
    static MultitaskingManager *s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        s_sharedInstance = [[self alloc] init];
    });
    return s_sharedInstance;
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

- (void)startDownloading
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
    
    [self stopProcess];
}

- (void)startProcess
{
    DebugLog(@"Starting");
    //delegate start
    if (self.startBlock)
    {
        self.startBlock();
    }
    
    //start downloading
    [self startDownloading];
}

- (void)stopProcess
{
    DebugLog(@"stopping");
    
    //delegate stop
    if (self.stopBlock)
    {
        self.stopBlock();
    }
}

@end
