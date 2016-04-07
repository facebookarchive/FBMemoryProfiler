/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FBRetainCycleStatus) {
  FBRetainCyclePresent,
  FBRetainCycleNotPresent,
  FBRetainCycleUnknown
};

/**
 FBRetainCycleAnalysisCache can answer if we have ran retain cycle detection for given class in given
 generation and what was it's result.
 */
@interface FBRetainCycleAnalysisCache : NSObject

/**
 What is the status of retain cycle detection for class in given generation
 
 @param generationIndex generation to check
 @param className class to check
 */
- (FBRetainCycleStatus)statusInGeneration:(NSUInteger)generationIndex
                            forClassNamed:(nullable NSString *)className;

/**
 Sets new state for given class in given generation
 
 @param status new status to set
 @param generationIndex generation to update
 @param className class to update
 */
- (void)updateAnalysisStatus:(FBRetainCycleStatus)status
             forInGeneration:(NSUInteger)generationIndex
               forClassNamed:(nullable NSString *)className;

@end
