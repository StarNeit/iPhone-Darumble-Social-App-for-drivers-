//
//  Common.h
//  HeroPager
//
//  Created by Nick LEE on 2/21/12.
//  Copyright (c) 2012 HireVietnamese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Common.h"

@interface RegisterVideoMeta : NSObject

+(void) setVideoMeta:(NSString *)video_url title:(NSString*)title description:(NSString*)description thumbnail:(NSString*) thumbnail;

+(void) addVideoCount;
+(void) removeVideoCount;
+(int) getVideoCount;
+(void) initVideoCount;
@end
