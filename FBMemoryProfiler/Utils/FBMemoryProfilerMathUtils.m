/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerMathUtils.h"

#import <tgmath.h>

#import <UIKit/UIKit.h>

CGFloat FBMemoryProfilerRoundPixelValue(CGFloat value) {
  CGFloat scale = [[UIScreen mainScreen] scale];
  return roundf(value * scale) / scale;
}
