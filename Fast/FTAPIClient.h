//
//  FTAPIClient.h
//  Fast
//
//  Created by Tom Hutchinson on 18/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <Pusher/Pusher.h>
#import "TAHArticle.h"

@interface FTAPIClient : AFHTTPSessionManager

+ (FTAPIClient *)sharedClient;
- (NSURLSessionDataTask *)getArticlesWithOffset:(NSNumber *)offset completion:( void (^)(NSArray *articles, NSError *error) )completion;

@property (strong, nonatomic) PTPusher *client;

- (TAHArticle *)articleFromDictionary : (NSDictionary *)articleDictionary;

@end
