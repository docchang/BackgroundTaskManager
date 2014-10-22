//
//  MultitaskingManager.m
//  S3UploadExerciser
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Lee Hasiuk. All rights reserved.
//

#import "MultitaskingManager.h"

#import "BackgroundTaskManager.h"
#import "FileDownloadInfo.h"
#import "AppDelegate.h"


#define kSessionID @"com.backgroundtaskmanager"

@interface MultitaskingManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
{
    NSUInteger _localCounter;
    FileDownloadInfo *_fileDownloadInfo;
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

- (FileDownloadInfo *)fileDownloadInfo
{
    if (_fileDownloadInfo == nil)
    {
        _fileDownloadInfo = [[FileDownloadInfo alloc] initWithFileTitle:@"Empty" andDownloadSource:@"http://dev.emplementation.com/empty.txt"];
    }
    return _fileDownloadInfo;
}

- (void)startDownloading:(FileDownloadInfo *)fdi
{
    DebugLog(@"startDownloading:%@", fdi);

    [fdi reset];
    
    // If the taskIdentifier property of the fdi object has value -1, then create a new task
    // providing the appropriate URL as the download source.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fdi.downloadSource]];
    fdi.downloadTask = [[self backgroundURLSession] downloadTaskWithRequest:request];
    
    // Keep the new task identifier.
    fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
    
    // Start the task.
    [fdi.downloadTask resume];
    
    fdi.isDownloading = YES;
}

#pragma mark - NSURLSession Delegate method implementation

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    DebugMethod;
    // Check if all download tasks have been finished.
    NSURLSession *backgroundSession = [self backgroundURLSession];
    [backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks)
    {
        if ([downloadTasks count] == 0)
        {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate callCompletionHandlerForSession:kSessionID];
        }
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    DebugLog(@"Download success:%@", self.fileDownloadInfo.fileTitle);
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

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown)
    {
        NSLog(@"Unknown transfer size");
    }
    else
    {
        FileDownloadInfo *fdi = self.fileDownloadInfo;
        if (fdi.taskIdentifier != downloadTask.taskIdentifier)
        {
            DebugLog(@"FileDownloadInfo not found by taskID:%lu", (unsigned long)downloadTask.taskIdentifier);
            return;
        }
        fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        DebugLog(@"downloading progress:%f", fdi.downloadProgress);
    }
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
    [self startDownloading:self.fileDownloadInfo];
}

- (void)stopProcess
{
    DebugLog(@"stopping");
    
    //reset fileDownloadInfo
    [self.fileDownloadInfo reset];
    
    //delegate stop
    if (self.stopBlock)
    {
        self.stopBlock();
    }
}

@end
