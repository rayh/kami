#import <UIKit/UIKit.h>

@class KATrackCell;

@interface KATrackCell : UICollectionViewCell
@property (nonatomic) UIImageView *artworkImageView;
- (void)configureWithTrack:(NSDictionary*)track;
@end
