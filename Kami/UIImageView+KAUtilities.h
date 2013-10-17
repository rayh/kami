#import <UIKit/UIKit.h>

@interface UIImageView (KAUtilities)
- (void)setImageWithURLString:(NSString*)urlString mutate:(UIImage *(^)(UIImage *image))mutateBlock;
@end
