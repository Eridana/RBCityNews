//
//  NewsTableViewCell.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "NewsTableViewCell.h"
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@implementation NewsTableViewCell

- (void)setCellData:(News *)newsData
{
    _cellNews = newsData;
    _cityLabel.text = newsData.city.name;
    _dateLabel.text = newsData.dateAsString;
    _newsTitleLabel.text = newsData.title;
    
    if (newsData.isNotRead == YES) {
        _todayCellColorView.backgroundColor = Rgb2UIColor(134, 226, 213);
    }
    else {
        _todayCellColorView.backgroundColor = [UIColor clearColor];
    }
}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isNotRead"]) {
        NSLog(@"cell - keypath isNotRead changed");
        BOOL val = [[change objectForKey:@"isNotRead"] boolValue];
        if (val == YES) {
            _todayCellColorView.backgroundColor = Rgb2UIColor(134, 226, 213);
        }
        else {
            [UIView animateWithDuration:1.0 animations:^{
                 _todayCellColorView.backgroundColor = [UIColor clearColor];
            }];
        }
    }
}

-(void)dealloc
{
    NSLog(@"cell dealloc remove observer");
    if ([_cellNews isKindOfClass:[News class]]) {
        [_cellNews removeObserver:self forKeyPath:@"isNotRead"];
    }
}
*/

@end
