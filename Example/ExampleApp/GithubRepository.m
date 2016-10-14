/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "GithubRepository.h"

@implementation GithubRepository

- (instancetype)initWithName:(NSString *)name
            shortDescription:(NSString *)shortDescription
                         url:(NSURL *)url
{
  if (self = [super init]) {
    _name = [name copy];
    _shortDescription = ([shortDescription class] != [NSNull class]) ? [shortDescription copy] : @"No Description";
    _url = [url copy];
  }
  
  return self;
}

@end
