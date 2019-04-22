/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerViewController.h"

#import <FBAllocationTracker/FBAllocationTrackerManager.h>

#import "FBMemoryProfilerDataSource.h"
#import "FBMemoryProfilerDeviceUtils.h"
#import "FBMemoryProfilerGenerationsSectionHeaderView.h"
#import "FBMemoryProfilerMathUtils.h"
#import "FBMemoryProfilerOptions.h"
#import "FBMemoryProfilerPluggable.h"
#import "FBMemoryProfilerPresentationModeDelegate.h"
#import "FBMemoryProfilerPresenting.h"
#import "FBMemoryProfilerSectionHeaderDelegate.h"
#import "FBMemoryProfilerSegmentedControl.h"
#import "FBMemoryProfilerTextField.h"
#import "FBMemoryProfilerView.h"
#import "FBRetainCycleAnalysisCache.h"
#import "FBRetainCyclePresenter.h"

#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

static const CGFloat kFBMemoryProfilerRefreshIntervalInSeconds = 3.0;

static NSString *const kFBMemoryProfilerSectionHeaderIdentifier = @"kFBMemoryProfilerSectionHeaderIdentifier";

@interface FBMemoryProfilerViewController () <
UITableViewDelegate,
UITextFieldDelegate,
FBMemoryProfilerSectionHeaderDelegate,
FBMemoryProfilerPresenting>
@end

@implementation FBMemoryProfilerViewController
{
  FBMemoryProfilerView *_profilerView;
  FBMemoryProfilerDataSource *_dataSource;

  NSTimer *_timer;
  NSByteCountFormatter *_byteCountFormatter;

  UITapGestureRecognizer *_tapGestureRecognizer;

  UIViewController *_currentlyPresentedViewController;
  FBRetainCyclePresenter *_retainCyclePresenter;
  FBRetainCycleAnalysisCache *_analysisCache;
  FBObjectGraphConfiguration *_retainCycleDetectorConfiguration;
}

- (instancetype)initWithOptions:(FBMemoryProfilerOptions *)options
retainCycleDetectorConfiguration:(FBObjectGraphConfiguration *)retainCycleDetectorConfiguration
{
  if (self = [super init]) {
    _analysisCache = [FBRetainCycleAnalysisCache new];
    _dataSource = [[FBMemoryProfilerDataSource alloc] initWithAnalysisCache:_analysisCache];
    _byteCountFormatter = [NSByteCountFormatter new];

    self.profilerOptions = options;
    _retainCyclePresenter = [[FBRetainCyclePresenter alloc] initWithDelegate:self];
    _retainCycleDetectorConfiguration = retainCycleDetectorConfiguration;
  }

  return self;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  _timer = [NSTimer scheduledTimerWithTimeInterval:kFBMemoryProfilerRefreshIntervalInSeconds
                                            target:self
                                          selector:@selector(_loadDataFromTimer:)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];

  [_timer invalidate];
}

