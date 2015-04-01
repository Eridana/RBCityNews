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

const CGFloat initialTitleViewHeight = 73;

@interface NewsDetailViewController () {
    News *news;
    NSUInteger currentNewsIndex;
    NSMutableArray *displayNews;
}
@end

@implementation NewsDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loadNext:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loadPrev:)];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:rightSwipeRecognizer];
}

- (void) setDetails:(News *)details
{
    _details = details;
}

- (void)updateDetails
{
    [self.detailTitle setText:_details.title];
    float height = [self heightForLabel:_detailTitle withText:_details.title];
    if (height > _titleViewHeight.constant) {
         _titleViewHeight.constant = height;
    }
    else {
        _titleViewHeight.constant = initialTitleViewHeight;
    }
    [self.summary setText:_details.summary];
    [self.dateLabel setText:_details.dateAsString];
    if(_details.city) {
        [self.cityLabel setText:_details.city.name];
    }
    if(_details.isNotRead == YES) {
        _details.isNotRead = NO;
    }
}
                           
- (CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text{
   
   NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
   CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil];
   
   return ceil(rect.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(displayNews == nil) {
        displayNews = [[NSMutableArray alloc] init];
        [displayNews addObjectsFromArray:[[NewsHelper sharedInstance].newsByCities objectForKey:_details.city.city_id]];
        currentNewsIndex = [displayNews indexOfObject:_details];
    }
    
    [self performSelectorOnMainThread:@selector(updateDetails)  withObject:nil waitUntilDone:YES];
}

- (IBAction)goToNew:(id)sender {
    if([_details.legacy_url description]) {
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[_details.legacy_url description]];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (IBAction)loadNext:(UISwipeGestureRecognizer *)gesture
{
    currentNewsIndex++;
    if(currentNewsIndex ==  [displayNews count]) {
        currentNewsIndex = 0;
    }
    [self loadNewsForIndex:currentNewsIndex];
}

- (IBAction)loadPrev:(UISwipeGestureRecognizer *)gesture
{
    currentNewsIndex--;
    if(currentNewsIndex == -1) {
        currentNewsIndex = [displayNews count] - 1;
    }
    [self loadNewsForIndex:currentNewsIndex];
}

- (void)loadNewsForIndex:(NSUInteger)index
{
    if(index < [displayNews count]) {
        _details = displayNews[index];
        [self performSelectorOnMainThread:@selector(updateDetails)  withObject:nil waitUntilDone:YES];
       
        /*
    [UIView transitionWithView:self.view duration:0.25 options:(UIViewAnimationOptionTransitionFlipFromRight) //(UIViewAnimationOptionTransitionFlipFromRight)
                    animations:^{
                        
                    }
                    completion:NULL];
         */
    }
}

@end
