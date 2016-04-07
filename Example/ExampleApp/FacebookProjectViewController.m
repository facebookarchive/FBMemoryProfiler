/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FacebookProjectViewController.h"

@implementation FacebookProjectViewController
{
  // It should be weak!
  id _delegate;
  
  UIWebView *_webView;
  NSURL *_url;
}

- (instancetype)initWithName:(NSString *)name URL:(NSURL *)url
{
  if (self = [super init]) {
    self.title = name;
    _url = url;
    
    // Intentional retain cycle
    _delegate = self;
  }
  
  return self;
}

- (void)loadView {
  _webView = [[UIWebView alloc] init];
  self.view = _webView;
  self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

@end
