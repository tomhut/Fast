//
//  FTAPIClient.m
//  Fast
//
//  Created by Tom Hutchinson on 18/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "FTAPIClient.h"
#import "TAHArticle.h"
#import "AppDelegate.h"
#import "FastKit.h"

@implementation FTAPIClient

#pragma mark - Public Methods
+ (FTAPIClient *)sharedClient {
    static FTAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://clamo.ftdata.co.uk/"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _sharedClient = [[FTAPIClient alloc] initWithBaseURL:baseURL
                                        sessionConfiguration:config];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _sharedClient.client = [PTPusher pusherWithKey:@"45b4170c83029acc104e" delegate:self];
        
        [_sharedClient.client connect];
    });
    
    return _sharedClient;
}

- (NSURLSessionDataTask *)getArticlesWithOffset:(NSNumber *)offset completion:( void (^)(NSArray *articles, NSError *error) )completion {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[[self parametersWithOffset:offset]] options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"NSJSONSerialization failed %@", error);
    }
    
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                json, @"request", nil];
    
    NSURLSessionDataTask *task = [self GET:@"/api"
                                parameters:parameters
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSDictionary *responseArray = [responseObject firstObject];
                                       NSDictionary *data = [responseArray objectForKey:@"data"];
                                       NSMutableArray *articles = [NSMutableArray new];
                                       for (NSDictionary *thisArticleDictionary in [data objectForKey:@"results"]) {
//                                           NSLog(@"%@", thisArticleDictionary);
                                           NSError *error;
                                           TAHArticle *newArticle = [self articleFromDictionary:thisArticleDictionary];
                                           
                                           [articles addObject:newArticle];

                                           
                                       }
                                       [self saveArticlesToStore:articles];
                                       completion(articles, nil);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        completion(nil, error);
                                   }];
    return task;
}

- (TAHArticle *)articleFromDictionary : (NSDictionary *)articleDictionary {
    NSError *error;
    TAHArticle *newArticle = [MTLJSONAdapter modelOfClass:[TAHArticle class]
                                       fromJSONDictionary:articleDictionary
                                                    error:&error];
    
    
    
    if (!error) {
        //PrimaryTag
        NSString *primaryTagID = [[articleDictionary objectForKey:@"metadata"] objectForKey:@"primarytagid"];
        for (NSDictionary *tag in [articleDictionary objectForKey:@"tags"]) {
            NSNumber *tagID = [tag objectForKey:@"id"];
            if ([tagID.stringValue isEqualToString:primaryTagID]) {
                newArticle.primaryTag = [tag objectForKey:@"tag"];
            }
        }
    } else {
        NSLog(@"error!!!!: %@", error);
    }
        return newArticle;
}


#pragma mark - Private Methods
- (NSDictionary *)parametersWithOffset:(NSNumber *)offset {
    NSDictionary *parameters = @{ @"action" : @"search",
                                  @"arguments" : @{ @"sort" : @"date",
                                                    @"query" : @"",
                                                    @"offset" : offset ,
                                                    @"limit" : @30,
                                                    @"suppressdrafts" : [NSNumber numberWithBool:0],
                                                    @"outputfields" : @{ @"id" : [NSNumber numberWithBool:NO],
                                                                         @"title" : [NSNumber numberWithBool:YES],
                                                                         @"abstract" : @"html",
                                                                         @"datepublished" : [NSNumber numberWithBool:YES],
                                                                         @"shorturl" : [NSNumber numberWithBool:NO],
                                                                         @"metadata" : [NSNumber numberWithBool:YES],
                                                                         @"tags" : @"visibleonly",
                                                                         @"slug" : [NSNumber numberWithBool:YES],
                                                                         }
                                                    },
                                  };
    return  parameters;
    
    
}

#pragma mark - CoreData

- (void)saveArticlesToStore:(NSArray *)articles {
    NSManagedObjectContext *mainMOC = [TAHDataAccess sharedDataAccess].managedObjectContext;
    
    //Remove old articles from store
    NSFetchRequest * allArticlesFetchRequest = [[NSFetchRequest alloc] init];
    [allArticlesFetchRequest setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:mainMOC]];
    [allArticlesFetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *articleError = nil;
    NSArray *oldArticles = [mainMOC executeFetchRequest:allArticlesFetchRequest error:&articleError];
    for (NSManagedObject *article in oldArticles) {
        [mainMOC deleteObject:article];
    }
    
    NSError *saveError = nil;
    [mainMOC save:&saveError];
    
    //Save new vouchers to store
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = mainMOC;
    [temporaryContext performBlock:^{
        
        for (TAHArticle *article in articles) {
            NSError *error;
            [MTLManagedObjectAdapter managedObjectFromModel:article
                                        insertingIntoContext:temporaryContext
                                                        error:&error];
            if (error) {
                NSLog(@"Error Serializing Voucher: %@", error);
            }

        }
        // push to parent
        NSError *pushParentError;
        if (![temporaryContext save:&pushParentError]) {
            NSLog(@"Error Pushing Child Context to Parent");
        }
        
        // save parent to disk asynchronously
        [mainMOC performBlockAndWait:^{
            NSError *error;
            if (![mainMOC save:&error]) {
                NSLog(@"Error Saving Articles to Disk: %@", error);
            } else {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"articlesUpdated"
                 object:self
                 userInfo:nil];
            }
        }];
    }];
}

@end
