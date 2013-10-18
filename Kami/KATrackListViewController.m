#import "KATrackListViewController.h"
#import "KASoundcloudService.h"
#import <UIColor-Utilities/UIColor+Expanded.h>
#import "KATrackCell.h"
#import "KATrackDetailViewController.h"
#import "KAListToDetailTransition.h"

@interface KATrackListViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic) NSArray *tracks;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation KATrackListViewController

- (id)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if(self = [super initWithCollectionViewLayout:flowLayout])
    {
        self.title = @"Mixmaster";
        self.flowLayout = flowLayout;
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 8.;
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[KATrackCell class] forCellWithReuseIdentifier:@"KATrackCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTracks) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];

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
//    return CGSizeMake(320, self.view.bounds.size.height);
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

@end
