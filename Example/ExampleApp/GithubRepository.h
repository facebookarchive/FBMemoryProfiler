/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface GithubRepository : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortDescription;
@property (nonatomic, copy) NSURL *url;

- (instancetype)initWithName:(NSString *)name
            shortDescription:(NSString *)shortDescription
                         url:(NSURL *)url;

@end
