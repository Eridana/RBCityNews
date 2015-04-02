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
#import "NSString+HTML.h"

static NSString * const apiSourceUrl = @"http://rbcitynews.ru/api/v1/cities/%@/news.json";

@implementation ApiManager

- (void)loadNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities
{
    NSArray *cities = [[Settings sharedInstance] getSelectedCities];
    for (City *city in cities) {
        int page = (int)[[pagesByCities objectForKey:city.city_id] integerValue];
        [self loadNewsByCity:city andPage:page];
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
                            [[NewsHelper sharedInstance] sortNewsByDate];
                            if ([_apiDelegate respondsToSelector:@selector(didReceiveNews:)]) {
                                [_apiDelegate didReceiveNews:news];
                            }
                        }
                    }
                }] resume];
}

- (void)loadAdditionalNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities
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
                         if ([_apiDelegate respondsToSelector:@selector(didReceiveAdditionalNews:)]) {
                             [_apiDelegate didReceiveAdditionalNews:news];
                         }
                     }
                 }
             }
         }] resume];
    } // end of for
}

- (void)loadAdditionalNewsByDatesAndCities:(NSMutableDictionary *)datesByCities
{
    NSArray *cities = [[Settings sharedInstance] getSelectedCities];
    for (City *city in cities) {
        NSString *dateString = [datesByCities objectForKey:city.city_id];
        if (dateString.length == 0) {
            if ([_apiDelegate respondsToSelector:@selector(didNotReceiveAdditionalNews)]) {
                NSLog(@"dateString is empty, no additional news for : %@", dateString);
                [_apiDelegate didNotReceiveAdditionalNews];
            }
        }
        NSLog(@"loadAdditionalNewsByDatesAndCities: city=%@, %@", city.name, dateString);
        NSString *paramsUrl = [NSString stringWithFormat: @"http://rbcitynews.ru/api/v1/cities/%@/news.json?published_at_more='%@'", city.city_id, dateString];
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
                            
                            if (response == nil) {
                                if ([_apiDelegate respondsToSelector:@selector(didNotReceiveAdditionalNews)]) {
                                    NSLog(@"no additional news for : %@", dateString);
                                    [_apiDelegate didNotReceiveAdditionalNews];
                                }
                            }
                            else if (parsingError != nil) {
                                [self loadNewsDidFailWithError:[parsingError description]];
                            }
                            
                            else {
                                NSMutableArray *news = [self parseNews:response];
                                if (news.count > 0) {
                                    for (News *new in news) {
                                        new.isNotRead = YES;
                                    }
                                    [[NewsHelper sharedInstance] setAdditionalNews:news];
                                    //                                    [[NewsHelper sharedInstance] sortNewsByDate];
                                    if ([_apiDelegate respondsToSelector:@selector(didReceiveAdditionalNews:)]) {
                                        NSLog(@"%ld additional news for : %@", news.count, dateString);
                                        [_apiDelegate didReceiveAdditionalNews:news];
                                    }
                                }
                                else {
                                    if ([_apiDelegate respondsToSelector:@selector(didNotReceiveAdditionalNews)]) {
                                        NSLog(@"no additional news for : %@", dateString);
                                        [_apiDelegate didNotReceiveAdditionalNews];
                                    }
                                    
                                }
                            }
                        }
                    }] resume];
    }
}

- (void)loadAdditionalNewsByDateString:(NSString *)dateString
{
    NSLog(@"loadAdditionalNewsByDateString: %@", dateString);
    NSArray *cities = [[Settings sharedInstance] getSelectedCities];
    for (City *city in cities) {
        NSString *paramsUrl = [NSString stringWithFormat: @"http://rbcitynews.ru/api/v1/cities/%@/news.json?published_at_more='%@'", city.city_id, dateString];
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
                            
                            if (response == nil) {
                                if ([_apiDelegate respondsToSelector:@selector(didNotReceiveAdditionalNews)]) {
                                     NSLog(@"no additional news for : %@", dateString);
                                    [_apiDelegate didNotReceiveAdditionalNews];
                                }
                            }
                            else if (parsingError != nil) {
                                [self loadNewsDidFailWithError:[parsingError description]];
                            }
                            
                            else {
                                NSMutableArray *news = [self parseNews:response];
                                if (news.count > 0) {
                                    for (News *new in news) {
                                        new.isNotRead = YES;
                                    }
                                    [[NewsHelper sharedInstance] setAdditionalNews:news];
//                                    [[NewsHelper sharedInstance] sortNewsByDate];
                                    if ([_apiDelegate respondsToSelector:@selector(didReceiveAdditionalNews:)]) {
                                        NSLog(@"%ld additional news for : %@", news.count, dateString);
                                        [_apiDelegate didReceiveAdditionalNews:news];
                                    }
                                }
                                else {
                                    if ([_apiDelegate respondsToSelector:@selector(didNotReceiveAdditionalNews)]) {
                                        NSLog(@"no additional news for : %@", dateString);
                                        [_apiDelegate didNotReceiveAdditionalNews];
                                    }

                                }
                            }
                        }
        }] resume];
    }
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
                continue;
            }
            if ([key isEqualToString:@"city_id"]) {
                NSString *cityId = [NSString stringWithFormat:@"%ld", [[newsDic valueForKey:key] longValue]];
                City *city = [[Settings sharedInstance] getCityById:cityId];
                new.city = city;
                continue;
            }
            if ([key isEqualToString:@"summary"]) {
                NSString *summary = [newsDic valueForKey:key];
                summary = [self stringByStrippingHTML:summary];
                new.summary = [summary kv_decodeHTMLCharacterEntities];
                continue;
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

- (NSString *)stringByStrippingHTML:(NSString *)htmlString
{
    NSString *newString = nil;
    newString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    newString = [htmlString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"\n"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    NSRange range;
    NSString *str = [newString copy];
    while ((range = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        str = [str stringByReplacingCharactersInRange:range withString:@""];
    return str;
}

- (void)loadNewsDidFailWithError:(NSString *)error
{
    NSLog(@"loadNewsDidFailWithError %@", error);
    if ([_apiDelegate respondsToSelector:@selector(loadNewsDidFailWithError:)]) {
        [_apiDelegate loadNewsDidFailWithError:error];
    }
}

@end
