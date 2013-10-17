#import "UIImageView+KAUtilities.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation UIImageView (KAUtilities)

- (void)setImageWithURLString:(NSString*)urlString mutate:(UIImage *(^)(UIImage *image))mutateBlock
{
    __weak UIImageView *weakSelf = self;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self setImageWithURLRequest:request
                placeholderImage:nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 UIImage *mutatedImage = mutateBlock(image);
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     UIImageView *strongSelf = weakSelf;
                                     if(strongSelf)
                                         strongSelf.image = mutatedImage;
                                 });
                             });
                       } failure:nil];
}
@end
