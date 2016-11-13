//
//  PhotoObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoObj : NSObject

@property (nonatomic, assign) int id;
//Photo, Video

@property (nonatomic, assign) int imageID;
@property (nonatomic, assign) int categoryID;
@property (nonatomic, retain) NSString *imageThumbnailURL;
@property (nonatomic, retain) NSString *videoThumbnailURL;
@property (nonatomic, retain) NSString *vehicleThumbnailURL;
@property (nonatomic, retain) NSString *des;
@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) NSString *videoURL;
@property (nonatomic, retain) NSString *URL;
//Vehicle
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *make;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, assign) int currentVehicleCount;
@property (nonatomic, retain) NSString *vehicleID;

//Garage

@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int isShop;
@property (nonatomic, assign) int uid;
@property (nonatomic, retain) NSString *shop_name;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;

//Event

@property (nonatomic, retain) NSString *day;
@property (nonatomic, retain) NSString *eventName;
@property (nonatomic, retain) NSString *dayName;
@property (nonatomic, retain) NSString *date_info;
@property (nonatomic, retain) NSString *event_type;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *monthNameShort;
@property (nonatomic, retain) NSString *start_date;

@property (nonatomic, retain) NSString *data_type;

@property (nonatomic, retain) NSString *event_country;
@property (nonatomic, retain) NSString *event_state;
@property (nonatomic, retain) NSString *event_city;
@property (nonatomic, retain) NSString *event_contact_info;
@property (nonatomic, assign) int event_flyer;
@property (nonatomic, retain) NSString *event_flyer_url;
@property (nonatomic, assign) int is_recurring;
@property (nonatomic, assign) int recurring_count;
@property (nonatomic, retain) NSString *recurring_time;
@property (nonatomic, assign) int recurring_end_count;
@property (nonatomic, retain) NSString *recurring_end_time;
@property (nonatomic, assign) int event_uid;
@property (nonatomic, assign) int event_catid;
@property (nonatomic, assign) int event_photo_id;
@property (nonatomic, retain) NSString *event_zip;

@end
