/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FBObjectiveCGraphElement;

/**
 Simple view controller representing one retain cycle. It will present it in a table view, where very row
 will be one FBObjectiveCGraphElement's description.
 */
@interface FBSingleRetainCycleViewController : UITableViewController

/**
 @param retainCycle retain cycle to present
 */
- (nonnull instancetype)initWithRetainCycle:(nonnull NSArray<FBObjectiveCGraphElement *> *)retainCycle;

@end
