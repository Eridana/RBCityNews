//
//  NewsTableViewCell.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <UIKit/UIKit.h>
#import "News.h"

@interface NewsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UIView *todayCellColorView;
@property (strong, nonatomic) News *cellNews;

- (void)setCellData:(News *)newsData;

@end
