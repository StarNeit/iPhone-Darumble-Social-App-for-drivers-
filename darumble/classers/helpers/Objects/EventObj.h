//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventObj : NSObject
@property (nonatomic, assign) int eventID;
@property (nonatomic, retain) NSString *eventName;

@property (nonatomic, retain) NSString *eventLocation;
@property (nonatomic, retain) NSString *start_date;
@property (nonatomic, assign) int eventCreator;
@property (nonatomic, retain) NSString *fname;
@property (nonatomic, retain) NSString *lname;
@property (nonatomic, retain) NSString *url;
@end
