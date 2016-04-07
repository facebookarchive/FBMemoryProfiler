/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FBMemoryProfilerSectionHeaderDelegate;

/**
 Custom section view that adds some additional UI elements
 */
@interface FBMemoryProfilerGenerationsSectionHeaderView : UITableViewHeaderFooterView

/**
 Delegate to support header button actions
 */
@property (nonatomic, weak, nullable) id<FBMemoryProfilerSectionHeaderDelegate> delegate;

/**
 Is section expanded
 */
@property (nonatomic, assign) BOOL expanded;

/**
 What is the index of this section
 */
@property (nonatomic, assign) NSInteger index;

@end
