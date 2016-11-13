//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopObj : NSObject
@property (nonatomic, assign) int shop_id;
@property (nonatomic, assign) int shop_photo_id;
@property (nonatomic, retain) NSString *shop_name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *contact_info;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, assign) int is_private;
@property (nonatomic, assign) int is_mycreated_shop;
@end