- (void)loadView
{
  _profilerView = [FBMemoryProfilerView new];
  self.view = _profilerView;

  _profilerView.tableView.delegate = self;
  _profilerView.tableView.dataSource = _dataSource;
  _profilerView.tableView.allowsSelection = YES;

  _profilerView.subwordFilter.delegate = self;

  [_profilerView.sortControl addTarget:self action:@selector(_sortControlValueChanged) forControlEvents:UIControlEventValueChanged];

  NSInteger segmentSelected = 0;
  if (_profilerOptions.sortingMode == FBMemoryProfilerSortByAlive) {
    segmentSelected = 1;
  }

  _profilerView.sortControl.selectedSegmentIndex = segmentSelected;


  [_profilerView.hideButton addTarget:self action:@selector(_hideProfiler) forControlEvents:UIControlEventTouchUpInside];
  [_profilerView.markGenerationButton addTarget:self action:@selector(_markGeneration) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_hideProfiler
{
  [_presentationModeDelegate presentationDelegateChangePresentationModeToMode:FBMemoryProfilerPresentationModeCondensed];
}

- (void)_sortControlValueChanged
{
  FBMemoryProfilerSortingMode mode = (FBMemoryProfilerSortingMode)_profilerView.sortControl.selectedSegmentIndex;

  if (mode != _profilerOptions.sortingMode) {
    self.profilerOptions = [[FBMemoryProfilerOptions alloc] initWithSortingMode:mode
                                                                   sortingOrder:_profilerOptions.sortingOrder
                                                                        plugins:_profilerOptions.plugins];
  } else {
    // Mode was the same, we are changing the ordering
    FBMemoryProfilerSortingOrder order =
      (_profilerOptions.sortingOrder == FBMemoryProfilerSortingOrderAscending) ?
      FBMemoryProfilerSortingOrderDescending :
      FBMemoryProfilerSortingOrderAscending;
    self.profilerOptions = [[FBMemoryProfilerOptions alloc] initWithSortingMode:_profilerOptions.sortingMode
                                                                   sortingOrder:order
                                                                        plugins:_profilerOptions.plugins];
  }
}

- (void)_markGeneration
{
  [[FBAllocationTrackerManager sharedManager] markGeneration];

  for (id<FBMemoryProfilerPluggable> plugin in _profilerOptions.plugins) {
    if ([plugin respondsToSelector:@selector(memoryProfilerDidMarkNewGeneration)]) {
      [plugin memoryProfilerDidMarkNewGeneration];
    }
  }

  [self _loadData];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.view.layer.borderWidth = 2.0f;
  self.view.userInteractionEnabled = YES;
  [self setupTapHandler];

  [_profilerView.subwordFilter addTarget:self
                                  action:@selector(_textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];

  [self _loadData];
  [self _update];
}

- (void)dealloc
{
  [_tapGestureRecognizer removeTarget:self action:NULL];
}

- (void)_loadDataFromTimer:(NSTimer *)timer
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self _loadData];
  });
}

- (void)_loadData
{
  [_dataSource forceDataReload];
  [self _updateProfilerView];
}

- (void)setupTapHandler
{
  _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tap:)];

  _tapGestureRecognizer.numberOfTapsRequired = 1;
  _tapGestureRecognizer.cancelsTouchesInView = NO;
  [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)_tap:(UITapGestureRecognizer *)gestureRecognizer
{
  [self _hideKeyboardIfPresent];
}

#pragma mark - Subword Filter related

- (void)_hideKeyboardIfPresent
{
  [_profilerView.subwordFilter resignFirstResponder];
}

- (void)_textFieldDidChange:(FBMemoryProfilerTextField *)textField
{
  NSString *currentFilter = textField.text;
  _dataSource.classFilter = currentFilter;
  [self _updateProfilerView];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 16.0;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 24.0;
}

- (UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  FBMemoryProfilerGenerationsSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kFBMemoryProfilerSectionHeaderIdentifier];

  if (!headerView) {
    headerView = [[FBMemoryProfilerGenerationsSectionHeaderView alloc] initWithReuseIdentifier:kFBMemoryProfilerSectionHeaderIdentifier];
  }

  headerView.expanded = [_dataSource isSectionExpanded:section];
  headerView.delegate = self;
  headerView.index = section;
  headerView.textLabel.text = [NSString stringWithFormat:@"Gen %ld - %@",
                               (long)(section + 1),
                               [_dataSource summaryForSection:section]];

  return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Retain cycle detection kicks in
  NSString *className = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
  NSInteger generationIndex = indexPath.section;

  [self _findRetainCyclesForClassesNamed:@[className]
                            inGeneration:generationIndex
                          presentDetails:YES];
}

