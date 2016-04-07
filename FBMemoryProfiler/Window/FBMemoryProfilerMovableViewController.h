/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

/**
 View Controller put into FBMemoryProfilerContainerViewController should implement this protocol.
 It's what container will use to interact with the view controller, inform him when it's being
 moved, etc.
 */

@protocol FBMemoryProfilerMovableViewController <NSObject>

/**
 Container will move view controller (either by pan or pinch).
 */
- (void)containerWillMove:(nonnull UIViewController *)container;

/**
 Should view should stretch on pinch?
 */
- (BOOL)shouldStretchInMovableContainer;

/**
 @return minimum height that view controllers must have
 */
- (CGFloat)minimumHeightInMovableContainer;

@end
