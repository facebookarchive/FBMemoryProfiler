/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FBMemoryProfilerPresenting.h"

/**
 FBMemoryProfilerPluggable describes plugin for memory profiler. Whenever we want to support
 additional behavior for memory profiler such as clearing caches on generation mark, or
 logging retain cycles to backend, we can create a plugin and attach it to memory profiler.
 */
@protocol FBMemoryProfilerPluggable <NSObject>

@optional

/**
 Lifecycle events, when Memory profiler is enabled/disabled
 */
- (void)memoryProfilerDidEnable;
- (void)memoryProfilerDidDisable;

/**
 When memory profiler finds retain cycles plugins can subscribe to get them.
 */
- (void)memoryProfilerDidFindRetainCycles:(nonnull NSSet *)retainCycles;

/**
 If you want to do additional cleanup after marking new generations.
 */
- (void)memoryProfilerDidMarkNewGeneration;

@end
