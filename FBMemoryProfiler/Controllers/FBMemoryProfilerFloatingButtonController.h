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

@protocol FBMemoryProfilerPresentationModeDelegate;

/**
 Floating button mode view controller. If current mode is condensed, this is the view controller that will
 own it. It represents a small button that can be dragged and dropped wherever, showing current resident memory.
 It will expand to full size profiler on tap.
 */
@interface FBMemoryProfilerFloatingButtonController : UIViewController <FBMemoryProfilerMovableViewController>

/**
 Delegate that can change presentation mode, will be used on tap.
 */
@property (nonatomic, weak, nullable) id<FBMemoryProfilerPresentationModeDelegate> presentationModeDelegate;

@end
