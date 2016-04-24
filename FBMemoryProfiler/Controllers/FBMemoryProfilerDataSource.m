/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerDataSource.h"

#import <FBAllocationTracker/FBAllocationTrackerManager.h>
#import <FBAllocationTracker/FBAllocationTrackerSummary.h>

#import "FBRetainCycleAnalysisCache.h"

static NSString *const kFBMemoryProfilerCellIdentifier = @"kFBMemoryProfilerCellIdentifier";

static UIColor *FBMemoryProfilerPaleGreenColor() {
  return [UIColor colorWithRed:198/255.0 green:1.0 blue:197/255.0 alpha:1.0];
}

static UIColor *FBMemoryProfilerPaleRedColor() {
  return [UIColor colorWithRed:1.0 green:196/255.0 blue:197/255.0 alpha:1.0];
}

@implementation FBMemoryProfilerDataSource
{
  NSArray *_data;
  NSArray *_filtered;

  // If section should be collapsed it's index will be in that set
  NSMutableSet *_expandedSection;

  NSByteCountFormatter *_byteCountFormatter;

  UIFont *_font;
  FBRetainCycleAnalysisCache *_analysisCache;
}

- (instancetype)initWithAnalysisCache:(FBRetainCycleAnalysisCache *)analysisCache
{
  if (self = [super init]) {
    _font = [UIFont systemFontOfSize:10.0];
    _expandedSection = [NSMutableSet new];
    _byteCountFormatter = [NSByteCountFormatter new];
    _analysisCache = analysisCache;
  }
  return self;
}

- (void)setExpanded:(BOOL)expanded
         forSection:(NSInteger)section
{
  if (expanded) {
    [_expandedSection addObject:@(section)];
  } else {
    [_expandedSection removeObject:@(section)];
  }
}

- (BOOL)isSectionExpanded:(NSInteger)section
{
  return [_expandedSection containsObject:@(section)];
}

- (void)forceDataReload
{
  if (![[FBAllocationTrackerManager sharedManager] isAllocationTrackerEnabled]) {
    return;
  }

  _data = [[FBAllocationTrackerManager sharedManager] currentSummaryForGenerations];
  [self refilter];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [_filtered count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (![self isSectionExpanded:section]) {
    return 0;
  }
  return [_filtered[section] count];
}

- (UIColor *)_colorForAnalysisStatus:(FBRetainCycleStatus)status
{
  switch (status) {
    case FBRetainCycleUnknown:
      return [UIColor whiteColor];
    case FBRetainCycleNotPresent:
      return FBMemoryProfilerPaleGreenColor();
    case FBRetainCyclePresent:
      return FBMemoryProfilerPaleRedColor();
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFBMemoryProfilerCellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kFBMemoryProfilerCellIdentifier];
    cell.detailTextLabel.font = _font;
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = _font;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  FBAllocationTrackerSummary *row = _filtered[indexPath.section][indexPath.row];

  NSInteger alive = row.aliveObjects;
  NSInteger byteCount = alive * row.instanceSize;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld (%@)",
                               (long)alive,
                               [_byteCountFormatter stringFromByteCount:byteCount]];
  cell.textLabel.text = row.className;
  cell.backgroundColor = [self _colorForAnalysisStatus:[_analysisCache statusInGeneration:indexPath.section
                                                                            forClassNamed:row.className]];

  return cell;
}

- (NSString *)summaryForSection:(NSInteger)section
{
  NSInteger summary = 0;
  NSInteger bytes = 0;
  
  for (FBAllocationTrackerSummary *entry in _data[section]) {
    NSInteger alive = entry.aliveObjects;
    summary += alive;
    bytes += (alive * entry.instanceSize);
  }

  return [NSString stringWithFormat:@"%ld (%@)",
          (long)summary,
          [_byteCountFormatter stringFromByteCount:bytes]];
}

- (void)setClassFilter:(NSString *)classFilter
{
  _classFilter = [classFilter lowercaseString];

  if (_classFilter.length == 0) {
    _classFilter = nil;
  }

  [self refilter];
}

- (void)setSortingMode:(FBMemoryProfilerSortingMode)sortingMode
{
  BOOL sortingModeChanged = sortingMode != _sortingMode;
  _sortingMode = sortingMode;

  if (sortingModeChanged) {
    [self refilter];
  }
}

- (void)setSortingOrder:(FBMemoryProfilerSortingOrder)sortingOrder
{
  BOOL sortingOrderChanged = sortingOrder != _sortingOrder;
  _sortingOrder = sortingOrder;

  if (sortingOrderChanged) {
    [self refilter];
  }
}

- (NSArray *)_refilterSectionAtIndex:(NSInteger)index
{
  NSArray *filtered = [_data[index] filteredArrayUsingPredicate:
                       [NSPredicate predicateWithBlock:^BOOL(FBAllocationTrackerSummary *entry, NSDictionary *bindings) {
    NSString *className = entry.className.lowercaseString;
    if (_classFilter && [className rangeOfString:_classFilter].location == NSNotFound) {
      return NO;
    }

    if (entry.aliveObjects > 0 && entry.className) {
      return YES;
    }

    return NO;
  }]];

  switch (_sortingMode) {
    case FBMemoryProfilerSortByClass:
      filtered = [self _sortArray:filtered withKey:@"className"];
      break;
    case FBMemoryProfilerSortByAlive:
      filtered = [self _sortArray:filtered withKey:@"aliveObjects"];
      break;
    case FBMemoryProfilerSortBySize:
      filtered = [filtered sortedArrayUsingComparator:^NSComparisonResult(FBAllocationTrackerSummary *obj1,
                                                                          FBAllocationTrackerSummary *obj2) {
        NSUInteger size1 = obj1.aliveObjects * obj1.instanceSize;
        NSUInteger size2 = obj2.aliveObjects * obj2.instanceSize;
        if (size1 > size2) {
          return (_sortingOrder == FBMemoryProfilerSortingOrderAscending) ? NSOrderedDescending : NSOrderedAscending;
        } else if (size2 > size1) {
          return (_sortingOrder == FBMemoryProfilerSortingOrderAscending) ? NSOrderedAscending : NSOrderedDescending;
        } else {
          return NSOrderedSame;
        }
      }];
      break;
  }

  return filtered;
}

- (NSArray *)_sortArray:(NSArray *)array withKey:(NSString *)key
{
  BOOL sortAscending = _sortingOrder == FBMemoryProfilerSortingOrderAscending;
  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key
                                                         ascending:sortAscending];
  return [array sortedArrayUsingDescriptors:@[sort]];
}

- (void)refilter
{
  NSMutableArray *filtered = [NSMutableArray array];
  for (NSInteger i = 0; i < _data.count; ++i) {
    [filtered addObject:[self _refilterSectionAtIndex:i]];
  }

  _filtered = filtered;
}

- (NSArray<NSString *> *)classNamesForSection:(NSInteger)section
{
  NSMutableArray *array = [NSMutableArray new];

  for (FBAllocationTrackerSummary *object in _filtered[section]) {
    [array addObject:object.className];
  }

  return array;
}

@end
