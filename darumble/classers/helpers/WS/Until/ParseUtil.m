//
//  UserObj.h
//  SmarkKid
//
//  Created by Phan Minh Tam on 3/22/14.
//  Copyright (c) 2014 SDC. All rights reserved.
//

#import "ParseUtil.h"

@implementation ParseUtil

+(void)parse_add_userFacebbook:(NSDictionary *)dic andPass:(NSString *)pass
{
    NSDictionary *data = [dic objectForKey:@"data"];
    //NSString *username =![[USER_DEFAULT objectForKey:@"username"] isEqualToString:@"<null>"]?[data objectForKey:@"username"]:@"";
   // NSString *username =![[USER_DEFAULT objectForKey:@"username"] isEqualToString:@"<null>"]?[data objectForKey:@"username"]:@"";
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"username"]!=[NSNull null]?[data objectForKey:@"username"]:@""] forKey:@"username"];
    [USER_DEFAULT setValue:[data objectForKey:@"firstName"] forKey:@"fname"];
    [USER_DEFAULT setValue:[data objectForKey:@"lastName"] forKey:@"lname"];
    [USER_DEFAULT setValue:[data objectForKey:@"email"] forKey:@"email"];
    [USER_DEFAULT setValue:pass forKey:@"password"];
    [USER_DEFAULT setValue:[data objectForKey:@"age"]!=[NSNull null]?[data objectForKey:@"age"]:@"" forKey:@"age"];
    [USER_DEFAULT setValue:[data objectForKey:@"phone"]!=[NSNull null]?[data objectForKey:@"phone"]:@"" forKey:@"phone"];
    [USER_DEFAULT setValue:[data objectForKey:@"zip"]!=[NSNull null]?[data objectForKey:@"zip"]:@"" forKey:@"zip"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"clubName"]!=[NSNull null]?[data objectForKey:@"clubName"]:@""] forKey:@"clubName"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"profile_pic_url"]!=[NSNull null]?[data objectForKey:@"profile_pic_url"]:@""] forKey:@"photo_url"];
    [USER_DEFAULT setValue:[data objectForKey:@"userID"] forKey:@"userID"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"country"]!=[NSNull null]?[data objectForKey:@"country"]:@""] forKey:@"country"];
    if ([data objectForKey:@"city"]) {
        [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"city"]!=[NSNull null]?[data objectForKey:@"city"]:@""] forKey:@"city"];
    }
    
}
+(void)parse_add_userDic:(NSDictionary*)dic andPass:(NSString*)pass{
    NSDictionary *data = [dic objectForKey:@"data"];
    [USER_DEFAULT setValue:[data objectForKey:@"username"] forKey:@"username"];
    [USER_DEFAULT setValue:[data objectForKey:@"fname"] forKey:@"fname"];
    [USER_DEFAULT setValue:[data objectForKey:@"lname"] forKey:@"lname"];
    [USER_DEFAULT setValue:[data objectForKey:@"email"] forKey:@"email"];
    [USER_DEFAULT setValue:pass forKey:@"password"];
    [USER_DEFAULT setValue:[data objectForKey:@"age"]!=[NSNull null]?[data objectForKey:@"age"]:@"" forKey:@"age"];
    [USER_DEFAULT setValue:[data objectForKey:@"phone"]!=[NSNull null]?[data objectForKey:@"phone"]:@"" forKey:@"phone"];
    [USER_DEFAULT setValue:[data objectForKey:@"zip"]!=[NSNull null]?[data objectForKey:@"zip"]:@"" forKey:@"zip"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"clubName"]!=[NSNull null]?[data objectForKey:@"clubName"]:@""] forKey:@"clubName"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"profile_pic_url"]!=[NSNull null]?[data objectForKey:@"profile_pic_url"]:@""] forKey:@"photo_url"];
    [USER_DEFAULT setValue:[data objectForKey:@"userID"] forKey:@"userID"];
     [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"country"]!=[NSNull null]?[data objectForKey:@"country"]:@""] forKey:@"country"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"city"]!=[NSNull null]?[data objectForKey:@"city"]:@""] forKey:@"city"];
}

