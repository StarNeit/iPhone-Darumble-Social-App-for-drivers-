//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleSearchResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnails;
@property (strong, nonatomic) IBOutlet UILabel *m_import;
@property (strong, nonatomic) IBOutlet UILabel *m_model;
@property (strong, nonatomic) IBOutlet UILabel *m_make;
@property (strong, nonatomic) IBOutlet UILabel *m_year;
@property (strong, nonatomic) IBOutlet UILabel *label_noimage;
@end
