//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObj : NSObject

@property (nonatomic, assign) int id;
@property (nonatomic, assign) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *fname;
@property (nonatomic, retain) NSString *lname;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, assign) int age;
@property (nonatomic, retain) NSString *terms_agreed;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *repassword;
@property (nonatomic, retain) NSString *clubName;
@property (nonatomic, retain) NSString *profile_pic_url;
@property (nonatomic, retain) NSString *c_description;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSString *url;
@end
