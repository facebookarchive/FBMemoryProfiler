/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerContainerViewController.h"

#import "FBMemoryProfiler.h"
#import "FBMemoryProfilerMathUtils.h"
#import "FBMemoryProfilerMovableViewController.h"

static UIEdgeInsets FBSafeAreaInsets(UIView *view) {
#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
  if (@available(iOS 11.0, *)) {
    return view.safeAreaInsets;
  }
#endif

  return UIEdgeInsetsZero;
}

@implementation FBMemoryProfilerContainerViewController
{
  UIViewController<FBMemoryProfilerMovableViewController> *_presentedViewController;
  UIPanGestureRecognizer *_panGestureRecognizer;

  UIPinchGestureRecognizer *_pinchGestureRecognizer;
  CGFloat _heightOnPinch;
  CGPoint _previousPinchingPoint;

  CGSize _size;
  CGFloat _windowTop;
  CGFloat _windowBottom;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor clearColor];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];

}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
}

- (void)presentViewController:(UIViewController<FBMemoryProfilerMovableViewController> *)viewController
                     withSize:(CGSize)size
{
  if (_presentedViewController) {
    [self dismissCurrentViewController];
  }

  _presentedViewController = viewController;
  _size = size;
  CGSize adjustedSize = CGSizeMake(MIN(_size.width, CGRectGetWidth(self.view.bounds)),
                                   MIN(_size.height, CGRectGetHeight(self.view.bounds)));

  // Put content right under status bar, in the middle
  _windowTop = MAX(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), FBSafeAreaInsets(self.view).top);
  _windowBottom = CGRectGetHeight(self.view.bounds) - FBSafeAreaInsets(self.view).bottom;
  CGFloat widthOffset = FBMemoryProfilerRoundPixelValue((CGRectGetWidth(self.view.bounds) - adjustedSize.width) / 2.0);
    
  CGRect frame = CGRectMake(widthOffset, _windowTop, adjustedSize.width, adjustedSize.height);

  [self addChildViewController:_presentedViewController];
  _presentedViewController.view.frame = frame;
  [self.view addSubview:_presentedViewController.view];

  _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan)];
  _panGestureRecognizer.minimumNumberOfTouches = 1;
  _panGestureRecognizer.maximumNumberOfTouches = 1;
  [_presentedViewController.view addGestureRecognizer:_panGestureRecognizer];

  if ([_presentedViewController shouldStretchInMovableContainer]) {
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_pinch:)];
    [_presentedViewController.view addGestureRecognizer:_pinchGestureRecognizer];
  }

  [_presentedViewController didMoveToParentViewController:self];
}

- (void)dismissCurrentViewController
{
  if (!_presentedViewController) {
    return;
  }

  [_presentedViewController willMoveToParentViewController:nil];

  [_panGestureRecognizer removeTarget:self action:NULL];
  _panGestureRecognizer = nil;
  [_pinchGestureRecognizer removeTarget:self action:NULL];
  _pinchGestureRecognizer = nil;

  [_presentedViewController.view removeFromSuperview];
  [_presentedViewController removeFromParentViewController];
}

- (void)_pan
{
  if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    [_presentedViewController containerWillMove:self];
  }

  CGPoint translation = [_panGestureRecognizer translationInView:self.view];

  CGPoint center = _presentedViewController.view.center;
  center.x += translation.x;
  center.y += translation.y;

  CGFloat centerHeightOffset = FBMemoryProfilerRoundPixelValue(CGRectGetHeight(_presentedViewController.view.frame) / 2.0);
  CGFloat centerWidthOffset = FBMemoryProfilerRoundPixelValue(CGRectGetWidth(_presentedViewController.view.frame) / 2.0);

  // Make sure it stays on screen
  if (center.y - centerHeightOffset < _windowTop) {
    center.y = _windowTop + centerHeightOffset;
  }
  if (center.x - centerWidthOffset < FBSafeAreaInsets(self.view).left) {
    center.x = centerWidthOffset + FBSafeAreaInsets(self.view).left;
  }

  CGFloat maximumY = _windowBottom -  CGRectGetHeight(_presentedViewController.view.frame);
  if (center.y - centerHeightOffset > maximumY) {
    center.y = maximumY + centerHeightOffset;
  }

  CGFloat maximumX = CGRectGetWidth(self.view.bounds) - FBSafeAreaInsets(self.view).right - CGRectGetWidth(_presentedViewController.view.frame);
  if (center.x - centerWidthOffset > maximumX) {
    center.x = maximumX + centerWidthOffset;
  }

  _presentedViewController.view.center = center;

  [_panGestureRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)_pinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    _heightOnPinch = CGRectGetHeight(_presentedViewController.view.frame);

    [_presentedViewController containerWillMove:self];
  }

  CGFloat windowHeight = CGRectGetHeight(self.view.bounds);

  CGFloat scale = gestureRecognizer.scale;
  CGFloat statusBarOffset = 20;

  CGFloat expectedHeight = scale * _heightOnPinch;
  expectedHeight = MAX(expectedHeight, [_presentedViewController minimumHeightInMovableContainer]);
  expectedHeight = MIN(expectedHeight, windowHeight - statusBarOffset);
  CGRect newFrame = _presentedViewController.view.frame;

  CGFloat yOffset = FBMemoryProfilerRoundPixelValue((expectedHeight - CGRectGetHeight(_presentedViewController.view.frame)) / 2.0);

  newFrame.size.height = expectedHeight;
  newFrame.origin.y -= yOffset;
  if (newFrame.origin.y <= statusBarOffset) {
    newFrame.origin.y = statusBarOffset;
  }

  if (newFrame.origin.y + expectedHeight >= windowHeight) {
    newFrame.origin.y = windowHeight - expectedHeight;
  }

  _presentedViewController.view.frame = newFrame;
}

