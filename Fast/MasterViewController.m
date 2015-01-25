//
//  MasterViewController.m
//  Fast
//
//  Created by Tom Hutchinson on 18/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "MasterViewController.h"
#import "TAHArticleTableViewCell.h"
#import "NSString_stripHtml.h"
#import "FastKit.h"

@interface MasterViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    
    //section headers
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
//    [self.sectionDateFormatter setDateStyle:NSDateFormatterLongStyle];
//    [self.sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.sectionDateFormatter setDateFormat:@"EEEE"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    

    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshPosts)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self refreshPosts];
    
    self.detailViewController = (TAHArticleViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, 100, self.tableView.frame.size.width, self.tableView.frame.size.height);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API
-(void)refreshPosts {
    [[FTAPIClient sharedClient] getArticlesWithOffset:[NSNumber numberWithInt:0] completion:^(NSArray *articles, NSError *error) {
        if (!error) {
//            _articles = articles;
//            [self.tableView reloadData];
            [self groupArticlesByDay:articles];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)groupArticlesByDay:(NSArray *)articles {
    self.sections = [NSMutableDictionary dictionary];
    for (TAHArticle *article in articles) {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:article.datepublished];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [self.sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the event to the list for this day
        [eventsOnThisDay addObject:article];
    }
    
    NSArray *unsortedDays = [self.sections allKeys];
    _sortedDays = [[unsortedDays sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator].allObjects;
//    NSLog(@"self.articlesByDay %@", self.sections);
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *articlesOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        TAHArticle *article = [articlesOnThisDay objectAtIndex:indexPath.row];
        TAHArticleViewController *destination = (TAHArticleViewController *)[[segue destinationViewController] topViewController];
        destination.article = article;
        destination.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TAHArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell" forIndexPath:indexPath];
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    cell.descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(TAHArticleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *articlesOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    TAHArticle *article = [articlesOnThisDay objectAtIndex:indexPath.row];
    cell.titleLabel.text = article.title;
    NSString *abstract = article.abstract;
    NSString* stripped = [abstract stripHtml];
    cell.descriptionLabel.text = stripped;
    
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
*/

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
