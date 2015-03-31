//
//  NewsHelper.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "NewsHelper.h"
#import "Settings.h"

@implementation NewsHelper

+ (NewsHelper *)sharedInstance
{
    static NewsHelper * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[NewsHelper alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _newsByCities = [[NSMutableDictionary alloc] init];
        for (City *city in [Settings sharedInstance].allCities) {
            [_newsByCities setObject:[[NSMutableArray alloc] init] forKey:city.city_id];
        }
    }
    return self;
}

- (void)setNews:(NSArray *)news
{
    // проверять на повторения
    for (News* new in news) {
        if ([self containsNews:new] == NO) {
            if (new.city != nil) {
                City *city = new.city;
                NSMutableArray *array = [_newsByCities objectForKey:city.city_id];
                if (array != nil) {
                    [array addObject:new];
                }
            }
        }
    }
}

- (NSMutableArray *)sortNewsByDate:(NSMutableArray *)array
{
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"date"
                                        ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    return [[array sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

- (void)setAdditionalNews:(NSArray *)news
{
    [self setNews:news];
}

- (NSArray *)getNewsByCity:(City *)city
{
    NSMutableArray *result = [_newsByCities objectForKey:city.city_id];
    result = [self sortNewsByDate:result];
    return result;
}

- (BOOL)containsNews:(News *)news
{
    if(news && news.news_id) {
        NSArray *newsArray = [_newsByCities objectForKey:news.city.city_id];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"news_id", news.news_id];
        NSArray *resultsArray = [newsArray filteredArrayUsingPredicate:predicate];
        return resultsArray.count > 0;
    }
    return NO;
}

@end
