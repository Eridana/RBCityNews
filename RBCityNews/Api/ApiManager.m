//
//  ApiManager.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "ApiManager.h"
#import "NewsHelper.h"
#import "Settings.h"
#import <Foundation/Foundation.h>

static NSString * const apiSourceUrl = @"http://rbcitynews.ru/api/v1/cities/%@/news.json";

@implementation ApiManager

- (void)loadNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities
{
    NSArray *cities = [[Settings sharedInstance] getSelectedCities];
    for (City *city in cities) {
        int page = (int)[[pagesByCities objectForKey:city.city_id] integerValue];
        [self loadNewsByCity:city andPage:page];
        /*
        NSString *url = [NSString stringWithFormat:apiSourceUrl, city.city_id];
        NSString *paramsUrl = [NSString stringWithFormat:@"%@?page=%d", url, page];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:paramsUrl]];
        [request setHTTPMethod:@"GET"];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (error != nil) {
                            // error
                            NSLog(@"error %@", [error description]);
                            [self loadNewsDidFailWithError:[error description]];
                        }
                        else {
                            // parse results
                            NSError *parsingError = nil;
                            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
                            
                            if (parsingError != nil) {
                                [self loadNewsDidFailWithError:[parsingError description]];
                            }
                            
                            else {
                                NSMutableArray *news = [self parseNews:response];
                                [[NewsHelper sharedInstance] setNews:news];
                                if ([_apiDelegate respondsToSelector:@selector(didReceiveNews:)]) {
                                    [_apiDelegate didReceiveNews:news];
                                }
                            }
                        }
                    }] resume];
         */
    } // end of for
}

- (void)loadNewsByCity:(City *)city andPage:(int)page
{
    NSString *url = [NSString stringWithFormat:apiSourceUrl, city.city_id];
    NSString *paramsUrl = [NSString stringWithFormat:@"%@?page=%d", url, page];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:paramsUrl]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error != nil) {
                        // error
                        NSLog(@"error %@", [error description]);
                        [self loadNewsDidFailWithError:[error description]];
                    }
                    else {
                        // parse results
                        NSError *parsingError = nil;
                        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
                        
                        if (parsingError != nil) {
                            [self loadNewsDidFailWithError:[parsingError description]];
                        }
                        
                        else {
                            NSMutableArray *news = [self parseNews:response];
                            [[NewsHelper sharedInstance] setNews:news];
                            if ([_apiDelegate respondsToSelector:@selector(didReceiveNews:)]) {
                                [_apiDelegate didReceiveNews:news];
                            }
                        }
                    }
                }] resume];
}

- (void)loaAdditionsldNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities
{
    NSArray *cities = [[Settings sharedInstance] getSelectedCities];
    for (City *city in cities) {
        int page = (int)[[pagesByCities objectForKey:city.city_id] integerValue];
        
        NSString *url = [NSString stringWithFormat:apiSourceUrl, city.city_id];
        NSString *paramsUrl = [NSString stringWithFormat:@"%@?page=%d", url, page];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:paramsUrl]];
        [request setHTTPMethod:@"GET"];
         
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
         
        [[session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             if (error != nil) {
                 // error
                 NSLog(@"error %@", [error description]);
                 [self loadNewsDidFailWithError:[error description]];
             }
             else {
                 // parse results
                 NSError *parsingError = nil;
                 NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
                 
                 if (parsingError != nil) {
                     [self loadNewsDidFailWithError:[parsingError description]];
                 }
                 
                 else {
                     NSMutableArray *news = [self parseNews:response];
                     if ([[NewsHelper sharedInstance] containsNews:[news firstObject]] == YES) {
                         // нет новых новостей
                         if ([_apiDelegate respondsToSelector:@selector(didNotReceiveAdditionalNews)]) {
                             [_apiDelegate didNotReceiveAdditionalNews];
                         }
                     }
                     else {
                         [[NewsHelper sharedInstance] setNews:news];
                         if ([_apiDelegate respondsToSelector:@selector(didReceiveAdditionalNews)]) {
                             [_apiDelegate didReceiveAdditionalNews];
                         }
                     }
                 }
             }
         }] resume];
    } // end of for
}

/**
 Загружает все новости по городу на заданную дату (с 00:00 до 23:59)
 */
- (void)loadNewsByCity:(City *)city andDate:(NSDate *)date
{
    NSString *url = [NSString stringWithFormat:apiSourceUrl, city.city_id];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];// HH:mm"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *more = [NSString stringWithFormat:@"%@ 00:00", dateStr];
    NSString *less = [NSString stringWithFormat:@"%@ 23:59", dateStr];
    
    NSString *paramsUrl = [NSString stringWithFormat: @"http://rbcitynews.ru/api/v1/cities/%@/news.json?published_at_more='%@'&published_at_less='%@'", url, more, less];
    paramsUrl = [paramsUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    paramsUrl = [paramsUrl stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:paramsUrl]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error != nil) {
                        // error
                        NSLog(@"error %@", [error description]);
                        [self loadNewsDidFailWithError:[error description]];
                    }
                    else {
                        // parse results
                        NSError *parsingError = nil;
                        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
                        
                        if (parsingError != nil) {
                            [self loadNewsDidFailWithError:[parsingError description]];
                        }
                        
                        else {
                            NSMutableArray *news = [self parseNews:response];
                            [[NewsHelper sharedInstance] setNews:news];
                            if ([_apiDelegate respondsToSelector:@selector(didReceiveNews:)]) {
                                [_apiDelegate didReceiveNews:news];
                            }
                        }
                    }
    }] resume];
}

- (NSMutableArray *)parseNews:(NSDictionary *)response
{
    NSMutableArray *news = [[NSMutableArray alloc] init];
    
    NSArray *results = [response valueForKey:@"news"];
    
    for (NSDictionary *newsDic in results) {
        News *new = [[News alloc] init];
        for (NSString *key in newsDic) {
            if([key isEqualToString:@"id"]) {
                [new setValue:[newsDic valueForKey:key] forKey:@"news_id"];
            }
            if ([key isEqualToString:@"city_id"]) {
                NSString *cityId = [NSString stringWithFormat:@"%ld", [[newsDic valueForKey:key] longValue]];
                City *city = [[Settings sharedInstance] getCityById:cityId];
                new.city = city;
            }
            if ([new respondsToSelector:NSSelectorFromString(key)]) {
                if([newsDic objectForKey:key] != [NSNull null]) {
                    [new setValue:[newsDic valueForKey:key] forKey:key];
                }
            }
        }
        [news addObject:new];
    }
    
    return news;
    
}

- (void)loadNewsDidFailWithError:(NSString *)error
{
    NSLog(@"loadNewsDidFailWithError %@", error);
    if ([_apiDelegate respondsToSelector:@selector(loadNewsDidFailWithError:)]) {
        [_apiDelegate loadNewsDidFailWithError:error];
    }
}

@end
