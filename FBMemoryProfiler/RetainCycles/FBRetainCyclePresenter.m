/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBRetainCyclePresenter.h"

#import "FBMemoryProfilerPresenting.h"
#import "FBSingleRetainCycleViewController.h"

#import <FBRetainCycleDetector/FBObjectiveCGraphElement.h>

static NSString *const FBRetainCycleDetectorIdentifier = @"retain_cycle_detector_identifier";
static NSString *const FBRetainCycleFromMemoryProfilerPerfEvent = @"retain_cycle_detector_memory_profiler_perf";

@interface FBRetainCyclePresenter () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FBRetainCyclePresenter
{
  NSArray<NSArray<FBObjectiveCGraphElement *> *> *_retainCycles;
  __weak id<FBMemoryProfilerPresenting> _delegate;

  UINavigationController *_resultsViewController;
}

- (instancetype)initWithDelegate:(id<FBMemoryProfilerPresenting>)delegate
{
  if (self = [super init]) {
    _delegate = delegate;
  }

  return self;
}

- (void)presentRetainCycles:(NSSet<NSArray<FBObjectiveCGraphElement *> *> *)retainCycles
{
  if (![_delegate memoryProfilerCanPresent]) {
    return;
  }

  _retainCycles = [retainCycles allObjects];

  UITableViewController *tableViewController = [UITableViewController new];
  tableViewController.tableView.delegate = self;
  tableViewController.tableView.dataSource = self;

  _resultsViewController = [[UINavigationController alloc] initWithRootViewController:tableViewController];

  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(_dismissTableViewController)];
  tableViewController.navigationItem.rightBarButtonItem = closeButton;
  tableViewController.title = @"Results";

  [_delegate memoryProfilerPresenter:self presentViewController:_resultsViewController];
}

- (void)_dismissTableViewController
{
  [_delegate memoryProfilerPresenter:self dismissViewController:_resultsViewController];
  _resultsViewController = nil;
  _retainCycles = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_retainCycles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FBRetainCycleDetectorIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:FBRetainCycleDetectorIdentifier];
  }

  NSArray<FBObjectiveCGraphElement *> *retainCycle = _retainCycles[indexPath.row];
  cell.textLabel.text = [retainCycle[0] classNameOrNull];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBSingleRetainCycleViewController *summary = [[FBSingleRetainCycleViewController alloc] initWithRetainCycle:_retainCycles[indexPath.row]];
  [_resultsViewController pushViewController:summary
                                    animated:YES];
}

@end
