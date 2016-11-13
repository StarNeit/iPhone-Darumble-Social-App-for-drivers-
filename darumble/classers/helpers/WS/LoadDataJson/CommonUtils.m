//
//  CommonUtils.m
//  Sufi
//
//  Created by KeHo on 2/21/13.
//  Copyright (c) 2013 KGP. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

/*----------------------------------------------------------------------------
 Method:      Image Stretch By Width
 -----------------------------------------------------------------------------*/
+ (UIImage *)imageStretchForWidth: (NSString *)filename {
    UIImage *img = [UIImage imageNamed: filename];
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
}

/*----------------------------------------------------------------------------
 Method:      Image Stretch By Height
 -----------------------------------------------------------------------------*/
+ (UIImage *)imageStretchForHeight: (NSString *)filename {
    
    UIImage *img = [UIImage imageNamed: filename];
    //    return [img stretchableImageWithLeftCapWidth: 0 topCapHeight: img.size.height / 2];
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(4, 0, 4, 0)];
}


/*----------------------------------------------------------------------------
 Method:      Image Stretch By Width & Height
 -----------------------------------------------------------------------------*/
+ (UIImage *)imageStretchForAll: (NSString *)filename {
    
    UIImage *img = [UIImage imageNamed: filename];
    //    return [img stretchableImageWithLeftCapWidth: img.size.width / 2 topCapHeight: img.size.height / 2];
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height / 2, img.size.width / 2, img.size.height / 2, img.size.width / 2)];
}

/*----------------------------------------------------------------------------
 Method:      Create Image With Mask Image
 -----------------------------------------------------------------------------*/
+ (UIImage *)maskImage: (UIImage *)image withMask: (UIImage *)p_maskImage {
    
    CGImageRef maskRef = p_maskImage.CGImage;
    
    //CGImageRef maskImage = p_maskImage.CGImage;
    CGSize targetSize = p_maskImage.size;
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a bitmap graphics context the size of the image
    mainViewContentContext = CGBitmapContextCreate (NULL, targetSize.width, targetSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, targetSize.width, targetSize.height), maskRef);
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, targetSize.width, targetSize.height), image.CGImage);
    
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished resized image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(mainViewContentBitmapContext);
    
    // return the image
    return theImage;
}

/*----------------------------------------------------------------------------
 Method:      Image Stretch By Width With Position
 -----------------------------------------------------------------------------*/
+ (UIImage *)imageStretchForWidth: (NSString *)filename withSpace: (float)space {
    
    UIImage *img = [UIImage imageNamed: filename];
    return [img stretchableImageWithLeftCapWidth: img.size.width / 2 + space topCapHeight: 0];
}

+ (UIImage *)imageByScalingAndCroppingForSize: (UIImage *) sourceImage : (CGSize)targetSize {
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = 0;//(targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
@end
