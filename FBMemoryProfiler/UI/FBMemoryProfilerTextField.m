/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerTextField.h"

@implementation FBMemoryProfilerTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
  return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
  return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, _edgeInsets)];
}

@end
