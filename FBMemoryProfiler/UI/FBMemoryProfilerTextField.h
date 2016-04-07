/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Simple subclass of UITextField that supports insets
 */
@interface FBMemoryProfilerTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end
