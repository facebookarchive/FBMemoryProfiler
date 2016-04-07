/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "FBMemoryProfilerDataSource.h"

@protocol FBMemoryProfilerPluggable;

/**
 FBMemoryProfilerOptions is an object holding sorting options and plugins that profiler is using.
 */

@interface FBMemoryProfilerOptions : NSObject

/**
 Which sorting mode is currently on? (classes, alive objects, size)
 */
@property (nonatomic, readonly) FBMemoryProfilerSortingMode sortingMode;

/**
 Is data ordered ascending or descending?
 */
@property (nonatomic, readonly) FBMemoryProfilerSortingOrder sortingOrder;

/**
 Contains list of plugins, every one of them has to conform to FBMemoryProfilerPluggable protocol.
 */
@property (nonatomic, readonly, copy, nullable) NSArray<id<FBMemoryProfilerPluggable>> *plugins;

- (nonnull instancetype)initWithSortingMode:(FBMemoryProfilerSortingMode)sortingMode
                               sortingOrder:(FBMemoryProfilerSortingOrder)sortingOrder
                                    plugins:(nullable NSArray<id<FBMemoryProfilerPluggable>> *)plugins;

@end
