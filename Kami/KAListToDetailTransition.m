#import "KAListToDetailTransition.h"
#import "KATrackDetailViewController.h"
#import "KATrackListViewController.h"
#import "KATrackCell.h"

@interface KAListToDetailTransition ()
@property (nonatomic) BOOL reverse;
@end

@implementation KAListToDetailTransition

+ (KAListToDetailTransition *)forward
{
    return [[KAListToDetailTransition alloc] init];
}

+ (KAListToDetailTransition *)reverse
{
    KAListToDetailTransition *transition = [[KAListToDetailTransition alloc] init];
    transition.reverse = YES;
    return transition;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if(self.reverse)
        [self animateTransitionReverse:transitionContext];
    else
        [self animateTransitionForward:transitionContext];
}

- (void)animateTransitionForward:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    // Add the destination view controller
    KATrackDetailViewController *toViewController = (KATrackDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.artworkImageView.hidden = YES;
    [containerView addSubview:toViewController.view];
    
    // Get a snapshot of the cell's artwork
    UINavigationController *fromViewController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    KATrackListViewController *listViewController = (KATrackListViewController *)[fromViewController topViewController];
    NSIndexPath *selectedIndexPath = [[listViewController.collectionView indexPathsForSelectedItems] firstObject];
    UIImageView *artworkView = [(KATrackCell*)[listViewController.collectionView cellForItemAtIndexPath:selectedIndexPath] artworkImageView];
    UIView *snapshotView = [artworkView snapshotViewAfterScreenUpdates:NO];
    [containerView addSubview:snapshotView];

    // From view
    snapshotView.frame = [containerView convertRect:artworkView.frame fromView:artworkView.superview];
    
    artworkView.hidden = YES;
    // Setup the initial view states
    toViewController.view.frame = fromViewController.view.frame;
    [toViewController.view layoutIfNeeded];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapshotView.frame = [containerView convertRect:toViewController.artworkImageView.frame
                                               fromView:toViewController.artworkImageView.superview];
    } completion:^(BOOL finished) {
        artworkView.hidden = NO;
        toViewController.artworkImageView.hidden = NO;
        [snapshotView removeFromSuperview];

        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)animateTransitionReverse:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    // Add the source view controller
    KATrackDetailViewController *fromViewController = (KATrackDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.artworkImageView.hidden = YES;
    [containerView addSubview:fromViewController.view];
    
    // Get a snapshot of the cell's artwork
    UINavigationController *toViewController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    KATrackListViewController *listViewController = (KATrackListViewController *)[toViewController topViewController];
    NSIndexPath *selectedIndexPath = [[listViewController.collectionView indexPathsForSelectedItems] firstObject];
    UIImageView *artworkView = [(KATrackCell*)[listViewController.collectionView cellForItemAtIndexPath:selectedIndexPath] artworkImageView];
    UIView *snapshotView = [artworkView snapshotViewAfterScreenUpdates:NO];
    artworkView.hidden = YES;
    [containerView addSubview:snapshotView];
    
    // From view
    snapshotView.frame = [containerView convertRect:fromViewController.artworkImageView.frame
                                           fromView:fromViewController.artworkImageView.superview];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        snapshotView.frame = [containerView convertRect:artworkView.frame
                                               fromView:artworkView.superview];
        fromViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        artworkView.hidden = NO;
        fromViewController.artworkImageView.hidden = NO;
        [snapshotView removeFromSuperview];
        
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}



@end
