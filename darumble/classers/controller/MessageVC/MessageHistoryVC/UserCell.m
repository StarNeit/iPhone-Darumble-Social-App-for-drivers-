//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell
@synthesize thumbnails = _thumbnails;
@synthesize lastMessage = _lastMessage;
@synthesize userName = _userName;
@synthesize lastTime = _lastTime;
@synthesize whileTime = _whileTime;
@synthesize btnAvatar = _btnAvatar;
@synthesize btn_delete_message = _btn_delete_message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
