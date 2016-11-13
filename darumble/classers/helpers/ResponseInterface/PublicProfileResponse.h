//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface PublicProfileResponse : NSObject

@property (nonatomic, assign) int userID;
@property (nonatomic, retain) NSString *fname;
@property (nonatomic, retain) NSString *lname;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, assign) int followers;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *garages;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSArray *events;
@property (nonatomic, retain) NSArray *videos;
@end
