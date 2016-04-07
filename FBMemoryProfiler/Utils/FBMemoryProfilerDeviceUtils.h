/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 @return current resident memory from mach task info
 */
uint64_t FBMemoryProfilerResidentMemoryInBytes(void);

#ifdef __cplusplus
}
#endif
