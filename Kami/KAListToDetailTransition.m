#import "KAListToDetailTransition.h"
#import "KATrackDetailViewController.h"
#import "KATrackListViewController.h"
#import "KATrackCell.h"

@implementation KAListToDetailTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    KATrackDetailViewController *toViewController = (KATrackDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [containerView addSubview:toViewController.view];
    
    UINavigationController *fromViewController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    KATrackListViewController *listViewController = (KATrackListViewController *)[fromViewController topViewController];
    NSIndexPath *selectedIndexPath = [[listViewController.collectionView indexPathsForSelectedItems] firstObject];
    UIImageView *artworkView = [(KATrackCell*)[listViewController.collectionView cellForItemAtIndexPath:selectedIndexPath] artworkImageView];
    UIView *snapshotView = [artworkView snapshotViewAfterScreenUpdates:NO];
    [containerView addSubview:snapshotView];

    // From view
    snapshotView.frame = [containerView convertRect:artworkView.frame fromView:artworkView.superview];
    
    // Setup the initial view states
    toViewController.view.frame = fromViewController.view.frame;
    toViewController.view.alpha = 0;
    [toViewController.view layoutIfNeeded];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapshotView.frame = CGRectMake(40, 80, CGRectGetWidth(toViewController.view.frame)-80., CGRectGetWidth(toViewController.view.frame)-80.);
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
