//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleObj : NSObject
@property (nonatomic, assign) int id;
@property (nonatomic, assign) int uid;
@property (nonatomic, retain) NSString *url;

@property (nonatomic, retain) NSString *import;
@property (nonatomic, retain) NSString *make;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *garage;
@property (nonatomic, retain) NSString *fname;
@property (nonatomic, retain) NSString *lname;
@end
