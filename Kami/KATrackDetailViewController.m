#import "KATrackDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface KATrackDetailViewController () <UIScrollViewDelegate>
@property (nonatomic) NSDictionary *track;
@property (nonatomic) UIToolbar *backgroundView;
@property (nonatomic) UIScrollView *scrollView;
@end

@implementation KATrackDetailViewController

- (id)initWithTrack:(NSDictionary *)dict;
{
    if(self = [super init])
    {
        self.track = dict;
    }

    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
 
    self.backgroundView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.backgroundView.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.backgroundView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    self.artworkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.artworkImageView.clipsToBounds = YES;
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.track[@"artwork_url"]]];
    [self.scrollView addSubview:self.artworkImageView];
}

- (void)viewDidLayoutSubviews
{
    self.backgroundView.frame = self.view.bounds;
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = self.view.bounds.size;
    
    self.artworkImageView.frame = CGRectMake(10, 100, 300, 200);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"vertical offset %0.2f", scrollView.contentOffset.y);
    if(scrollView.contentOffset.y<0)
    {
        self.backgroundView.alpha = 1 - scrollView.contentOffset.y/-200;
    }
    else
    {
        self.backgroundView.alpha = 1.;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.contentOffset.y>-100)
        return;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
@end
