//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *txtNotification;
@property (strong, nonatomic) IBOutlet UILabel *arrivedTime;
@property (strong, nonatomic) IBOutlet UILabel *beforeTime;
@property (strong, nonatomic) IBOutlet UILabel *txtTitle;
@property (strong, nonatomic) IBOutlet UILabel *txtCommenter;

@property int shop_id;

@end
