//
//  City.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <Foundation/Foundation.h>

@interface City : NSObject

@property (strong, nonatomic) NSString *city_id;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL selected;

- (id)initWithId:(NSString *)cityId name:(NSString *)cityName selected:(BOOL)isSelected;
@end
