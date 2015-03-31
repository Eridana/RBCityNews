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

-(void)setSummary:(NSString *)summary
{
    @try {
        _summary = [self stringByStrippingHTML:summary];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    @finally {
        _summary = summary;
    }
}

- (NSString *)stringByStrippingHTML:(NSString *)htmlString
{
    NSString *newString = nil;
    newString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    newString = [htmlString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"\n"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    newString = [newString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSRange range;
    NSString *str = [newString copy];
    while ((range = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        str = [str stringByReplacingCharactersInRange:range withString:@""];
    return str;
}

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
    _dateAsString = [dateFormatter stringFromDate:_date];
}

- (NSString *)removeColonFromTimeZoneInDate:(NSString *)dateAsString {
       return [dateAsString stringByReplacingOccurrencesOfString:@":"
                                           withString:@""
                                              options:0
                                                range:NSMakeRange([dateAsString length] - 5,5)];
}

@end
