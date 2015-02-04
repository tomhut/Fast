//
//  TAHArticleViewController.m
//  Fast
//
//  Created by Tom Hutchinson on 25/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "TAHArticleViewController.h"

@interface TAHArticleViewController ()

@property (nonatomic, strong) NSUserActivity *myActivity;

@end

@implementation TAHArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setURL:[NSURL URLWithString:_article.url]];
    self.title = _article.title;
    
//    self.showsNavigationToolbar = YES;
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.804 green:0.114 blue:0.149 alpha:1.0];
    self.navigationController.toolbar.opaque = YES;
    self.navigationController.toolbar.barTintColor = [UIColor colorWithWhite:0.200 alpha:1.0];
//    self.title = @"The quick brown fox jumps over the lazy dog";
    
    _myActivity = [[NSUserActivity alloc]
                                  initWithActivityType: @"com.tomhut.fast.reading"];
//    myActivity.userInfo = @{ ... };
    _myActivity.title = @"Reading";
    _myActivity.webpageURL = [NSURL URLWithString:_article.url];
    [_myActivity becomeCurrent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_myActivity invalidate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
