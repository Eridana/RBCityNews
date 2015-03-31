//
//  ApiManager.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <Foundation/Foundation.h>
#import "News.h"
#import "City.h"

@protocol ApiManagerDelegate;

@interface ApiManager : NSObject

@property id<ApiManagerDelegate> apiDelegate;

- (void)loadNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities;
- (void)loaAdditionsldNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities;
- (void)loadNewsByCity:(City *)city andPage:(int)page;
- (void)loadNewsByDate:(NSDate *)date;

@end

@protocol ApiManagerDelegate <NSObject>
- (void)didReceiveNews:(NSMutableArray *)receivedNews;
- (void)loadNewsDidFailWithError:(NSString *)error;
- (void)didNotReceiveAdditionalNews;
- (void)didReceiveAdditionalNews;
@end