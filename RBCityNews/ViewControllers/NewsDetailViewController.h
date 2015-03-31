//
//  NewsDetailViewController.h
//  RBCityNews
//
//  Created by Женя Михайлова on 27.02.15.
//
//

#import <UIKit/UIKit.h>
#import "News.h"

@interface NewsDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *summary;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property(strong, nonatomic) News *details;

-(void)setDetails:(News *)details;
-(void)loadNewsForIndex:(NSUInteger)index;

@end