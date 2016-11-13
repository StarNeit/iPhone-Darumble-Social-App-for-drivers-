//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopManagerVC.h"

@interface RequestCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnails;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *btnAvatar;

@property ShopObj *m_shop_detail_info;

@property int requesterID;
@property ShopManagerVC *parent;
@end
