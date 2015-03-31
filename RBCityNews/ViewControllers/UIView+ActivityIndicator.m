//
//  UIView+ActivityIndicator.m
//  RBCityNews
//
//  Created by Женя Михайлова on 19.03.15.
//
//

#import "UIView+ActivityIndicator.h"

@implementation UIView (ActivityIndicator)

- (void)showActivityIndicator {
    [self showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray];
}

- (void)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle) style {
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    view.layer.opacity = 0.5;
    view.tag = 1001;
    [self addSubview:view];
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: style];
    
    indicator.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    
    indicator.tag = 1002;
    indicator.center = view.center;
    [indicator startAnimating];
    
    [self addSubview:indicator];
}

- (void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self viewWithTag:1001] removeFromSuperview];
        [[self viewWithTag:1002] removeFromSuperview];
    });
}

@end
