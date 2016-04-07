/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 FBMemoryProfilerPresenting

 Protocol implemented by FBMemoryProfiler part that is responsible for UI.
 */

@protocol FBMemoryProfilerPresenting <NSObject>

/**
 Custom presentation in memory profiler's container
 */
- (void)memoryProfilerPresenter:(nonnull id)presenter
          presentViewController:(nonnull UIViewController *)viewController;

- (void)memoryProfilerPresenter:(nonnull id)presenter
          dismissViewController:(nonnull UIViewController *)viewController;

- (BOOL)memoryProfilerCanPresent;

@end
