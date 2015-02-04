//
//  TAHDataAccess.m
//  Fast
//
//  Created by Tom Hutchinson on 21/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "TAHDataAccess.h"
#import "TAHArticle.h"

@implementation TAHDataAccess

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (TAHDataAccess *)sharedDataAccess {
    static TAHDataAccess *_sharedDataAccess = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataAccess = [[TAHDataAccess alloc] init];
    });
    return _sharedDataAccess;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.tomhut.Fast" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Fast" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *containerPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.fast.datastore.store"].path;
    NSString *sqlitePath = [NSString stringWithFormat:@"%@/%@", containerPath, @"Fast"];
    NSURL *url = [NSURL fileURLWithPath:sqlitePath];
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError *error = nil;

    // Create the coordinator and store
    
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fast.sqlite"];
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (NSArray *)articlesFromPersistantStore {
    NSManagedObjectContext *mainMOC = [TAHDataAccess sharedDataAccess].managedObjectContext;
    
    NSError *error = nil;
    NSArray *managedArticlesArray = [mainMOC executeFetchRequest:[self articlesFetchRequestWithManagedObjectContext:mainMOC] error:&error];
    
    NSMutableArray *articles = [NSMutableArray new];
    for (NSManagedObject *managedArticle in managedArticlesArray) {
        NSError *error;
        TAHArticle *article = [MTLManagedObjectAdapter modelOfClass:TAHArticle.class fromManagedObject:managedArticle error:&error];
        if (!error) {
            [articles addObject:article];
        }
    }
    return articles;
}

#pragma mark - CoreData
- (NSFetchRequest *)articlesFetchRequestWithManagedObjectContext:(NSManagedObjectContext *)mangedObjectContext {
    NSFetchRequest *allArticlesFetchRequest = [[NSFetchRequest alloc] init];
    [allArticlesFetchRequest setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:mangedObjectContext]];
    [allArticlesFetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    //    NSArray *sortDescriptors = [self voucherSortDescriptors];
    //    [allArticlesFetchRequest setSortDescriptors:sortDescriptors];
    
    return allArticlesFetchRequest;
}

@end
