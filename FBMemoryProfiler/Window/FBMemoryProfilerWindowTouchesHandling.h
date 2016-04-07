/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@protocol FBMemoryProfilerWindowTouchesHandling <NSObject>

- (BOOL)window:(nullable UIWindow *)window shouldReceiveTouchAtPoint:(CGPoint)point;

@end
