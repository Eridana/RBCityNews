//
//  News.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <Foundation/Foundation.h>
#import "City.h"

@interface News : NSObject

@property (strong, nonatomic) NSString *news_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *city_id;
@property (strong, nonatomic) City *city;
@property (strong, nonatomic) NSString *published_at;
@property (strong, nonatomic) NSString *legacy_url;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *dateAsString;

@end