+(void)parse_add_userDicUpdate:(NSDictionary*)dic andPass:(NSString*)pass{
    NSDictionary *data = [dic objectForKey:@"data"];
    [USER_DEFAULT setValue:[data objectForKey:@"username"] forKey:@"username"];
    [USER_DEFAULT setValue:[data objectForKey:@"fname"] forKey:@"fname"];
    [USER_DEFAULT setValue:[data objectForKey:@"lname"] forKey:@"lname"];
    [USER_DEFAULT setValue:[data objectForKey:@"email"] forKey:@"email"];
    [USER_DEFAULT setValue:pass forKey:@"password"];
    [USER_DEFAULT setValue:[data objectForKey:@"age"]!=[NSNull null]?[data objectForKey:@"age"]:@"" forKey:@"age"];
    [USER_DEFAULT setValue:[data objectForKey:@"phone"]!=[NSNull null]?[data objectForKey:@"phone"]:@"" forKey:@"phone"];
    [USER_DEFAULT setValue:[data objectForKey:@"zip"]!=[NSNull null]?[data objectForKey:@"zip"]:@"" forKey:@"zip"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"photo_url"]!=[NSNull null]?[data objectForKey:@"photo_url"]:@""] forKey:@"photo_url"];
    [USER_DEFAULT setValue:[data objectForKey:@"userID"] forKey:@"userID"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"country"]!=[NSNull null]?[data objectForKey:@"country"]:@""] forKey:@"country"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"city"]!=[NSNull null]?[data objectForKey:@"city"]:@""] forKey:@"city"];
    
    
    NSString *age = [USER_DEFAULT objectForKey:@"age"];
    
    
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%@", [data objectForKey:@"clubName"]!=[NSNull null]?[data objectForKey:@"clubName"]:@""] forKey:@"clubName"];
    
    
}



+(NSMutableArray*)parse_get_categories:(NSDictionary*)dic{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableDictionary *arra = [[dic objectForKey:@"data"] objectForKey:@"categories"];
    for (int i = 0; i < arra.count; i++) {
        CategoriesObj *obj = [[CategoriesObj alloc] init];
        obj.name = [[[[dic objectForKey:@"data"] objectForKey:@"categories"] objectForKey:[NSString stringWithFormat:@"%d", i+1]] objectForKey:@"name"];
        obj.parentID = [[[[dic objectForKey:@"data"] objectForKey:@"categories"] objectForKey:[NSString stringWithFormat:@"%d", i+1]] objectForKey:@"parentID"];
        [arr addObject:obj];
    }
    return arr;
}

+(NSMutableArray*)parse_get_vehicle:(NSDictionary*)dic{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDictionary *data0 = [dic objectForKey:@"data"];
    NSArray *array = [data0 objectForKey:@"vehicles"];
    
    for (NSDictionary *data in array) {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.des = [data objectForKey:@"description"]!=[NSNull null]?[data objectForKey:@"description"]:@"";
        obj.make = [data objectForKey:@"make"]!=[NSNull null]?[data objectForKey:@"make"]:@"";
        obj.model = [data objectForKey:@"model"]!=[NSNull null]?[data objectForKey:@"model"]:@"";
        obj.type = [data objectForKey:@"type"]!=[NSNull null]?[data objectForKey:@"type"]:@"";
        obj.id = [[data objectForKey:@"id"] intValue];
        obj.year = [data objectForKey:@"year"];
         obj.URL = [data objectForKey:@"photo_url"]!=[NSNull null]?[data objectForKey:@"photo_url"]:@"";
        [arr addObject:obj];
    }
    
    return arr;
}

