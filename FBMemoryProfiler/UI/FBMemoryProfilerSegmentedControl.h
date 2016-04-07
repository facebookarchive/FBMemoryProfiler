/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

/**
 FBMemoryProfilerSegmentedControl will behave as UISegmentedControl with small difference:

 It will call up valueChanged target-action when someone will tap on already selected
 segment.
 */
@interface FBMemoryProfilerSegmentedControl : UISegmentedControl

@end
