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
#import <Pusher/Pusher.h>

@interface MasterViewController () <PTPusherDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *articles;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}
//- (IBAction)add:(id)sender {
//    TAHArticle *newArticle = [TAHArticle new];
//    newArticle.title = @"jffdsf";
//    newArticle.abstract = @"fljasdhglkhdflgkhdfslkg";
//    newArticle.url = @"http://google.com";
//    newArticle.datepublished = [NSDate new];
//    newArticle.primaryTag = @"test";
//    newArticle.uuidv3 = @"aaaaa-1";
//    
//    __block bool wasUpdated;
//    [_articles enumerateObjectsUsingBlock:^(TAHArticle *article, NSUInteger index, BOOL *stop) {
//        if ([article.uuidv3 isEqualToString:newArticle.uuidv3]) {
//            [self.tableView beginUpdates];
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
//            [self.tableView endUpdates];
//            wasUpdated = YES;
//            *stop = YES;
//        }
//    }];
//    
//    if (!wasUpdated) {
//        NSArray *insertIndexPaths = [[NSArray alloc] initWithObjects:
//                                     [NSIndexPath indexPathForRow:0 inSection:0],
//                                     nil];
//        
//        
//        [_articles insertObject:newArticle atIndex:0];
//        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
//    }
//
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FastFT";
    // Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithWhite:0.200 alpha:1.0]];
    [self.tableView registerClass:[TAHDateHeaderView class] forHeaderFooterViewReuseIdentifier:@"TableViewSectionHeaderViewIdentifier"];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
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
    

    
    PTPusherChannel *channel = [[FTAPIClient sharedClient].client subscribeToChannelNamed:@"clamo-engine-prod01-querydef-855dc66573256ec1a5088c3beb25200a"];
    [channel bindToEventNamed:@"post" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSLog(@"post: %@", channelEvent.data);
        TAHArticle *newArticle = [[FTAPIClient sharedClient] articleFromDictionary:channelEvent.data];
        
        __block bool wasUpdated;
        [_articles enumerateObjectsUsingBlock:^(TAHArticle *article, NSUInteger index, BOOL *stop) {
            if ([article.uuidv3 isEqualToString:newArticle.uuidv3]) {
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
                wasUpdated = YES;
                *stop = YES;
            }
        }];
        
        if (!wasUpdated) {
            NSArray *insertIndexPaths = [[NSArray alloc] initWithObjects:
                                         [NSIndexPath indexPathForRow:0 inSection:0],
                                         nil];
            
            
            [_articles insertObject:newArticle atIndex:0];
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)applicationDidBecomeActive:(NSNotification *) notification {
    [self refreshPosts];
}

#pragma mark - API
-(void)refreshPosts {
    [[FTAPIClient sharedClient] getArticlesWithOffset:[NSNumber numberWithInt:0] completion:^(NSArray *articles, NSError *error) {
        if (!error) {
            _articles = articles.mutableCopy;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error);
        }
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TAHArticle *article = [_articles objectAtIndex:indexPath.row];
        TAHArticleViewController *destination = (TAHArticleViewController *)[[segue destinationViewController] topViewController];
        destination.article = article;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _articles.count;
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
    TAHArticle *article = [_articles objectAtIndex:indexPath.row];
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

@end
