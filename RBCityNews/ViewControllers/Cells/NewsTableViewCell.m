//
//  NewsTableViewCell.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void)setCellData:(News *)newsData
{
    _cellNews = newsData;
    
    _cityLabel.text = newsData.city.name;
    _dateLabel.text = newsData.dateAsString;
    _newsTitleLabel.text = newsData.title;
}

@end
