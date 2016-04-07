/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FBMemoryProfilerView.h"

#import "FBMemoryProfilerMathUtils.h"
#import "FBMemoryProfilerSegmentedControl.h"
#import "FBMemoryProfilerTextField.h"

static const CGFloat kFBMemoryProfilerHeaderHeight = 70.0;
static const CGFloat kFBMemoryProfilerMargin = 5.0;
static const CGFloat kFBMemoryProfilerNumberOfRowsInHeader = 2.0;
static const CGFloat kFBMemoryProfilerDragHandleHeight = 20.0;

@implementation FBMemoryProfilerView
{
  NSDictionary *_attributes;

  UILabel *_residentMemory;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithRed:(245.0f / 255.0f) green:(245.0f / 255.0f) blue:(245.0f / 255.0f) alpha:1.0];

    UIFont *font = [UIFont systemFontOfSize:14];
    _attributes = @{NSFontAttributeName: font};

    _residentMemory = [UILabel new];
    _residentMemory.font = font;

    _tableView = [UITableView new];
    _tableView.backgroundColor = [UIColor whiteColor];

    _subwordFilter = [FBMemoryProfilerTextField new];
    _subwordFilter.backgroundColor = [UIColor whiteColor];
    _subwordFilter.font = font;
    _subwordFilter.placeholder = @"Filter...";
    _subwordFilter.autocorrectionType = UITextAutocorrectionTypeNo;
    _subwordFilter.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _subwordFilter.layer.borderWidth = 0.5;
    _subwordFilter.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _subwordFilter.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);

    _sortControl = [[FBMemoryProfilerSegmentedControl alloc] initWithItems:@[@"Class", @"Alive", @"Size"]];
    _sortControl.backgroundColor = [UIColor whiteColor];

    _hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _hideButton.backgroundColor = [UIColor whiteColor];
    _hideButton.layer.borderWidth = 1.0;
    _hideButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_hideButton setTitle:@"Hide" forState:UIControlStateNormal];

    _markGenerationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _markGenerationButton.backgroundColor = [UIColor whiteColor];
    _markGenerationButton.layer.borderWidth = 1.0;
    _markGenerationButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_markGenerationButton setTitle:@"Mark Gen." forState:UIControlStateNormal];

    [self addSubview:_residentMemory];
    [self addSubview:_tableView];
    [self addSubview:_subwordFilter];
    [self addSubview:_sortControl];
    [self addSubview:_hideButton];
    [self addSubview:_markGenerationButton];
  }

  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGFloat cellHeight = FBMemoryProfilerRoundPixelValue(kFBMemoryProfilerHeaderHeight / kFBMemoryProfilerNumberOfRowsInHeader);

  CGFloat width = CGRectGetWidth(self.bounds);
  CGFloat halfWidth = FBMemoryProfilerRoundPixelValue(width / 2);

  // The real content width
  CGFloat expectedElementWidth = halfWidth - 2 * kFBMemoryProfilerMargin;
  CGFloat expectedElementHeight = cellHeight - 2 * kFBMemoryProfilerMargin;

  // Text Field in the top left corner
  _subwordFilter.frame = CGRectMake(kFBMemoryProfilerMargin,
                                    kFBMemoryProfilerMargin,
                                    expectedElementWidth,
                                    expectedElementHeight);

  // Two buttons will be layed out in top right corner sharing the space
  CGFloat buttonSpaceWithMargins = FBMemoryProfilerRoundPixelValue(halfWidth / 2.0);
  CGFloat buttonWidth = buttonSpaceWithMargins - 2 * kFBMemoryProfilerMargin;
  _markGenerationButton.frame = CGRectMake(halfWidth + kFBMemoryProfilerMargin,
                                           kFBMemoryProfilerMargin,
                                           buttonWidth,
                                           expectedElementHeight);
  _hideButton.frame = CGRectMake(halfWidth + buttonSpaceWithMargins + kFBMemoryProfilerMargin,
                                 kFBMemoryProfilerMargin,
                                 buttonWidth,
                                 expectedElementHeight);

  _sortControl.frame = CGRectMake(kFBMemoryProfilerMargin,
                                  cellHeight + kFBMemoryProfilerMargin,
                                  FBMemoryProfilerRoundPixelValue(expectedElementWidth),
                                  expectedElementHeight);

  // Resident Memory layout
  CGFloat residentLabelWidth = halfWidth - 2 * kFBMemoryProfilerMargin;

  CGRect residentBoundingRect =
    [_residentMemory.text boundingRectWithSize:CGSizeMake(residentLabelWidth, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:_attributes
                                       context:nil];

  // Y-offset for residentBoundingRect to make it centered vertically
  CGFloat yOffset = MAX(0, FBMemoryProfilerRoundPixelValue((cellHeight - CGRectGetHeight(residentBoundingRect)) / 2));


  _residentMemory.frame = CGRectMake(halfWidth + kFBMemoryProfilerMargin,
                                     cellHeight + yOffset,
                                     FBMemoryProfilerRoundPixelValue(residentLabelWidth),
                                     FBMemoryProfilerRoundPixelValue(CGRectGetHeight(residentBoundingRect)));


  _tableView.frame = CGRectMake(0,
                                kFBMemoryProfilerHeaderHeight,
                                CGRectGetWidth(self.bounds),
                                CGRectGetHeight(self.bounds) - kFBMemoryProfilerHeaderHeight - kFBMemoryProfilerDragHandleHeight);
}

- (void)setResidentMemory:(NSString *)residentMemory
{
  _residentMemory.text = [NSString stringWithFormat:@"%@", residentMemory];
}

@end
