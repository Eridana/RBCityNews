//
//  NewsHelper.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <Foundation/Foundation.h>
#import "News.h"
#import "City.h"

@interface NewsHelper : NSObject

@property (strong, nonatomic) NSMutableDictionary *newsByCities;
+ (NewsHelper *)sharedInstance;

- (void)setNews:(NSArray *)news;
- (NSArray *)getNewsByCity:(City *)city;
- (BOOL) containsNews:(News *)news;

@end
