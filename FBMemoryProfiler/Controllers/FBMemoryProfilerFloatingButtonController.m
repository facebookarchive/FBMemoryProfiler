/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerFloatingButtonController.h"

#import "FBMemoryProfilerDeviceUtils.h"
#import "FBMemoryProfilerMathUtils.h"
#import "FBMemoryProfilerPresentationModeDelegate.h"

@implementation FBMemoryProfilerFloatingButtonController
{
  UIButton *_floatingButton;

  NSTimer *_timer;
  NSByteCountFormatter *_formatter;
}

- (instancetype)init
{
  if (self = [super init]) {
    _formatter = [NSByteCountFormatter new];
  }
  return self;
}

- (void)loadView
{
  _floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];

  self.view = _floatingButton;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _floatingButton.backgroundColor = [UIColor lightGrayColor];
  _floatingButton.titleLabel.font = [UIFont systemFontOfSize:11];
  _floatingButton.titleLabel.textColor = [UIColor whiteColor];
  _floatingButton.layer.borderWidth = 1.0;
  _floatingButton.layer.borderColor = [UIColor grayColor].CGColor;
  _floatingButton.alpha = 0.8;
  [_floatingButton setTitle:@"IMP" forState:UIControlStateNormal];

  [_floatingButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];

  [self _update];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  _timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                            target:self
                                          selector:@selector(_update)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];

  [_timer invalidate];
  _timer = nil;
}

- (void)_update
{
  [_floatingButton setTitle:[_formatter stringFromByteCount:FBMemoryProfilerResidentMemoryInBytes()] forState:UIControlStateNormal];
}

- (void)buttonTapped
{
  [self.presentationModeDelegate presentationDelegateChangePresentationModeToMode:FBMemoryProfilerPresentationModeFullWindow];
}

#pragma mark FBMemoryProfilerMovableViewController

- (void)containerWillMove:(UIViewController *)container
{
  // No extra behavior
}

- (BOOL)shouldStretchInMovableContainer
{
  return YES;
}

- (CGFloat)minimumHeightInMovableContainer
{
  return 0;
}

@end
