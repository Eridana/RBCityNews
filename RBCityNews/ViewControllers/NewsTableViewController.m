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
#import "NewsHelper.h"
#import "NetworkManager.h"
#import "Settings.h"

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
NSString * const keyLastUpdated = @"lastUpdated";

@interface NewsTableViewController ()
{
    NSString *lastUpdatedDateString;
    UIView *footerView;
    NSMutableDictionary *pagesByCities;
    News *selectedNews;
    ApiManager *apiManager;
    NSDateFormatter *formatter;
    UIButton *loadMoreButton;
    UIView *noInternetConnectionView;
    NSMutableArray *indexPathsForResresh;
    NSTimer *timer;
}
@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    indexPathsForResresh = [[NSMutableArray alloc] init];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    pagesByCities = [[NSMutableDictionary alloc] init];
    NSArray *cities = [Settings sharedInstance].allCities;
    for (City *city in cities) {
        [pagesByCities setObject:@(1) forKey:city.city_id];
    }
    
    [self addFooterToTableView];
    
    apiManager = [[ApiManager alloc] init];
    apiManager.apiDelegate = self;
    
    if ([[NetworkManager sharedInstance] isConnectionAvailable]) {
        [self loadNews];
        //[self setLastUpdatedDate:[NSDate date]];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNews)
                                                     name:kConnectionIsAvailableNotificationName
                                                   object:nil];
        [self addNoInternetConnectionView];
    }
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)dealloc
{
    [self removeNotifications];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFooterToTableView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 60.0)];
    loadMoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
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

- (void)addNoInternetConnectionView
{
    CGRect frame = self.navigationController.view.bounds;
    frame.origin.x = 0;
    frame.origin.y = self.navigationController.view.frame.origin.y;
    
    noInternetConnectionView = [[UIView alloc] initWithFrame:frame];
    noInternetConnectionView.backgroundColor = [UIColor whiteColor];
    
    CGRect viewFrame = self.navigationController.view.frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(viewFrame.size.width/2 - 125, viewFrame.size.height/2 - 100, 250, 80)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    label.text = @"Не найдено активное соединение с интернетом.";
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label setTextColor:Rgb2UIColor(111, 123, 138)];
    label.clipsToBounds = YES;
    [noInternetConnectionView addSubview:label];
    /*
    if (IS_OS_8_OR_LATER) {
        UIButton *goToSettings = [UIButton buttonWithType:UIButtonTypeSystem];
        [goToSettings setFrame:CGRectMake(0, 0, 194, 40)];
        [goToSettings setBackgroundImage:[UIImage imageNamed:@"button_web.png"] forState:UIControlStateNormal];
        [goToSettings setTitle: @"Перейти в настройки" forState:UIControlStateNormal];
        [goToSettings setTintColor:[UIColor whiteColor]];
        [goToSettings.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [goToSettings.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [goToSettings addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        goToSettings.center = noInternetConnectionView.center;
        [noInternetConnectionView addSubview:goToSettings];
    }
    else {
        label.center = noInternetConnectionView.center;
    }
     */
    label.center = noInternetConnectionView.center;
    [self.navigationController.view insertSubview:noInternetConnectionView belowSubview:self.navigationController.navigationBar];
}

- (void)openSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (NSMutableDictionary *)getLastUpdatedDateByCities
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (City *city in [[Settings sharedInstance] getSelectedCities]) {
        NSMutableArray *array = [[NewsHelper sharedInstance].newsByCities objectForKey:city.city_id];
        if (array.count > 0) {
            NSDate *date = [[array firstObject] date];
            NSDate *datePlusOneSecond = [date dateByAddingTimeInterval:1];
            NSString *lastUpdated = [formatter stringFromDate:datePlusOneSecond];
            [result setObject:lastUpdated forKey:city.city_id];
        }
    }
    return result;
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

- (void)loadNews
{
    if ([[self.navigationController.view subviews] containsObject:noInternetConnectionView]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [noInternetConnectionView removeFromSuperview];
        });
    }
    [self showActivityIndicator];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [apiManager loadNewsByCitiesAndPages:pagesByCities];
    [self removeNotifications];
}

- (IBAction)refreshNews:(id)sender
{
    [apiManager loadAdditionalNewsByDatesAndCities:[self getLastUpdatedDateByCities]];
}

