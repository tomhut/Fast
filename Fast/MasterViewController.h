//
//  MasterViewController.h
//  Fast
//
//  Created by Tom Hutchinson on 18/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TAHArticleViewController.h"


@class TAHArticleViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TAHArticleViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

