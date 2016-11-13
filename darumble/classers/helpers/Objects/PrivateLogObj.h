//
//  UserObj.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivateLogObj : NSObject
@property (nonatomic, assign) int from_user;
@property (nonatomic, assign) int to_user;
@property (nonatomic, retain) NSString *text_message;
@property (nonatomic, retain) NSString *date;
@end
