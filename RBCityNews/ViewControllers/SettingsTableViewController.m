//
//  SettingsTableViewController.m
//  RBCityNews
//
//  Created by Женя Михайлова on 27.02.15.
//
//

#import "SettingsTableViewController.h"
#import "Settings.h"
#import "CityTableViewCell.h"
#import "City.h"

static NSString *cellIdentifier = @"cityCell";

@interface SettingsTableViewController()
{
    NSArray *cities;
    UIImage *checkmark;
    BOOL citiedDidChange;
}
@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    self.navigationController.navigationBar.translucent = NO;
    [super viewDidLoad];
    checkmark = [UIImage imageNamed:@"check.png"];
    cities = [Settings sharedInstance].allCities;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    City *city = [self getCityByIndexPath:indexPath];
    cell.textLabel.text = city.name;
    
    if(city.selected) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:checkmark];
        cell.accessoryView.opaque = NO;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (City *)getCityByIndexPath:(NSIndexPath *)indexPath
{
    City * city = [cities objectAtIndex:indexPath.row];
    return city;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    City *city = [self getCityByIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryView == nil) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:checkmark];
        [[Settings sharedInstance] selectCity:city];
        citiedDidChange = YES;
    }
    else {
        if([[Settings sharedInstance] getSelectedCities].count != 1) {
            cell.accessoryView = nil;
            [[Settings sharedInstance] unselectCity:city];
            citiedDidChange = YES;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (citiedDidChange) {
        if ([_settingsDelegate respondsToSelector:@selector(citiesDidChange)]) {
            [_settingsDelegate citiesDidChange];
        }
    }
}

@end
