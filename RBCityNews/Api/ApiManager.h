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
- (void)loadAdditionalNewsByCitiesAndPages:(NSMutableDictionary *)pagesByCities;
- (void)loadNewsByCity:(City *)city andPage:(int)page;
- (void)loadAdditionalNewsByDateString:(NSString *)dateString;

@end

@protocol ApiManagerDelegate <NSObject>
- (void)didReceiveNews:(NSMutableArray *)receivedNews;
- (void)loadNewsDidFailWithError:(NSString *)error;
- (void)didNotReceiveAdditionalNews;
- (void)didReceiveAdditionalNews:(NSMutableArray *)receivedNews;
@end