/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerWindow.h"

#import "FBMemoryProfiler.h"

@implementation FBMemoryProfilerWindow

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];

    /**
     Window level will determine how on top we want to appear in window hierarchy.
     We do not want to hide alerts, but we want to be pretty much above everything else.
     */
    self.windowLevel = UIWindowLevelStatusBar + 100;
  }

  return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  if ([_touchesDelegate window:self shouldReceiveTouchAtPoint:point]) {
    return [super pointInside:point withEvent:event];
  }

  return NO;
}

#if _INTERNAL_IMP_ENABLED

- (BOOL)_canAffectStatusBarAppearance
{
  return NO;
}

- (BOOL)_canBecomeKeyWindow
{
  return NO;
}

#endif // _INTERNAL_IMP_ENABLED

@end
