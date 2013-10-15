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
@end

@implementation KATrackListViewController

- (id)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if(self = [super initWithCollectionViewLayout:flowLayout])
    {
        self.title = @"神";
        self.flowLayout = flowLayout;
        self.flowLayout.itemSize = CGSizeMake(150, 210.);
        self.flowLayout.minimumLineSpacing = 10;
        self.flowLayout.minimumInteritemSpacing = 8.;
        self.flowLayout.sectionInset = UIEdgeInsetsMake(10., 6., 10., 6.);
        
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(logoutSelected:)];
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[KATrackCell class] forCellWithReuseIdentifier:@"KATrackCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTracks) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
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
    KATrackDetailViewController *detailViewController = [[KATrackDetailViewController alloc] initWithTrack:track];
    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
    detailViewController.transitioningDelegate = self;
//    detailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:detailViewController animated:YES completion:nil];
    
//    NSString *songId = [track valueForKeyPath:@"origin.id"];
//    NSURL *mobileAppUrl = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:track:%@", songId]];
//    NSURL *mobileWebsiteUrl = [NSURL URLWithString:[track valueForKeyPath:@"origin.permalink_url"]];
//    
//    if([[UIApplication sharedApplication] canOpenURL:mobileAppUrl])
//       [[UIApplication sharedApplication] openURL:mobileAppUrl];
//    else
//        [[UIApplication sharedApplication] openURL:mobileWebsiteUrl];
    
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return [[KAListToDetailTransition alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return nil;
}

@end
