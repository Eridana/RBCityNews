//
//  City.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "City.h"

@implementation City

- (id)initWithId:(NSString *)cityId name:(NSString *)cityName selected:(BOOL)isSelected
{
    self = [super init];
    if (self) {
        _city_id = cityId;
        _name = cityName;
        _selected = isSelected;
    }
    return self;
}

@end
