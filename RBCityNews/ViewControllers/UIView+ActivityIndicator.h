//
//  UIView+ActivityIndicator.h
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import <UIKit/UIKit.h>

@interface UIView (ActivityIndicator)

- (void)showActivityIndicator;
- (void)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style;
- (void)hideActivityIndicator;

@end