#pragma mark Keyboard Handling

- (void)_keyboardWillShow:(NSNotification *)notification
{
  CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  CGFloat keyboardTopY = endFrame.origin.y;

  [self _pushPresentedViewAboveKeyboard:keyboardTopY];
}

- (void)_pushPresentedViewAboveKeyboard:(CGFloat)keyboardTopY
{
  CGFloat rectBottom = CGRectGetMaxY(_presentedViewController.view.frame);
  if (rectBottom <= keyboardTopY) {
    return;
  }

  CGFloat difference = rectBottom - keyboardTopY;

  // Maximum height is measured from status bar to keyboard top line
  CGFloat maximumHeight = keyboardTopY - 20;
  CGFloat currentHeight = CGRectGetHeight(_presentedViewController.view.frame);
  CGFloat desiredHeight = (currentHeight > maximumHeight) ? maximumHeight : currentHeight;

  CGFloat yOffset = MAX(currentHeight - maximumHeight, 0);

  CGRect newFrame = CGRectMake(_presentedViewController.view.frame.origin.x,
                               _presentedViewController.view.frame.origin.y - difference + yOffset,
                               CGRectGetWidth(_presentedViewController.view.frame),
                               desiredHeight);

  [UIView animateWithDuration:0.3
                   animations:^{
                     self->_presentedViewController.view.frame = newFrame;
                   }];
}

#pragma mark Rotations

- (UIViewController *)_viewControllerDecidingAboutRotations
{
#if _INTERNAL_IMP_ENABLED
  UIWindow *window = [[UIApplication sharedApplication] keyWindow];
  UIViewController *viewController = window.rootViewController;
  SEL viewControllerForSupportedInterfaceOrientationsSelector =
  NSSelectorFromString(@"_viewControllerForSupportedInterfaceOrientations");
  if ([viewController respondsToSelector:viewControllerForSupportedInterfaceOrientationsSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    viewController = [viewController performSelector:viewControllerForSupportedInterfaceOrientationsSelector];
#pragma clang diagnostic pop
  }
  return viewController;
#else
  return self;
#endif // _INTERNAL_IMP_ENABLED
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  UIViewController *viewControllerToAsk = [self _viewControllerDecidingAboutRotations];
  UIInterfaceOrientationMask supportedOrientations = UIInterfaceOrientationMaskAll;
  if (viewControllerToAsk && viewControllerToAsk != self) {
    supportedOrientations = [viewControllerToAsk supportedInterfaceOrientations];
  }

  return supportedOrientations;
}

- (BOOL)shouldAutorotate
{
  UIViewController *viewControllerToAsk = [self _viewControllerDecidingAboutRotations];
  BOOL shouldAutorotate = YES;
  if (viewControllerToAsk && viewControllerToAsk != self) {
    shouldAutorotate = [viewControllerToAsk shouldAutorotate];
  }
  return shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
  // We did rotate, we should update frame of contained window (it was depending on bounds)
  CGSize adjustedSize = CGSizeMake(MIN(_size.width, CGRectGetWidth(self.view.bounds)),
                                   MIN(_size.height, CGRectGetHeight(self.view.bounds)));

  CGFloat widthOffset = MIN(_presentedViewController.view.frame.origin.x,
                            CGRectGetWidth(self.view.bounds) - adjustedSize.width);
  CGFloat heightOffset = MIN(_presentedViewController.view.frame.origin.y,
                             CGRectGetHeight(self.view.bounds) - adjustedSize.height);

  CGRect frame = CGRectMake(widthOffset, heightOffset, adjustedSize.width, adjustedSize.height);

  [UIView animateWithDuration:duration animations:^{
    self->_presentedViewController.view.frame = frame;
  }];

}

@end