- (void)_findRetainCyclesForClassesNamed:(NSArray<NSString *> *)classesNamed
                            inGeneration:(NSUInteger)generationIndex
                          presentDetails:(BOOL)presentDetails
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    for (NSString *className in classesNamed) {
      Class aCls = NSClassFromString(className);
      NSArray *objects = [[FBAllocationTrackerManager sharedManager] instancesForClass:aCls
                                                                          inGeneration:generationIndex];
      FBObjectGraphConfiguration *configuration = _retainCycleDetectorConfiguration ?: [FBObjectGraphConfiguration new];
      FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
      
      for (id object in objects) {
        [detector addCandidate:object];
      }

      NSSet<NSArray<FBObjectiveCGraphElement *> *> *retainCycles =
      [detector findRetainCyclesWithMaxCycleLength:8];

      for (id<FBMemoryProfilerPluggable> plugin in _profilerOptions.plugins) {
        if ([plugin respondsToSelector:@selector(memoryProfilerDidFindRetainCycles:)]) {
          [plugin memoryProfilerDidFindRetainCycles:retainCycles];
        }
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        if ([retainCycles count] > 0) {
          // We've got a leak
          [_analysisCache updateAnalysisStatus:FBRetainCyclePresent
                               forInGeneration:generationIndex
                                 forClassNamed:className];
          if (presentDetails) {
            [_retainCyclePresenter presentRetainCycles:retainCycles];
          }
        } else {
          [_analysisCache updateAnalysisStatus:FBRetainCycleNotPresent
                               forInGeneration:generationIndex
                                 forClassNamed:className];
        }
        [_profilerView.tableView reloadData];
      });
    }
  });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}

#pragma mark - FBMemoryProfilerPresenting

- (void)memoryProfilerPresenter:(id)presenter presentViewController:(UIViewController *)viewController
{
  if (![self memoryProfilerCanPresent]) {
    return;
  }

  _currentlyPresentedViewController = viewController;
  [self addChildViewController:viewController];
  viewController.view.frame = self.view.bounds;
  [self.view addSubview:viewController.view];
  [viewController didMoveToParentViewController:self];
}

- (void)memoryProfilerPresenter:(id)presenter dismissViewController:(UIViewController *)viewController
{
  [viewController willMoveToParentViewController:nil];
  [viewController.view removeFromSuperview];
  [viewController removeFromParentViewController];
  _currentlyPresentedViewController = nil;
}

- (BOOL)memoryProfilerCanPresent
{
  return (_currentlyPresentedViewController == nil);
}

#pragma mark - Options

- (void)setProfilerOptions:(FBMemoryProfilerOptions *)profilerOptions
{
  if ([_profilerOptions isEqual:profilerOptions]) {
    return;
  }

  _profilerOptions = profilerOptions;

  [self _update];
}

- (void)_update
{
  _dataSource.sortingMode = _profilerOptions.sortingMode;
  _dataSource.sortingOrder = _profilerOptions.sortingOrder;

  [self _updateProfilerView];
}

- (void)_updateProfilerView
{
  [_profilerView setResidentMemory:[_byteCountFormatter stringFromByteCount:FBMemoryProfilerResidentMemoryInBytes()]];
  [_profilerView.tableView reloadData];
}

#pragma mark - FBMemoryProfilerSectionHeaderProtocol

- (void)sectionHeaderRequestedExpandCollapseAction:(FBMemoryProfilerGenerationsSectionHeaderView *)sectionHeader
{
  sectionHeader.expanded = !sectionHeader.expanded;

  [_dataSource setExpanded:sectionHeader.expanded
                forSection:sectionHeader.index];
  [_profilerView.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionHeader.index] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)sectionHeaderRequestedRetainCycleDetection:(FBMemoryProfilerGenerationsSectionHeaderView *)sectionHeader
{
  NSArray<NSString *> *classNames = [_dataSource classNamesForSection:sectionHeader.index];

  [self _findRetainCyclesForClassesNamed:classNames
                            inGeneration:sectionHeader.index
                          presentDetails:NO];
}

#pragma mark - FBMemoryProfilerMovableViewController

- (void)containerWillMove:(UIViewController *)container
{
  [self _hideKeyboardIfPresent];
}

- (BOOL)shouldStretchInMovableContainer
{
  return YES;
}

- (CGFloat)minimumHeightInMovableContainer
{
  return 130;
}

@end
