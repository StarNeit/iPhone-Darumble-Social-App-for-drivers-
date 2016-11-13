//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventSearchResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnails;
@property (strong, nonatomic) IBOutlet UILabel *eventname;
@property (strong, nonatomic) IBOutlet UILabel *eventlocation;
@property (strong, nonatomic) IBOutlet UILabel *eventdate;
@property (strong, nonatomic) IBOutlet UILabel *eventadder;
@property (strong, nonatomic) IBOutlet UILabel *label_noimage;
@end
