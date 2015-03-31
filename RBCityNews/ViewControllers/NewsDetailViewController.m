//
//  NewsDetailViewController.m
//  RBCityNews
//
//  Created by Женя Михайлова on 27.02.15.
//
//

#import "NewsDetailViewController.h"
#import "Settings.h"
#import "NewsHelper.h"
#import "SVWebViewController.h"

@interface NewsDetailViewController () {
    News *news;
    NSUInteger currentNewsIndex;
    NSMutableArray *displayNews;
}
@end

@implementation NewsDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loadNext:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:leftSwipeRecognizer];
    
//    displayNews = [[NSMutableArray alloc] init];
//    
//    NSMutableArray *selectedCities = [[Settings sharedInstance] getSelectedCities];
//    for (City *city in selectedCities) {
//        [displayNews addObjectsFromArray: [[NewsHelper sharedInstance] getNewsByCity:city]];
//    }
//    
//    currentNewsIndex = 0;
    
    [self updateDetails];
}

-(void) setDetails:(News *)details
{
    _details = details;
}

-(void)updateDetails
{
//    if(!displayNews) {
//        [self viewDidLoad];
//    }
//    else {
//        currentNewsIndex = [displayNews indexOfObjectIdenticalTo: _details];
//    }
    [self.detailTitle setText:_details.title];
    [self.summary setText:_details.summary];
    [self.dateLabel setText:_details.dateAsString];
    if(_details.city) {
        [self.cityLabel setText:_details.city.name];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelectorOnMainThread:@selector(updateDetails)  withObject:nil waitUntilDone:YES];
}

- (IBAction)goToNew:(id)sender {
    if([_details.legacy_url description]) {
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[_details.legacy_url description]];
        [self.navigationController pushViewController:webViewController animated:YES];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: [_details.legacy_url description]]];
    }
}

-(IBAction)loadNext:(UISwipeGestureRecognizer *)gesture
{
    [self loadNewsForIndex:currentNewsIndex];
    if(currentNewsIndex ==  [displayNews count] - 1) {
        currentNewsIndex = 0;
    }
    currentNewsIndex++;
}

-(void)loadNewsForIndex:(NSUInteger)index
{
    if(index < [displayNews count]) {
        [self setDetails:displayNews[index]];
    }
}

@end
