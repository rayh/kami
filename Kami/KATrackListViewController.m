#import "KATrackListViewController.h"
#import "KASoundcloudService.h"
#import <UIColor-Utilities/UIColor+Expanded.h>
#import "KATrackCell.h"
#import "KATrackDetailViewController.h"
#import "KAListToDetailTransition.h"
#import <EnumeratorKit/EnumeratorKit.h>

@interface KATrackListViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic) NSArray *tracks;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIActivityIndicatorView *loadingView;
@property (nonatomic) UIToolbar *overlayView;
@property (nonatomic) UIView *navigationBarBackgroundView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic, readonly) KATrackCell *centreCell;
@end

@implementation KATrackListViewController

- (id)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if(self = [super initWithCollectionViewLayout:flowLayout])
    {
        self.title = @"Kami";
        self.flowLayout = flowLayout;
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 0.;
        self.flowLayout.sectionInset = UIEdgeInsetsZero;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(logoutSelected:)];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[KATrackCell class] forCellWithReuseIdentifier:@"KATrackCell"];
        
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTracks) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
    
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.collectionView.backgroundView addSubview:self.backgroundImageView];

    self.overlayView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.overlayView.barStyle = UIBarStyleBlack;
    [self.collectionView.backgroundView addSubview:self.overlayView];

    self.navigationBarBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationBarBackgroundView.backgroundColor = [[UIColor colorWithRGBHex:0xf0570c] colorWithAlphaComponent:0.7];
    [self.collectionView.backgroundView addSubview:self.navigationBarBackgroundView];
    
    UIInterpolatingMotionEffect *horizontalShift = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalShift.maximumRelativeValue=@(10);
    horizontalShift.minimumRelativeValue=@(-10);
    
    UIInterpolatingMotionEffect *verticalShift = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalShift.maximumRelativeValue=@(10);
    verticalShift.minimumRelativeValue=@(-10);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[horizontalShift, verticalShift];
    [self.backgroundImageView addMotionEffect:group];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTracks];
}

#pragma mark - Actions

- (void)reloadTracks
{
    [self.refreshControl beginRefreshing];
    [[[KASoundcloudService sharedInstance] fetchStream] subscribeNext:^(NSArray *tracks) {
        self.tracks = tracks;
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
        [self.loadingView stopAnimating];
    } error:^(NSError *error) {
        NSLog(@"Unable to fetch data: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"Unable to talk to SoundCloud"
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)logoutSelected:(id)sender
{
    // Log the user out
    [[KASoundcloudService sharedInstance] logout];
    
    // Clear the loaded tracks
    self.tracks = @[];
    [self.collectionView reloadData];
    
    // Force re-autentication
    [self reloadTracks];
}

- (void)viewDidLayoutSubviews
{
    self.loadingView.center = CGPointMake(self.view.bounds.size.width/2., self.view.bounds.size.height/2.);
    self.overlayView.frame = self.view.bounds;
    self.backgroundImageView.frame = CGRectInset(self.view.bounds, 60, 60);
    self.navigationBarBackgroundView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateBackgroundImage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateBackgroundImage];
}

#pragma mark - Centre Cell Calculation

- (void)updateBackgroundImage
{
    KATrackCell *cell = [[[self.collectionView visibleCells] sortBy:^id(KATrackCell *cell) {
        return @([self proportionOfScreenTakenUpByCell:cell]);
    }] lastObject];
    
    CGFloat proportion = [self proportionOfScreenTakenUpByCell:cell];
    self.backgroundImageView.image = self.centreCell.artworkImageView.image;
    self.backgroundImageView.alpha = (proportion-0.5)*2;
    NSLog(@"cell %@ is ar %0.2f", cell, proportion);
}

- (CGFloat)proportionOfScreenTakenUpByCell:(KATrackCell *)cell
{
    CGRect intersection = CGRectIntersection([self.collectionView convertRect:self.view.bounds fromView:self.view], cell.frame);
    CGFloat proportion = intersection.size.width/self.view.bounds.size.width;
    return proportion;
}

- (KATrackCell *)centreCell
{
    NSIndexPath *centreIndexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:CGPointMake(self.view.bounds.size.width/2.,
                                                                                                                              self.view.bounds.size.height/2.)
                                                                                                         fromView:self.view]];
    KATrackCell *cell = (KATrackCell *)[self.collectionView cellForItemAtIndexPath:centreIndexPath];
    return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KATrackCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KATrackCell" forIndexPath:indexPath];
    [cell configureWithTrack:[self.tracks objectAtIndex:indexPath.row]];
    [cell addObserver:self forKeyPath:@"artworkImageView.image" options:NSKeyValueObservingOptionNew context:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    NSString *songId = [track valueForKeyPath:@"id"];
    NSURL *mobileAppUrl = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:track:%@", songId]];
    NSURL *mobileWebsiteUrl = [NSURL URLWithString:[track valueForKeyPath:@"permalink_url"]];
    
    if([[UIApplication sharedApplication] canOpenURL:mobileAppUrl])
       [[UIApplication sharedApplication] openURL:mobileAppUrl];
    else
        [[UIApplication sharedApplication] openURL:mobileWebsiteUrl];
    
    
// Disabled potential detail view
//    KATrackDetailViewController *detailViewController = [[KATrackDetailViewController alloc] initWithTrack:nil];
//    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
//    detailViewController.transitioningDelegate = self;
//    [self presentViewController:detailViewController animated:NO completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:^(BOOL finished) {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return self.view.bounds.size;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return [KAListToDetailTransition forward];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [KAListToDetailTransition reverse];
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval)         duration
{
    [UIView animateWithDuration:duration animations:^{
         CGPoint newContentOffset = CGPointMake(self.collectionView.contentOffset.x *
                                                self.collectionView.contentSize.height,
                                                self.collectionView.contentOffset.y *
                                                self.collectionView.contentSize.width);
         [self.collectionView setContentOffset:newContentOffset animated:YES];
     }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

@end
