//
//  SettingsTableViewController.h
//  RBCityNews
//
//  Created by Женя Михайлова on 27.02.15.
//
//

#import <UIKit/UIKit.h>

@protocol SettingsDelegate;

@interface SettingsTableViewController : UITableViewController
@property (weak, nonatomic) id <SettingsDelegate> settingsDelegate;
@end

@protocol SettingsDelegate <NSObject>
- (void)citiesDidChange;
@end

