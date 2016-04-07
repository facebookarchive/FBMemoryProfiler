/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBRetainCycleAnalysisCache.h"

@implementation FBRetainCycleAnalysisCache
{
  NSMutableArray *_analysis;
}

- (instancetype)init
{
  if (self = [super init]) {
    _analysis = [NSMutableArray new];
  }

  return self;
}

- (FBRetainCycleStatus)statusInGeneration:(NSUInteger)generationIndex
                            forClassNamed:(NSString *)className
{
  if (_analysis.count <= generationIndex || (_analysis[generationIndex][className] == nil)) {
    return FBRetainCycleUnknown;
  }

  return (FBRetainCycleStatus)[_analysis[generationIndex][className] unsignedIntegerValue];
}

- (void)updateAnalysisStatus:(FBRetainCycleStatus)status
             forInGeneration:(NSUInteger)generationIndex
               forClassNamed:(NSString *)className
{
  // If first class in new generation, expand array
  while (_analysis.count <= generationIndex) {
    [_analysis addObject:[NSMutableDictionary new]];
  }

  [_analysis[generationIndex] setObject:@(status) forKey:className];
}

@end
