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
 Example of FBMemoryProfiler plugin that will clear NSURLCache every time
 we hit mark generation.
 */

@interface CacheCleanerPlugin : NSObject <FBMemoryProfilerPluggable>

@end
