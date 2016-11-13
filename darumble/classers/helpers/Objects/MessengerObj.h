//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessengerObj : NSObject

@property (nonatomic, assign) int followerID;
@property (nonatomic, retain) NSString *fname;
@property (nonatomic, retain) NSString *lname;
@property (nonatomic, retain) NSString *profile_pic_url;
@property (nonatomic, retain) NSString *date_sent;
@property (nonatomic, retain) NSString *text_message;
@property (nonatomic, assign) long timespan;
@end
