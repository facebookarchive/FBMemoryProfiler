/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FBMemoryProfilerWindowTouchesHandling.h"

/**
 Window that FBMemoryProfiler will reside in.
 */
@interface FBMemoryProfilerWindow : UIWindow

/**
 Whenever we receive a touch event, window needs to ask delegate if this event should be captured.
 */
@property (nonatomic, weak, nullable) id<FBMemoryProfilerWindowTouchesHandling> touchesDelegate;

@end
