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

- (UIImage*)rotateAboutPoint
{
//    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *beginImage = [CIImage imageWithCGImage:self.CGImage];
    
    NSLog(@"Effects in %@", [CIFilter filterNamesInCategory:kCICategoryDistortionEffect]);
    
    CIFilter *filter = [CIFilter filterWithName:@"CICircularWrap"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
//    [filter setValue:[CIVector vectorWithX:self.size.width/2. Y:-self.size.height] forKey:kCIInputCenterKey];
//    [filter setValue:@(self.size.width/(M_PI)) forKey:kCIInputRadiusKey];
//    [filter setValue:@(M_PI*2) forKey:kCIInputAngleKey];
    
    CIImage *outputImage = [filter outputImage];
//    CGImageRef cgImgRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *finalImage = [UIImage imageWithCIImage:outputImage];
//    CGImageRelease(cgImgRef);
    return finalImage;
}

@end
