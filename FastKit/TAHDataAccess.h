//
//  TAHDataAccess.h
//  Fast
//
//  Created by Tom Hutchinson on 21/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TAHDataAccess : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (TAHDataAccess *)sharedDataAccess;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSArray *)articlesFromPersistantStore;


@end
