#import <UIKit/UIKit.h>

@interface KATrackCell : UICollectionViewCell
@property (nonatomic) UIImageView *artworkImageView;
- (void)configureWithTrack:(NSDictionary*)track;
@end
