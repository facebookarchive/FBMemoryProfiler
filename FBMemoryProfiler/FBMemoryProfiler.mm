/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfiler.h"

#import <FBAllocationTracker/FBAllocationTrackerManager.h>

#import "FBMemoryProfilerContainerViewController.h"
#import "FBMemoryProfilerFloatingButtonController.h"
#import "FBMemoryProfilerOptions.h"
#import "FBMemoryProfilerPluggable.h"
#import "FBMemoryProfilerViewController.h"
#import "FBMemoryProfilerWindow.h"
#import "FBMemoryProfilerWindowTouchesHandling.h"

static const NSUInteger kFBFloatingButtonSize = 52.0;
static const CGFloat KFBMemoryProfilerDesignatedHeight = 230;

@interface FBMemoryProfiler () <FBMemoryProfilerWindowTouchesHandling>

@property (nonatomic, strong) FBMemoryProfilerWindow *memoryProfilerWindow;

@end

@implementation FBMemoryProfiler
{
  FBMemoryProfilerViewController *_profilerViewController;
  FBMemoryProfilerFloatingButtonController *_floatingButtonController;

  FBMemoryProfilerContainerViewController *_containerViewController;

  FBMemoryProfilerOptions *_options;
  FBObjectGraphConfiguration *_retainCycleDetectorConfiguration;
}

- (instancetype)init
{
  return   [self initWithPlugins:nil
retainCycleDetectorConfiguration:nil];
}

- (instancetype)initWithPlugins:(NSArray<id<FBMemoryProfilerPluggable>> *)plugins
retainCycleDetectorConfiguration:(FBObjectGraphConfiguration *)retainCycleDetectorConfiguration
{
  if (self = [super init]) {
    _presentationMode = FBMemoryProfilerPresentationModeFullWindow;
    _options = [[FBMemoryProfilerOptions alloc] initWithSortingMode:FBMemoryProfilerSortByClass
                                                       sortingOrder:FBMemoryProfilerSortingOrderAscending
                                                            plugins:plugins];
    _retainCycleDetectorConfiguration = retainCycleDetectorConfiguration;
  }

  return self;
}

#pragma mark - Public

- (void)enable
{
  // Put Memory profiler in status bar but save window for future reference when showing on screen
  _enabled = YES;

  [[FBAllocationTrackerManager sharedManager] enableGenerations];

  _containerViewController = [FBMemoryProfilerContainerViewController new];

  _memoryProfilerWindow = [[FBMemoryProfilerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _memoryProfilerWindow.touchesDelegate = self;
  _memoryProfilerWindow.rootViewController = _containerViewController;
  _memoryProfilerWindow.hidden = NO;

  self.presentationMode = FBMemoryProfilerPresentationModeCondensed;

  [_options.plugins enumerateObjectsUsingBlock:^(id<FBMemoryProfilerPluggable> plugin,
                                                 NSUInteger idx,
                                                 BOOL *stop) {
    if ([plugin respondsToSelector:@selector(memoryProfilerDidEnable)]) {
      [plugin memoryProfilerDidEnable];
    }
  }];
}

- (void)disable
{
  [_options.plugins enumerateObjectsUsingBlock:^(id<FBMemoryProfilerPluggable> plugin,
                                                 NSUInteger idx,
                                                 BOOL *stop) {
    if ([plugin respondsToSelector:@selector(memoryProfilerDidDisable)]) {
      [plugin memoryProfilerDidDisable];
    }
  }];

  self.presentationMode = FBMemoryProfilerPresentationModeDisabled;
  _memoryProfilerWindow = nil;
  [[FBAllocationTrackerManager sharedManager] disableGenerations];
  _enabled = NO;
}

#pragma mark - Popover attaching

- (void)_instanceAttachToWindow
{
  if (_profilerViewController) {
    // Breaks cycle
    [_profilerViewController.view removeFromSuperview];
  }

  _profilerViewController = [[FBMemoryProfilerViewController alloc] initWithOptions:_options
                                                   retainCycleDetectorConfiguration:_retainCycleDetectorConfiguration];
  _profilerViewController.presentationModeDelegate = self;
  [_containerViewController presentViewController:_profilerViewController
                                         withSize:CGSizeMake(MAXFLOAT, KFBMemoryProfilerDesignatedHeight)];
}

- (void)_instanceDetachFromWindow
{
  // Backup options
  if (_profilerViewController) {
    _options = _profilerViewController.profilerOptions;
  }

  [_containerViewController dismissCurrentViewController];
  _profilerViewController = nil;
}

- (void)setPresentationMode:(FBMemoryProfilerPresentationMode)presentationMode
{
  if (_presentationMode != presentationMode) {
    switch (presentationMode) {
      case FBMemoryProfilerPresentationModeFullWindow:
        [self _hideFloatingButton];
        [self _instanceAttachToWindow];
        break;
      case FBMemoryProfilerPresentationModeCondensed:
        [self _instanceDetachFromWindow];
        [self _showFloatingButton];
        break;
      case FBMemoryProfilerPresentationModeDisabled:
        [self _hideFloatingButton];
        [self _instanceDetachFromWindow];
        break;
    }
  }

  _presentationMode = presentationMode;
}

#pragma mark - Floating button presentation

- (void)_showFloatingButton
{
  _floatingButtonController = [FBMemoryProfilerFloatingButtonController new];
  _floatingButtonController.presentationModeDelegate = self;

  [_containerViewController presentViewController:_floatingButtonController
                                         withSize:CGSizeMake(kFBFloatingButtonSize,
                                                             kFBFloatingButtonSize)];
}

- (void)_hideFloatingButton
{
  [_containerViewController dismissCurrentViewController];
  _floatingButtonController = nil;
}

#pragma mark - FBMemoryProfilerPresentationModeDelegate

- (void)presentationDelegateChangePresentationModeToMode:(FBMemoryProfilerPresentationMode)mode
{
  self.presentationMode = mode;
}

#pragma mark - FBMemoryProfilerWindowTouchesHandling

- (BOOL)window:(UIWindow *)window shouldReceiveTouchAtPoint:(CGPoint)point
{
  switch (_presentationMode) {
    case FBMemoryProfilerPresentationModeFullWindow:
      return CGRectContainsPoint(_profilerViewController.view.bounds,
                                 [_profilerViewController.view convertPoint:point
                                                                   fromView:window]);
    case FBMemoryProfilerPresentationModeCondensed:
      return CGRectContainsPoint(_floatingButtonController.view.bounds,
                                 [_floatingButtonController.view convertPoint:point
                                                                     fromView:window]);
    case FBMemoryProfilerPresentationModeDisabled:
      return NO;
  }
}

@end
