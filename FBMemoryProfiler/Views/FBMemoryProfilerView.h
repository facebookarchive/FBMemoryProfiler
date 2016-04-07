/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FBMemoryProfilerTextField, FBMemoryProfilerSegmentedControl;

/**
 Main view that FBMemoryProfilerViewController will be using.
 */
@interface FBMemoryProfilerView : UIView

/**
 Table view, that data source will be on.
 */
@property (nonatomic, readonly, nullable) UITableView *tableView;

/**
 Text field to filter data by class name.
 */
@property (nonatomic, readonly, nullable) FBMemoryProfilerTextField *subwordFilter;

/**
 Segmented controller to pick ordering (alive objects, size, class name)
 */
@property (nonatomic, readonly, nullable) FBMemoryProfilerSegmentedControl *sortControl;

@property (nonatomic, readonly, nullable) UIButton *hideButton;
@property (nonatomic, readonly, nullable) UIButton *markGenerationButton;

- (void)setResidentMemory:(nullable NSString *)residentMemory;

@end
