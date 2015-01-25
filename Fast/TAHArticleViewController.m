//
//  TAHArticleViewController.m
//  Fast
//
//  Created by Tom Hutchinson on 25/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "TAHArticleViewController.h"

@interface TAHArticleViewController ()

@end

@implementation TAHArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setURL:[NSURL URLWithString:_article.url]];
    self.title = _article.title;
    self.showsNavigationToolbar = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
