/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

//! Project version number for FBMemoryProfiler.
FOUNDATION_EXPORT double FBMemoryProfilerVersionNumber;

//! Project version string for FBMemoryProfiler.
FOUNDATION_EXPORT const unsigned char FBMemoryProfilerVersionString[];

#import <UIKit/UIKit.h>

#import "FBMemoryProfilerPluggable.h"
#import "FBMemoryProfilerPresentationModeDelegate.h"

#import <FBRetainCycleDetector/FBObjectGraphConfiguration.h>

/**
 This will protect some internal parts that could use dangerous paths like private API's.
 Memory Profiler should be safe to use even without them, it's just going to have missing features.
 */
#ifdef FB_MEMORY_TOOLS
#define _INTERNAL_IMP_ENABLED (FB_MEMORY_TOOLS)
#else
#define _INTERNAL_IMP_ENABLED DEBUG
#endif // FB_MEMORY_TOOLS

@protocol FBMemoryProfilerPluggable;

/**
 FBMemoryProfiler is a tool helping with memory profiling on iOS. It leverages FBAllocationTracker
 and FBRetainCycleDetector. It can track all NSObject subclasses allocations. You can scan every
 class' instances for retain cycles. It also supports generations similar to Instruments, so you
 can observe objects created in between given generation marks.
 */
@interface FBMemoryProfiler : NSObject <FBMemoryProfilerPresentationModeDelegate>

/**
 Designated initializer
 @param plugins Plugins can take up some behavior like cache cleaning when we are working with profiler.
 Check FBMemoryProfilerPluggable for details.
 @param retainCycleDetectorConfiguration Retain cycle detector will use this configuration to determine how it should
 walk on object graph, check FBObjectGraphConfiguration to see what options you can define.
 @see FBObjectGraphConfiguration
 */
- (nonnull instancetype)initWithPlugins:(nullable NSArray<id<FBMemoryProfilerPluggable>> *)plugins
       retainCycleDetectorConfiguration:(nullable FBObjectGraphConfiguration *)retainCycleDetectorConfiguration NS_DESIGNATED_INITIALIZER;

/**
 Enable Memory Profiler. It will show a button that after clicking will bring up the memory profiler.
 */
- (void)enable;

/**
 Disable Memory Profiler. The window will be destroyed.
 */
- (void)disable;

/**
 Presentation mode for FBMemoryProfiler. It currently supports three presentation modes.
 It can be a small floating button, that we can keep around, or a full window for actual
 profiling, or it can simply be disabled.
 */
@property (nonatomic, assign) FBMemoryProfilerPresentationMode presentationMode;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

@end
