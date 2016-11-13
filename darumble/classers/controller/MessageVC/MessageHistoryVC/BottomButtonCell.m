//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "BottomButtonCell.h"
#import "MessageComposeVC.h"

@implementation BottomButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.to_user = 0;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)redirectController{
    MessageComposeVC *vc = [[MessageComposeVC alloc] init];
    vc.to_user = self.to_user;
    vc.from_user =[[USER_DEFAULT objectForKey:@"userID"] intValue];
    [self.parent.navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickNewPostButton:(id)sender {
    int userID = [[USER_DEFAULT objectForKey:@"userID"] intValue];
    if (userID == self.parent.plog_from_id)
    {
        self.to_user = self.parent.plog_to_id;
    }
    else {
        self.to_user = self.parent.plog_from_id;
    }
    
    if (self.to_user == 0){
        [Common showAlert:@"Couldn't send message to this user."];
        return;
    }
    [self redirectController];
}
@end
