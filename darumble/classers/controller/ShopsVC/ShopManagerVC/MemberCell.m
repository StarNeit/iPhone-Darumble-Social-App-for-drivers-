//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "MemberCell.h"
#import "MessageComposeVC.h"

@implementation MemberCell
@synthesize thumbnails = _thumbnails;
@synthesize userName = _userName;
@synthesize btnAvatar = _btnAvatar;


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

- (IBAction)clickMessage:(id)sender
{
    if (self.memberID == 0){
        [Common showAlert:@"Couldn't send message to this user"];
        return;
    }
    MessageComposeVC *vc = [[MessageComposeVC alloc] init];
    vc.from_user = [[USER_DEFAULT objectForKey:@"userID"] intValue];
    vc.to_user = self.memberID;
    [self.parent.navigationController pushViewController:vc animated:NO];

}

- (IBAction)clickFollow:(id)sender
{
    //---WS API CALL(follow user)---
    [self removeNotifi4];
    [self addNotifi4];
    
    [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    int action = 2;     // 2 : follow user, 1: unfollow user
    [ws follow_user:APP_TOKEN uid:self.memberID followerid:[[USER_DEFAULT objectForKey:@"userID"] intValue] action:action];
}

- (IBAction)clickRemove:(id)sender
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to remove this member?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = 7000;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7000)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            //---WS API CALL(block user)---
            [self removeNotifi2];
            [self addNotifi2];
            
            [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws remove_member:APP_TOKEN userID:self.memberID shopID:self.parent.m_shopid];
        }
    }
}



//==============WEBSERVICE(Follow User)============
- (void)addNotifi4
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FollowUser_Success:) name:k_follow_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FollowUser_Fail:) name:k_follow_user_fail object:nil];
}
- (void)removeNotifi4
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_follow_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_follow_user_fail object:nil];
}
-(void) FollowUser_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"BlockUser_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully followed"];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi4];
}
-(void) FollowUser_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi4];
}

//==============WEBSERVICE(Remove member)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveMember_Success:) name:k_remove_member_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveMember_Fail:) name:k_remove_member_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_member_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_member_fail object:nil];
}
-(void) RemoveMember_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"RemoveMember_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully removed"];
        ShopManagerVC *vc = [[ShopManagerVC alloc] init];
        vc.m_shopid = self.parent.m_shopid;
        vc.flagOfSwitchView = 0;
        vc.m_shop_detail_info = self.m_shop_detail_info;
        
        [self.parent.navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi2];
}
-(void) RemoveMember_Fail:(NSNotification*)notif{
    NSLog(@"RemoveMember_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi2];
}
@end
