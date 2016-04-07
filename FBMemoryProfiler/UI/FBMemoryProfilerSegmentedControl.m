/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerSegmentedControl.h"

@implementation FBMemoryProfilerSegmentedControl

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSInteger currentSegment = self.selectedSegmentIndex;

  [super touchesEnded:touches withEvent:event];

  if (currentSegment == self.selectedSegmentIndex) {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

@end
