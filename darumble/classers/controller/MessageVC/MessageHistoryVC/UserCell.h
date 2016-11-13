//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnails;
@property (strong, nonatomic) IBOutlet UILabel *lastMessage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *lastTime;
@property (strong, nonatomic) IBOutlet UILabel *whileTime;
@property (strong, nonatomic) IBOutlet UIButton *btnAvatar;

@property (strong, nonatomic) IBOutlet UIButton *btn_delete_message;

@end
