#import <Foundation/Foundation.h>

@interface KAListToDetailTransition : NSObject <UIViewControllerAnimatedTransitioning>
+ (KAListToDetailTransition *)forward;
+ (KAListToDetailTransition *)reverse;
@end
