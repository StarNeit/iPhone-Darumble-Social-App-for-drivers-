//
//  CommonUtils.h
//  Sufi
//
//  Created by KeHo on 2/21/13.
//  Copyright (c) 2013 KGP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

/*----------------------------------------------------------------------------
 Method:      Image Method
 -----------------------------------------------------------------------------*/
+ (UIImage *)imageStretchForWidth: (NSString *)filename;
+ (UIImage *)imageStretchForHeight: (NSString *)filename;
+ (UIImage *)imageStretchForAll: (NSString *)filename;
+ (UIImage *)maskImage: (UIImage *)image withMask: (UIImage *)p_maskImage;
+ (UIImage *)imageStretchForWidth: (NSString *)filename withSpace: (float)space;
+ (UIImage *)imageByScalingAndCroppingForSize: (UIImage *) sourceImage : (CGSize)targetSize;

@end
