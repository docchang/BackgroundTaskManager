//
//  Common.h
//  S3UploadExerciser
//
//  Created by Dominic Chang on 10/20/14.
//  Copyright (c) 2014 Lee Hasiuk. All rights reserved.
//

#ifndef S3UploadExerciser_Common_h
#define S3UploadExerciser_Common_h


#ifdef DEBUG
    #define DebugLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define DebugLog(format, ...)
#endif

#define DebugMethod DebugLog(@"%@", NSStringFromSelector(_cmd))

#define DebugObj(obj) DebugLog(@"%s:%@", #obj, obj)

typedef void (^void_block_t)(void);



#endif
