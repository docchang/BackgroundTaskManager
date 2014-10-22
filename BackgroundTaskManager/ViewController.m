//
//  ViewController.m
//  BackgroundTaskManager
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Dominic Chang. All rights reserved.
//

#import "ViewController.h"
#import "BackgroundTaskManager.h"
#import "Timer.h"

@interface ViewController () {
    NSUInteger _counter;
    NSUInteger _localCounter;
}
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [BackgroundTaskManager beginBackgroundTaskWithLocalCounter:&_localCounter];
    
    [Timer timerWithInterval:1.0 repeats:YES block:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%lu", (unsigned long)_counter);
            self.counterLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_counter];
            _counter++;
        });
    }];
}

@end
