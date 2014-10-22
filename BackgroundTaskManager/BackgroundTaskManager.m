//
//  BackgroundTaskManager.m
//  PhotoKharma
//
//  Created by Lee Hasiuk on 10/17/14.
//  Copyright (c) 2014 Idealab. All rights reserved.
//

#import "BackgroundTaskManager.h"
#import "Timer.h"
#import "MultitaskingManager.h"

#define kWatchdogInterval 20

#define kMinBackgroundTimeRemaining 60

@interface BackgroundTaskManager ()
{
    NSUInteger _count;
    UIBackgroundTaskIdentifier _bgTaskId;
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
        MultitaskingManager *multiManager = [MultitaskingManager sharedInstance];
        [multiManager setStartBlock:nil];
        [multiManager setStopBlock:^
         {
             [self createBackgroundTask];
         }];
        [multiManager startProcess];
        
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

@end
