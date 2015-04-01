//
//  News.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "News.h"
#import "Settings.h"

@implementation News

- (void)setPublished_at:(NSString *)published_at
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    published_at =[self removeColonFromTimeZoneInDate:published_at];
    _date= [dateFormatter dateFromString:published_at];
    
     NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    dateFormatter.doesRelativeDateFormatting = YES;
    _dateAsString = [dateFormatter stringFromDate:_date];
}

- (NSString *)removeColonFromTimeZoneInDate:(NSString *)dateAsString {
       return [dateAsString stringByReplacingOccurrencesOfString:@":"
                                           withString:@""
                                              options:0
                                                range:NSMakeRange([dateAsString length] - 5,5)];
}

@end
