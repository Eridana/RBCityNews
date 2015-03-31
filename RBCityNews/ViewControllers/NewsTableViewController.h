//
//  NewsTableViewController.h
//  RBCityNews
//
//  Created by Женя Михайлова on 27.02.15.
//
//

#import <UIKit/UIKit.h>
#import "SettingsTableViewController.h"
#import "ApiManager.h"

@interface NewsTableViewController : UITableViewController <ApiManagerDelegate, SettingsDelegate>

@end
