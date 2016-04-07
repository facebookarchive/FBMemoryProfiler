/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <FBMemoryProfiler/FBMemoryProfiler.h>

/**
 Example of FBMemoryProfiler plugin that will NSLog all retain cycles found
 within FBMemoryProfiler. This could, for instance, send it somewhere to the backend.
 */

@interface RetainCycleLoggerPlugin : NSObject <FBMemoryProfilerPluggable>

@end
