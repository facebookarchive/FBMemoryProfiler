/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBSingleRetainCycleViewController.h"

#import <FBRetainCycleDetector/FBObjectiveCGraphElement.h>

static NSString *const FBRetainCycleSingleLeakIdentifier = @"retain_cycle_single_leak_identifier";

@implementation FBSingleRetainCycleViewController
{
  NSArray<FBObjectiveCGraphElement *> *_retainCycle;
}

- (instancetype)initWithRetainCycle:(NSArray<FBObjectiveCGraphElement *> *)retainCycle
{
  if (self = [super init]) {
    _retainCycle = [retainCycle copy];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.userInteractionEnabled = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_retainCycle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FBRetainCycleSingleLeakIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:FBRetainCycleSingleLeakIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
  }

  cell.textLabel.text = [_retainCycle[indexPath.row] description];

  return cell;
}

@end