+(NSMutableArray*)parse_get_garage:(NSDictionary *)dic{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDictionary *data0 = [dic objectForKey:@"data"];
    NSArray *array = [data0 objectForKey:@"garages"];
    
    for (NSDictionary *data in array) {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.address = [data objectForKey:@"address"]!=[NSNull null]?[data objectForKey:@"address"]:@"";
        obj.date = [data objectForKey:@"date_established"]!=[NSNull null]?[data objectForKey:@"date_established"]:@"";
        obj.des = [data objectForKey:@"description"]!=[NSNull null]?[data objectForKey:@"description"]:@"";
        obj.email = [data objectForKey:@"email"]!=[NSNull null]?[data objectForKey:@"email"]:@"";
        obj.id = [[data objectForKey:@"id"] intValue];
        obj.isShop = [[data objectForKey:@"isShop"] intValue];
        obj.phone = [data objectForKey:@"phone"]!=[NSNull null]?[data objectForKey:@"phone"]:@"";
        obj.shop_name = [data objectForKey:@"shop_name"]!=[NSNull null]?[data objectForKey:@"shop_name"]:@"";
        obj.state = [data objectForKey:@"state"]!=[NSNull null]?[data objectForKey:@"state"]:@"";
        obj.tags = [data objectForKey:@"tags"]!=[NSNull null]?[data objectForKey:@"tags"]:@"";
        obj.uid = [data objectForKey:@"uid"]!=[NSNull null]?[[data objectForKey:@"uid"] intValue]:0;
        obj.website = [data objectForKey:@"website"]!=[NSNull null]?[data objectForKey:@"website"]:@"";
        obj.zip = [data objectForKey:@"zip"]!=[NSNull null]?[data objectForKey:@"zip"]:@"";
        obj.URL = [data objectForKey:@"photo_url"]!=[NSNull null]?[data objectForKey:@"photo_url"]:@"";
        [arr addObject:obj];
    }
    
    return arr;
}
+(NSMutableArray*)parse_get_photo:(NSDictionary *)dic{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDictionary *data0 = [dic objectForKey:@"data"];
    NSArray *array = [data0 objectForKey:@"photos"];
    
    for (NSDictionary *data in array) {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.categoryID = [data objectForKey:@"catid"]!=[NSNull null]?[[data objectForKey:@"catid"] intValue]:Cat_GeneralPhotos;
        obj.des = [data objectForKey:@"description"]!=[NSNull null]?[data objectForKey:@"description"]:@"";
        obj.URL = [data objectForKey:@"url"]!=[NSNull null]?[data objectForKey:@"url"]:@"";
        obj.id = [[data objectForKey:@"id"] intValue];
        obj.tags = [data objectForKey:@"tags"]!=[NSNull null]?[data objectForKey:@"tags"]:@"";
        obj.uid = [data objectForKey:@"uid"]!=[NSNull null]?[[data objectForKey:@"uid"] intValue]:0;
        [arr addObject:obj];
    }
    
    return arr;
}

