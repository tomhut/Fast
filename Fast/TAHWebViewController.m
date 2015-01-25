//
//  TAHWebViewController.m
//  ftapitest
//
//  Created by Tom Hutchinson on 12/01/2015.
//  Copyright (c) 2015 JustYoyo Ltd. All rights reserved.
//

#import "TAHWebViewController.h"

@interface TAHWebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TAHWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:1.000 green:0.945 blue:0.882 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
//    self.title = _title;
    [_webView loadHTMLString:_html baseURL:nil];
    _webView.backgroundColor = [UIColor colorWithRed:1.000 green:0.945 blue:0.882 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:1.000 green:0.945 blue:0.882 alpha:1.0];
    _webView.opaque = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setHtml:(NSString *)html {
//    _html = html;
//    [_webView loadHTMLString:html baseURL:nil];
//}

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
