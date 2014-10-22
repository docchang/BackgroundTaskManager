//
//  BackgroundTaskManager.h
//  PhotoKharma
//
//  Created by Lee Hasiuk on 10/17/14.
//  Copyright (c) 2014 Idealab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundTaskManager : NSObject

+ (void)beginBackgroundTaskWithLocalCounter:(NSUInteger *)localCounter;

+ (void)endBackgroundTaskWithLocalCounter:(NSUInteger *)localCounter;

@end
