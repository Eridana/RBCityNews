//
//  NetworkManager.m
//  RBCityNews
//
//  Created by Женя Михайлова on 27.03.15.
//
//

#import "NetworkManager.h"

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
    __block BOOL result = NO;
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        result = YES;
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"REACHABLE!");
//        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        result = NO;
    };

    return result;
//    reachability = [Reachability reachabilityWithHostname:@"google.com"];
//    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
//    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
//    {
//        return NO;
//    }
//    return YES;
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
