//
//  NetworkManager.h
//  RBCityNews
//
//  Created by Женя Михайлова on 27.03.15.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedInstance;
- (BOOL)isConnectionAvailable;

@end
