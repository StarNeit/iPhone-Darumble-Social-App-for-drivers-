//
//  Common.m
//  HeroPager
//
//  Created by Nick LEE on 2/21/12.
//  Copyright (c) 2012 HireVietnamese. All rights reserved.
//

#import "RegisterVideoMeta.h"
#import "VIMNetworking.h"
#import "VIMObjectMapper.h"
#import "VIMPictureCollection.h"
#import "VIMPicture.h"
#import "Common.h"

@implementation RegisterVideoMeta

int video_count = 0;

+(void) addVideoCount
{
    video_count ++;
}
+(void) removeVideoCount
{
    video_count --;
}
+(int) getVideoCount
{
    return video_count;
}
+(void) initVideoCount
{
    video_count = 0;
}

+(void) setVideoMeta:(NSString *)video_url title:(NSString*)title description:(NSString*)description thumbnail:(NSString*) thumbnail
{
    if (thumbnail == nil)
    {
        thumbnail = @"";
    }
    DataCenter *ws = [[DataCenter alloc] init];
    [ws add_video:APP_TOKEN url:video_url uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] description:description catid:@"2" title:title thumbnail:thumbnail zip:[USER_DEFAULT objectForKey:@"zip"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"zip"] : @"" country:[USER_DEFAULT objectForKey:@"country"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"country"] : @"" eventID:[[USER_DEFAULT objectForKey:@"video_eventID"] intValue]];
}
@end
