//
//  NewsTableViewController.m
//  RBCityNews
//
//  Created by Женя Михайлова on 27.02.15.
//
//

#import "NewsTableViewController.h"
#import "NewsTableViewCell.h"
#import "NewsDetailViewController.h"
//#import "UIView+ActivityIndicator.h"
#import "NewsHelper.h"
#import "Settings.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface NewsTableViewController ()
{
    UIView *footerView;
    UIRefreshControl *refreshControl;
    NSMutableDictionary *pagesByCities;
    News *selectedNews;
    ApiManager *apiManager;
}
@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pagesByCities = [[NSMutableDictionary alloc] init];
    NSArray *cities = [Settings sharedInstance].allCities;
    for (City *city in cities) {
        [pagesByCities setObject:@(1) forKey:city.city_id];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(loadAdditionalNews) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self addFooterToTableView];
    
    apiManager = [[ApiManager alloc] init];
    apiManager.apiDelegate = self;
    [self showActivityIndicator];
    [apiManager loadNewsByCitiesAndPages:pagesByCities];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFooterToTableView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 60.0)];
    UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [loadMoreButton setTitle: @"Загрузить еще новости" forState:UIControlStateNormal];
    [loadMoreButton setTintColor:Rgb2UIColor(111, 123, 138)];
    [loadMoreButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [loadMoreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [loadMoreButton addTarget:self action:@selector(loadMoreNews) forControlEvents:UIControlEventTouchUpInside];
    [loadMoreButton setFrame:CGRectMake(0, 0, self.view.frame.size.width, 60.0)];
    loadMoreButton.center = footerView.center;
    [footerView addSubview:loadMoreButton];
    [self.tableView setTableFooterView:footerView];
    self.tableView.tableFooterView.hidden = NO;
}

- (NSMutableArray *)getSelectedCities
{
    return [[Settings sharedInstance] getSelectedCities];
}

- (NSString *)getCityIdBySection:(NSInteger)section
{
    City *city = (City *)[[self getSelectedCities] objectAtIndex:section];
    return [city city_id];
}

- (void)loadAdditionalNews
{
    NSMutableDictionary *pages = [[NSMutableDictionary alloc] init];
    NSArray *cities = [Settings sharedInstance].allCities;
    for (City *city in cities) {
        [pagesByCities setObject:@(1) forKey:city.city_id];
    }
    [apiManager loaAdditionsldNewsByCitiesAndPages:pages];
}

- (void)loadMoreNews
{
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
    
    NSLog(@"load more news...");
    for (City *city in [self getSelectedCities]) {
        int page = (int)[[pagesByCities objectForKey:city.city_id] integerValue];
        page++;
        [pagesByCities setObject:[NSNumber numberWithInt:page] forKey:city.city_id];
    }
    [apiManager loadNewsByCitiesAndPages:pagesByCities];
}

/*
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.tableView.indexPathsForVisibleRows.count > 0) {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        float reload_distance = 50;
        if(y > h + reload_distance) {
            self.tableView.tableFooterView.hidden = NO;
            NSLog(@"load more rows");
        }
    }
    
 
    if(self.tableView.indexPathsForVisibleRows.count > 0) {
        NSInteger currentOffset = scrollView.contentOffset.y;
        NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if (maximumOffset - currentOffset <= -20) {
            self.tableView.tableFooterView.hidden = NO;
            NSLog(@"show footer");
        }
    }
}
*/

#pragma mark - ApiManagerDelegate

- (void)didReceiveNews:(NSMutableArray *)receivedNews
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self hideActivityIndicator];
}

- (void)loadNewsDidFailWithError:(NSString *)error
{
    [self hideActivityIndicator];
    NSLog(@"NewsTableViewController loadNewsDidFailWithError: %@", error);
}

- (void)didNotReceiveAdditionalNews
{
    [refreshControl endRefreshing];
}

- (void)didReceiveAdditionalNews
{
    [refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - SettingsDelegate

- (void)citiesDidChange
{
     [apiManager loadNewsByCitiesAndPages:pagesByCities];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self getSelectedCities] count];
}

- (NSMutableArray *)getNewsBySection:(NSInteger)section
{
    return [[NewsHelper sharedInstance].newsByCities objectForKey:[self getCityIdBySection:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *array = [self getNewsBySection:section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
    [cell setCellData:[[self getNewsBySection:indexPath.section] objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *data = [self getNewsBySection:indexPath.section];
    selectedNews = [data objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showDetails" sender:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self getSelectedCities][section] name];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    view.backgroundColor = Rgb2UIColor(236, 240, 241);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 24)];
    [label setTextColor:Rgb2UIColor(111, 123, 138)];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [label setTextAlignment:NSTextAlignmentCenter];
    City *city = [[self getSelectedCities] objectAtIndex:section];
    [label setText:city.name];
    label.center = view.center;
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //last section
    if (indexPath.section == [self getSelectedCities].count - 1) {
        if ([self getNewsBySection:indexPath.section].count == (indexPath.row + 1)) {
            tableView.tableFooterView.hidden = NO;
        }
    }
}*/

#pragma mark - Navigation

- (IBAction)readMorePressed:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil) {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        NewsDetailViewController *newsDetail = segue.destinationViewController;
        [newsDetail setDetails:selectedNews];
    }
}

#pragma mark - Activity Indicator

- (void)showActivityIndicator {
    [self showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray];
}

- (void)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style {
    CGRect frame = self.navigationController.view.bounds; //self.tableView.bounds;
    frame.origin.x = 0;
    frame.origin.y = self.navigationController.view.frame.origin.y;// self.tableView.contentOffset.y;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    view.layer.opacity = 1;
    view.tag = 1001;
    CGRect viewFrame = self.navigationController.view.frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(viewFrame.size.width/2 - 100, viewFrame.size.height/2 - 50, 200, 30)];
    [label setTextColor:Rgb2UIColor(111, 123, 138)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    label.text = @"Загрузка новостей...";
    [view addSubview:label];
    [self.navigationController.view insertSubview:view belowSubview:self.navigationController.navigationBar];
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    indicator.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    indicator.tag = 1002;
    indicator.center = view.center;
    [indicator startAnimating];
    [self.navigationController.view insertSubview:indicator belowSubview:self.navigationController.navigationBar];
}

- (void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.navigationController.view  viewWithTag:1001] removeFromSuperview];
        [[self.navigationController.view  viewWithTag:1002] removeFromSuperview];
    });
}

@end
