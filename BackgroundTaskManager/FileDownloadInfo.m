//
//  FileDownloadInfo.m
//  BGTransferDemo
//
//  Created by Gabriel Theodoropoulos on 25/3/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

- (id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source
{
    if (self == [super init])
    {
        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    return self;
}

- (void)reset
{
    self.downloadProgress = 0.0;
    self.isDownloading = NO;
    self.downloadComplete = NO;
    self.taskIdentifier = -1;
    self.taskResumeData = nil;
}

- (BOOL)taskCompleted
{
    DebugLog(@"Received:%lld Expected:%lld", self.downloadTask.countOfBytesReceived, self.downloadTask.countOfBytesExpectedToReceive);
    return (self.downloadTask.countOfBytesReceived == self.downloadTask.countOfBytesExpectedToReceive);
}

@end
