/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "AppDelegate.h"

#import "CacheCleanerPlugin.h"
#import "FacebookOpenSourceViewController.h"
#import "RetainCycleLoggerPlugin.h"

#import <FBMemoryProfiler/FBMemoryProfiler.h>

@implementation AppDelegate
{
  FBMemoryProfiler *_memoryProfiler;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  UINavigationController *navigationController =
  [[UINavigationController alloc] initWithRootViewController:[FacebookOpenSourceViewController new]];
  _window.rootViewController = navigationController;
  [_window makeKeyAndVisible];
  
  _memoryProfiler = [[FBMemoryProfiler alloc] initWithPlugins:@[[CacheCleanerPlugin new],
                                                                [RetainCycleLoggerPlugin new]]
                             retainCycleDetectorConfiguration:nil];
  [_memoryProfiler enable];
  
  return YES;
}

@end
