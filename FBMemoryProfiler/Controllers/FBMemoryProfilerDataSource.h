/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FBMemoryProfilerSortingMode) {
  FBMemoryProfilerSortByClass,
  FBMemoryProfilerSortByAlive,
  FBMemoryProfilerSortBySize,
};

typedef NS_ENUM(NSUInteger, FBMemoryProfilerSortingOrder) {
  FBMemoryProfilerSortingOrderAscending,
  FBMemoryProfilerSortingOrderDescending,
};

@class FBRetainCycleAnalysisCache;

/**
 FBMemoryProfilerDataSource is responsible for gathering data about allocations from
 FBAllocationTracker. It supports few ways of filtering data source and ordering them.
 */
@interface FBMemoryProfilerDataSource : NSObject <UITableViewDataSource>

/**
 classFilter is a string representing part of class name, used to filter data by class name
 */
@property (nonatomic, copy, nullable) NSString *classFilter;

/**
 What mode is used to sort data in table view? Check FBMemoryProfilerSortingMode
 */
@property (nonatomic, assign) FBMemoryProfilerSortingMode sortingMode;

/**
 Is data in ascending or descending order?
 */
@property (nonatomic, assign) FBMemoryProfilerSortingOrder sortingOrder;

/**
 @param analysisCache is a cache of results memory profiler gathered during retain cycle detection. Rows which objects
 were checked for retain cycles will be marked with red or green depending on wether they were cycled or no
 */
- (nonnull instancetype)initWithAnalysisCache:(nullable FBRetainCycleAnalysisCache *)analysisCache;

/**
 In Generations mode full section can be expanded or collapsed to make it easier to browse
 */
- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section;

/**
 Checks if current section is expanded
 */
- (BOOL)isSectionExpanded:(NSInteger)section;

/**
 Summary for section will be a string that will appear next to generation name.
 */
- (nonnull NSString *)summaryForSection:(NSInteger)section;

/**
 If we need new data, because we for example marked new generation, we can force refresh.
 */
- (void)forceDataReload;

/**
 Takes visible cells and returns an array of class names that those cells represent.
 */
- (nonnull NSArray<NSString *> *)classNamesForSection:(NSInteger)section;

@end
