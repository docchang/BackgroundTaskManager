//
//  Timer.m
//  Slice
//
//  Created by Lee Hasiuk on 10/31/12.
//  Copyright (c) 2012 Idealab. All rights reserved.
//

#import "Timer.h"

@interface Timer ()
{
    BOOL _repeats;
    NSTimer *_timer;
    void (^_block)();
}

@end

@implementation Timer

- (void)dealloc
{
    [self cancel];
}

- (id)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)())block
{
    if ((self = [super init]) != nil) {
        _repeats = repeats;
        _block = block;
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fire:) userInfo:nil repeats:repeats];
    }
    return self;
}

- (void)fire:(NSTimer *)timer
{
    _block();
    if (!_repeats) {
        _timer = nil;
        _block = nil;
    }
}

+ (Timer *)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)())block
{
    return [[Timer alloc] initWithInterval:interval repeats:repeats block:block];
}

- (void)cancel
{
    [_timer invalidate];
    _timer = nil;
    _block = nil;
}

@end
