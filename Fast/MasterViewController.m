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
#import "TAHDateHeaderView.h"

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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithWhite:0.200 alpha:1.0]];
    [self.tableView registerClass:[TAHDateHeaderView class] forHeaderFooterViewReuseIdentifier:@"TableViewSectionHeaderViewIdentifier"];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //section headers
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.804 green:0.114 blue:0.149 alpha:1.0];
    [self.refreshControl addTarget:self
                            action:@selector(refreshPosts)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self refreshPosts];
    
    self.detailViewController = (TAHArticleViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
//    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
//    paragraphStyle.alignment                = NSTextAlignmentRight;
//    
//    
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                                     paragraphStyle,
//                                                                     NSParagraphStyleAttributeName,
//                                                                     nil]];
    
    
    //StatusBar
//    UIWindow *statusBarWindow = [[UIApplication sharedApplication] valueForKey:@"_statusBarWindow"];
//    UIView *statusBarView = statusBarWindow.subviews.firstObject;
//    statusBarView.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, 100, self.tableView.frame.size.width, self.tableView.frame.size.height);

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
            [self updateTitle];
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
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inputDate];
    
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
//        destination.navigationItem.leftItemsSupplementBackButton = YES;
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
    cell.presentingTV = self.tableView;
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *articlesOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    TAHArticle *article = [articlesOnThisDay objectAtIndex:indexPath.row];
    cell.titleLabel.text = article.title;
    NSString *abstract = article.abstract;
    NSString* stripped = [abstract stripHtml];
    cell.descriptionLabel.text = stripped;
    cell.tagLabel.text = article.primaryTag;
    
    //Time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    cell.timePublishedLabel.text = [dateFormatter stringFromDate:article.datepublished];
    
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
//    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 44.0;
    return 0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *headerReuseIdentifier = @"TableViewSectionHeaderViewIdentifier";
//    
//    TAHDateHeaderView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
//    // Display specific header title
//    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
//    sectionHeaderView.dateLabel.text = [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
//    
//    return sectionHeaderView;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateTitle];
}

- (void)updateTitle {
    NSIndexPath *indexPath = [self.tableView indexPathsForVisibleRows].firstObject;
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    self.title = [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
}


@end
