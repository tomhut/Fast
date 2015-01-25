//
//  InterfaceController.m
//  Fast WatchKit Extension
//
//  Created by Tom Hutchinson on 19/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "NewsItemInterfaceController.h"
@import FastKit;

@interface NewsItemInterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *bodyLabel;

@end


@implementation NewsItemInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSLog(@"context: %@", context);
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSArray *articles = [TAHDataAccess sharedDataAccess].articlesFromPersistantStore;
    [self configureControllerWithArticle:articles.firstObject];
}

- (void)configureControllerWithArticle:(TAHArticle *)article {
    [_titleLabel setText:article.title];
    [_bodyLabel setText:article.abstract];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



