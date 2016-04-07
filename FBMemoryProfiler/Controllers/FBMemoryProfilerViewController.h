/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FBMemoryProfilerMovableViewController.h"

@class FBMemoryProfilerOptions;
@class FBObjectGraphConfiguration;

@protocol FBMemoryProfilerPresentationModeDelegate;

/**
 Main view controller that is visible in full mode. It's represented by draggable and stretchable window
 that has table view with all the allocations data.
 */
@interface FBMemoryProfilerViewController : UIViewController <FBMemoryProfilerMovableViewController>

/**
 @param options Options for memory profiler, see FBMemoryProfilerOptions
 @param retainCycleDetectorConfiguration configuration for object graph, defines filters, and options for detector
 */
- (nonnull instancetype)initWithOptions:(nonnull FBMemoryProfilerOptions *)options
       retainCycleDetectorConfiguration:(nullable FBObjectGraphConfiguration *)retainCycleDetectorConfiguration;

/**
 Delegate for presentation mode, it will be used on "Hide" action
 */
@property (nonatomic, weak, nullable) id<FBMemoryProfilerPresentationModeDelegate> presentationModeDelegate;
@property (nonatomic, copy, nonnull) FBMemoryProfilerOptions *profilerOptions;

@end
