//
//  UserObj.h
//  SmarkKid
//
//  Created by Phan Minh Tam on 3/22/14.
//  Copyright (c) 2014 SDC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "UserObj.h"
#import "PhotoObj.h"
#import "CategoriesObj.h"
#import "PublicProfileResponse.h"

@interface ParseUtil : NSObject

/*----------------------------------------------------------------------------
 Method:      AppInfo Method
 -----------------------------------------------------------------------------*/
+(void)parse_add_userDic:(NSDictionary*)dic andPass:(NSString*)pass;
+(void)parse_add_userFacebbook:(NSDictionary*)dic andPass:(NSString*)pass;
+(void)parse_add_userDicUpdate:(NSDictionary*)dic andPass:(NSString*)pass;
+(NSMutableArray*)parse_get_categories:(NSDictionary*)dic;
+(NSMutableArray*)parse_get_vehicle:(NSDictionary*)dic;
+(NSMutableArray*)parse_get_garage:(NSDictionary *)dic;
+(NSMutableArray*)parse_get_event:(NSDictionary *)dic;
+(NSMutableArray*)parse_get_photo:(NSDictionary *)dic;
+(NSMutableArray*)parse_get_video:(NSDictionary *)dic;

+(PublicProfileResponse*)parse_get_publicprofile:(NSDictionary *)dic;
+(PublicProfileResponse*)parse_get_globalfeed:(NSDictionary *)dic;
@end
