//
//  Timer.h
//  Slice
//
//  Created by Lee Hasiuk on 10/31/12.
//  Copyright (c) 2012 Idealab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject

+ (Timer *)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)())block;

- (void)cancel;

@end