+(NSMutableArray*)parse_get_event:(NSDictionary *)dic{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDictionary *data0 = [dic objectForKey:@"data"];
    NSArray *array = [data0 objectForKey:@"events"];
    
    for (NSDictionary *data in array) {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.id = [[data objectForKey:@"id"] intValue];
        obj.day = [data objectForKey:@"day"]!=[NSNull null]?[data objectForKey:@"day"]:@"";
        obj.dayName = [data objectForKey:@"dayName"]!=[NSNull null]?[data objectForKey:@"dayName"]:@"";
        obj.event_type = [data objectForKey:@"event_type"]!=[NSNull null]?[data objectForKey:@"event_type"]:@"";
        obj.location = [data objectForKey:@"location"]!=[NSNull null]?[data objectForKey:@"location"]:@"";
        obj.monthNameShort = [data objectForKey:@"monthNameShort"]!=[NSNull null]?[data objectForKey:@"monthNameShort"]:@"";
        obj.start_date = [data objectForKey:@"start_date"]!=[NSNull null]?[data objectForKey:@"start_date"]:@"";
        obj.eventName = [data objectForKey:@"eventName"]!=[NSNull null]?[data objectForKey:@"eventName"]:@"";
        obj.URL = [data objectForKey:@"photo_url"]!=[NSNull null]?[data objectForKey:@"photo_url"]:@"";
        
        obj.event_country = [data objectForKey:@"country"] != [NSNull null]?[data objectForKey:@"country"]:@"";
        obj.event_state = [data objectForKey:@"state"] != [NSNull null]?[data objectForKey:@"state"]:@"";
        obj.event_city = [data objectForKey:@"city"] != [NSNull null]?[data objectForKey:@"city"]:@"";
        obj.event_contact_info = [data objectForKey:@"contact_info"] != [NSNull null]?[data objectForKey:@"contact_info"]:@"";
        obj.event_flyer = [data objectForKey:@"flyer"] != [NSNull null]?[[data objectForKey:@"flyer"] intValue]:0;
        obj.event_flyer_url = [data objectForKey:@"flyer_url"] != [NSNull null]?[data objectForKey:@"flyer_url"] : @"";
        obj.is_recurring = [data objectForKey:@"is_recurring"] != [NSNull null]?[[data objectForKey:@"is_recurring"] intValue] : 0;
        obj.recurring_count = [data objectForKey:@"recurring_count"] != [NSNull null]?[[data objectForKey:@"recurring_count"] intValue] : 0;
        obj.recurring_time = [data objectForKey:@"recurring_time"] != [NSNull null]?[data objectForKey:@"recurring_time"] : @"";
        obj.recurring_end_count = [data objectForKey:@"recurring_end_time"] != [NSNull null]?[[data objectForKey:@"recurring_end_count"] intValue]:0;
        obj.recurring_end_time = [data objectForKey:@"recurring_end_time"] != [NSNull null]?[data objectForKey:@"recurring_end_time"]:@"";
        obj.event_uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
        obj.event_catid = [data objectForKey:@"catid"] != [NSNull null] ? [[data objectForKey:@"catid"] intValue] : 5;
        obj.event_photo_id = [data objectForKey:@"photo_id"] != [NSNull null] ? [[data objectForKey:@"photo_id"] intValue] : 0;
        obj.event_zip = [data objectForKey:@"zip"] != [NSNull null] ? [data objectForKey:@"zip"] : @"";
        [arr addObject:obj];
        
    }
    
    return arr;
}
+(NSMutableArray*)parse_get_video:(NSDictionary *)dic{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDictionary *data0 = [dic objectForKey:@"data"];
    NSArray *array = [data0 objectForKey:@"videos"];
    for (NSDictionary *data in array) {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.id = [[data objectForKey:@"id"] intValue];
        obj.uid = [data objectForKey:@"uid"]!=[NSNull null]?[[data objectForKey:@"uid"] intValue]:0;
        obj.URL = [data objectForKey:@"url"]!=[NSNull null]?[data objectForKey:@"url"]:@"";
        obj.des = [data objectForKey:@"description"]!=[NSNull null]?[data objectForKey:@"description"]:@"";
        obj.title = [data objectForKey:@"title"]!=[NSNull null]?[data objectForKey:@"title"]:@"";
        obj.categoryID = [data objectForKey:@"catid"]!=[NSNull null]?[[data objectForKey:@"catid"] intValue]:Cat_Videos;
        obj.videoThumbnailURL = [data objectForKey:@"thumbnail"]!=[NSNull null]?[data objectForKey:@"thumbnail"]:@"";
        [arr addObject:obj];
    }
    
    return arr;
}

//---New Parse Functions---

+(PublicProfileResponse*)parse_get_publicprofile:(NSDictionary *)dic{
    NSDictionary *data0 = [dic objectForKey:@"data"];
    
    PublicProfileResponse *profileRes = [[PublicProfileResponse alloc] init];
    profileRes.userID = [data0 objectForKey:@"userID"]!=[NSNull null]?[[data0 objectForKey:@"userID"] intValue]:0;
    profileRes.fname = [data0 objectForKey:@"fname"]!=[NSNull null]?[data0 objectForKey:@"fname"]:@"";
    profileRes.lname = [data0 objectForKey:@"lname"]!=[NSNull null]?[data0 objectForKey:@"lname"]:@"";
    profileRes.city = [data0 objectForKey:@"city"]!=[NSNull null]?[data0 objectForKey:@"city"]:@"";
    profileRes.country = [data0 objectForKey:@"country"]!=[NSNull null]?[data0 objectForKey:@"country"]:@"";
    profileRes.zip = [data0 objectForKey:@"zip"]!=[NSNull null]?[data0 objectForKey:@"zip"]:@"";
    profileRes.clubName = [data0 objectForKey:@"clubName"]!=[NSNull null]?[data0 objectForKey:@"clubName"]:@"";
    profileRes.email = [data0 objectForKey:@"email"]!=[NSNull null]?[data0 objectForKey:@"email"]:@"";
    profileRes.followers = [data0 objectForKey:@"followers"]!=[NSNull null]?[[data0 objectForKey:@"followers"] intValue]:0;
    profileRes.url = [data0 objectForKey:@"url"]!=[NSNull null]?[data0 objectForKey:@"url"]:@"";
    
    profileRes.garages = [data0 objectForKey:@"garages"];
    profileRes.photos = [data0 objectForKey:@"photos"];
    profileRes.events = [data0 objectForKey:@"events"];
    profileRes.videos = [data0 objectForKey:@"videos"];
    return profileRes;
}
@end

