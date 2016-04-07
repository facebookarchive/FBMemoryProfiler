/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerOptions.h"

@implementation FBMemoryProfilerOptions

- (instancetype)initWithSortingMode:(FBMemoryProfilerSortingMode)sortingMode
                       sortingOrder:(FBMemoryProfilerSortingOrder)sortingOrder
                            plugins:(NSArray<id<FBMemoryProfilerPluggable>> *)plugins
{
  if ((self = [super init])) {
    _sortingMode = sortingMode;
    _sortingOrder = sortingOrder;
    _plugins = [plugins copy];
  }

  return self;
}

@end
