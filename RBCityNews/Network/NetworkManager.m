//
//  NetworkManager.m
//  RBCityNews
//
//  Created by Женя Михайлова on 27.03.15.
//
//

#import "NetworkManager.h"

#define kConnectionIsAvailableNotificationName @"connectionIsAvailable"

@interface NetworkManager ()
{
    Reachability *reachability;
}
@end

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static NetworkManager * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[NetworkManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkNetworkStatus:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
    }
    return self;
}

- (BOOL)isConnectionAvailable
{
    reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        return NO;
    }
    return YES;
}

- (void)checkNetworkStatus:(NSNotification *)notification
{
    reachability = [notification object];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionIsAvailableNotificationName
                                                            object:nil
                                                          userInfo:nil];
    }
}

@end
