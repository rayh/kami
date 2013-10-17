#import "UIImage+KAUtilities.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (KAUtilities)
- (UIImage *)cropToTopHalf
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height/2);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)applyArtworkImageEffects
{
    CIImage *beginImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    [filter setValue:@(1.) forKey:kCIInputRadiusKey];
    [filter setValue:@(1) forKey:kCIInputIntensityKey];
    
    CIImage *outputImage = [filter outputImage];
    UIImage *finalImage = [UIImage imageWithCIImage:outputImage];
    return finalImage;
}

- (UIImage*)rotateAboutPoint
{
    CIImage *beginImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CICircularWrap"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    
    CIImage *outputImage = [filter outputImage];
    UIImage *finalImage = [UIImage imageWithCIImage:outputImage];
    return finalImage;
}

@end
