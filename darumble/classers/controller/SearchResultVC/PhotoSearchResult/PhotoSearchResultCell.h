//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSearchResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnails;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *label_noimage;
@property int m_followerID;
@end
