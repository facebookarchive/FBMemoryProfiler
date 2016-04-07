/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerGenerationsSectionHeaderView.h"

#import "FBMemoryProfilerSectionHeaderDelegate.h"

@implementation FBMemoryProfilerGenerationsSectionHeaderView
{
  UIButton *_retainCycleDetectionButton;
  UIButton *_collapseButton;
}

- (UIButton *)_defaultSectionButton
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.titleLabel.font = [UIFont systemFontOfSize:10];
  button.layer.borderColor = [UIColor lightGrayColor].CGColor;
  button.layer.borderWidth = 1.0;

  return button;
}

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier
{
  if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
    _retainCycleDetectionButton = [self _defaultSectionButton];
    [_retainCycleDetectionButton setTitle:@"Retain Cycles" forState:UIControlStateNormal];
    [_retainCycleDetectionButton addTarget:self action:@selector(_retainCycleDetectionButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    _collapseButton = [self _defaultSectionButton];
    [_collapseButton addTarget:self action:@selector(_buttonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_retainCycleDetectionButton];
    [self addSubview:_collapseButton];
  }

  return self;
}

- (void)_buttonTapped
{
  [self.delegate sectionHeaderRequestedExpandCollapseAction:self];
}

- (void)_retainCycleDetectionButtonTapped
{
  [self.delegate sectionHeaderRequestedRetainCycleDetection:self];
}

- (void)setExpanded:(BOOL)expanded
{
  _expanded = expanded;

  if (_expanded) {
    [_collapseButton setTitle:@"Collapse" forState:UIControlStateNormal];
  } else {
    [_collapseButton setTitle:@"Expand" forState:UIControlStateNormal];
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGFloat expandButtonWidth = 56.0;
  CGFloat retainCyclesButtonWidth = 70.0;
  CGFloat width = CGRectGetWidth(self.bounds);
  CGFloat margin = 2.0;
  CGFloat height = CGRectGetHeight(self.bounds) - 2 * margin;

  _retainCycleDetectionButton.frame = CGRectMake(width - expandButtonWidth - retainCyclesButtonWidth - 4 * margin,
                                                 margin,
                                                 retainCyclesButtonWidth,
                                                 height);

  _collapseButton.frame = CGRectMake(width - expandButtonWidth - 2 * margin,
                                     margin,
                                     expandButtonWidth,
                                     height);
}

@end