- (void)loadMoreNews
{
    NSLog(@"loadMoreNews");
    loadMoreButton.enabled = NO;
    
//    if ([[NetworkManager sharedInstance] isConnectionAvailable] == YES) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        for (City *city in [self getSelectedCities]) {
            int page = (int)[[pagesByCities objectForKey:city.city_id] integerValue];
            page++;
            [pagesByCities setObject:[NSNumber numberWithInt:page] forKey:city.city_id];
        }
        [apiManager loadNewsByCitiesAndPages:pagesByCities];
//    }
//    else {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(loadMoreNews)
//                                                     name:kConnectionIsAvailableNotificationName
//                                                   object:nil];
//        [self addNoInternetConnectionView];
//    }
}

- (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.05, 1.0)
                               green:MIN(g + 0.05, 1.0)
                                blue:MIN(b + 0.05, 1.0)
                               alpha:a];
    return nil;
}

#pragma mark - ApiManagerDelegate

- (void)didReceiveNews:(NSMutableArray *)receivedNews
{
    NSLog(@"didReceiveNews");
    dispatch_async(dispatch_get_main_queue(), ^{
        loadMoreButton.enabled = YES;
        if ([[self.navigationController.view subviews] containsObject:noInternetConnectionView]) {
            [noInternetConnectionView removeFromSuperview];
        }
    });
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self hideActivityIndicator];
}

- (void)loadNewsDidFailWithError:(NSString *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadMoreButton.enabled = YES;
    });
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self hideActivityIndicator];
    NSLog(@"NewsTableViewController loadNewsDidFailWithError: %@", error);
}
     
- (void)didNotReceiveAdditionalNews
{
    NSLog(@"didNotReceiveAdditionalNews");
    if ([self.refreshControl isRefreshing] == YES) {
        [self.refreshControl endRefreshing];
    }
}

- (void)didReceiveAdditionalNews:(NSMutableArray *)receivedNews
{
    NSLog(@"didReceiveAdditionalNews");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.refreshControl isRefreshing] == YES) {
            [self.refreshControl endRefreshing];
            
            [indexPathsForResresh removeAllObjects];
            [self performSelector:@selector(hideColors) withObject:nil afterDelay:180];
        }
        NSMutableArray *indicesToAdd = [[NSMutableArray alloc] init];
        [self.tableView beginUpdates];
        for (int i = 0; i < receivedNews.count; i++) {
            News* news = receivedNews[i];
            int section = (int)[[self getSelectedCities] indexOfObject:news.city];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:section];
            [indicesToAdd addObject: indexpath];
        }
        [indexPathsForResresh addObjectsFromArray:indicesToAdd];
        [self.tableView insertRowsAtIndexPaths:indicesToAdd withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self.tableView reloadData];
    });
}


- (void)hideColors
{
    NSLog(@"hideColors");
    for (City *city in [Settings sharedInstance].allCities) {
        NSMutableArray *news = [[NewsHelper sharedInstance].newsByCities objectForKey:city.city_id];
        for (News *new in news) {
            if (new.isNotRead == YES) {
                new.isNotRead = NO;
            }
        }
    }
    [self.tableView reloadRowsAtIndexPaths:indexPathsForResresh withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - SettingsDelegate

- (void)citiesDidChange
{
    NSLog(@"cities did change");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
    News *cellNew = [[self getNewsBySection:indexPath.section] objectAtIndex:indexPath.row];
    [cellNew addObserver:cell forKeyPath:@"isNotRead" options:NSKeyValueObservingOptionNew context:nil];
    [cell setCellData:cellNew];
    if (cellNew.isNotRead == YES) {
        cell.todayCellColorView.backgroundColor = Rgb2UIColor(134, 226, 213);
    }
    else {
        cell.todayCellColorView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *data = [self getNewsBySection:indexPath.section];
    selectedNews = [data objectAtIndex:indexPath.row];
    selectedNews.isNotRead = NO;
    [self performSegueWithIdentifier:@"showDetails" sender:nil];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    else if ([segue.identifier isEqualToString:@"selectCities"]) {
        SettingsTableViewController *svc = segue.destinationViewController;
        if (svc.settingsDelegate == nil) {
            svc.settingsDelegate = self;
        }
    }
}

#pragma mark - Activity Indicator

- (void)showActivityIndicator {
    [self showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray];
}

- (void)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style {
    CGRect frame = self.navigationController.view.bounds;
    frame.origin.x = 0;
    frame.origin.y = self.navigationController.view.frame.origin.y;
    
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
