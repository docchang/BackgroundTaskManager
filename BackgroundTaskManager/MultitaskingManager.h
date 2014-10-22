//
//  MultitaskingManager.h
//  S3UploadExerciser
//
//  Created by Dominic Chang on 10/21/14.
//  Copyright (c) 2014 Lee Hasiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultitaskingManager : NSObject

@property (nonatomic, strong) void_block_t startBlock;

@property (nonatomic, strong) void_block_t stopBlock;

+ (instancetype)sharedInstance;

- (NSURLSession *)backgroundURLSession;

- (void)startProcess;

- (void)stopProcess;

@end
