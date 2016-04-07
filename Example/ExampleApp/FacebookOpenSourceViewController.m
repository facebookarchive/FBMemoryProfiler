/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the LICENSE file in
 * the root directory of this source tree.
 */

#import "FacebookOpenSourceViewController.h"

#import "FacebookProjectViewController.h"

#import "GithubRepository.h"

static NSString *const kFacebookOpenSourceReusableIdentifier = @"kFacebookOpenSourceReusableIdentifier";

@interface FacebookOpenSourceViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation FacebookOpenSourceViewController
{
  UITableView *_tableView;
  
  NSArray<GithubRepository *> *_data;
}

- (instancetype)init
{
  if (self = [super init]) {
    _data = [NSArray array];
    self.title = @"Facebook Open Source";
  }
  
  return self;
}

- (void)loadView
{
  _tableView = [UITableView new];
  _tableView.backgroundColor = [UIColor whiteColor];
  self.view = _tableView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _tableView.delegate = self;
  _tableView.dataSource = self;
  
  NSURL *url = [NSURL URLWithString:@"https://api.github.com/orgs/facebook/repos?per_page=300"];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:
                           [NSURLSessionConfiguration defaultSessionConfiguration]];
 
  NSURLSessionDataTask *task =
  [session dataTaskWithURL:url
         completionHandler:^(NSData * _Nullable data,
                             NSURLResponse * _Nullable response,
                             NSError * _Nullable error) {
           dispatch_async(dispatch_get_main_queue(), ^{
             NSArray *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
             if (json) {
               [self _parseData:json];
               [_tableView reloadData];
             }
           });
         }];
  [task resume];
}

- (void)_parseData:(NSArray *)data
{
  NSMutableArray<GithubRepository *> *parsedData = [NSMutableArray array];
  for (NSDictionary *repository in data) {
    GithubRepository *githubRepository =
    [[GithubRepository alloc] initWithName:repository[@"name"]
                          shortDescription:repository[@"description"]
                                       url:[NSURL URLWithString:repository[@"html_url"]]];
    [parsedData addObject:githubRepository];
  }
  
  _data = [parsedData copy];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFacebookOpenSourceReusableIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:kFacebookOpenSourceReusableIdentifier];
  }
  
  cell.textLabel.text = _data[indexPath.row].name;
  cell.detailTextLabel.text = _data[indexPath.row].shortDescription;
  cell.detailTextLabel.numberOfLines = 0;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FacebookProjectViewController *projectViewController =
  [[FacebookProjectViewController alloc] initWithName:_data[indexPath.row].name
                                                  URL:_data[indexPath.row].url];
  [self.navigationController pushViewController:projectViewController
                                       animated:YES];
}

@end
