/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FBMemoryProfilerPresenting;

@class FBObjectiveCGraphElement;

/**
 When we find retain cycles for given class, we will show this presenter. It's a table view. Every row will represent
 retain cycle and, when selected, will present it in details using FBSingleRetainCycleViewController
 */
@interface FBRetainCyclePresenter : NSObject

/**
 @param delegate Delegate that can present view controllers inside FBMemoryProfiler
 */
- (nonnull instancetype)initWithDelegate:(nullable id<FBMemoryProfilerPresenting>)delegate;

/**
 When found, retain cycles can be presented, they will be delivered to presenter using this method and then
 showed on top of FBMemoryProfiler
 */
- (void)presentRetainCycles:(nonnull NSSet<NSArray<FBObjectiveCGraphElement *> *> *)retainCycles;

@end
