//
//  Settings.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <Foundation/Foundation.h>
#import "City.h"
#import "News.h"

@interface Settings : NSObject

+ (Settings *)sharedInstance;

@property (strong, nonatomic) NSMutableArray *allCities;

- (NSMutableArray *)getSelectedCities;
- (City *)getCityById:(NSString *)byId;
- (void)selectCity:(City *)city;
- (void)unselectCity:(City *)city;

- (void)saveCities;

@end
