//
//  Settings.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "Settings.h"

@implementation Settings

+ (Settings *)sharedInstance
{
    static Settings * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Settings alloc] init];
    });
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        [self initializeAllCities];
    }
    return self;
}

- (void)initializeAllCities
{
    _allCities = [[self getCitiesArray] mutableCopy];
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    for (City *city in _allCities) {
        if([currentDefaults objectForKey:city.city_id]) {
            city.selected = [[currentDefaults objectForKey:city.city_id] boolValue];
        }
    }
}


- (NSArray *)getCitiesArray
{
    return
    @[
        [[City alloc] initWithId: @"4" name: @"Уфа"         selected: YES],
        [[City alloc] initWithId: @"7" name: @"Белебей"     selected: YES],
        [[City alloc] initWithId: @"1" name: @"Ишимбай"     selected: YES],
        [[City alloc] initWithId: @"5" name: @"Нефтекамск"  selected: YES],
        [[City alloc] initWithId: @"8" name: @"Октябрьский" selected: YES],
        [[City alloc] initWithId: @"2" name: @"Салават"     selected: YES],
        [[City alloc] initWithId: @"3" name: @"Стерлитамак" selected: YES]
    ];
}


- (void)saveCities
{
    for (City *city in _allCities) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:city.selected] forKey:city.city_id];
    }
}

- (NSArray *) getSelectedCities
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (City *city in _allCities) {
        if(city && city.selected == YES) {
            [result addObject:city];
        }
    }
    return result;
}


- (City *)getCityById:(NSString *)byId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city_id == %@", byId];
    NSArray *resultsArray = [_allCities filteredArrayUsingPredicate:predicate];
    return [resultsArray lastObject];
}


- (void)selectCity:(City *)city
{
    city.selected = YES;
    [self saveCities];
}


- (void)unselectCity:(City *)city
{
    city.selected = NO;
    [self saveCities];
}

@end
