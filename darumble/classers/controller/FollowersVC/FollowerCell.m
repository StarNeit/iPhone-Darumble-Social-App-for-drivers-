//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "FollowerCell.h"
#import "MessageComposeVC.h"

@implementation FollowerCell
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
- (IBAction)clickRumble:(id)sender {
    MessageComposeVC *vc = [[MessageComposeVC alloc] init];
    vc.from_user = [[USER_DEFAULT objectForKey:@"userID"] intValue];
    vc.to_user = self.m_followerID;
    [self.parent.navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickBlockFollower:(id)sender {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to block this user?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_block_follower;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}

- (IBAction)clickRemoveFollower:(id)sender {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to remove this user?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_remove_follower;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}



//---UI Controller---
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == c_block_follower)
    {
        if (buttonIndex == 0) //no
        {
        }else if (buttonIndex == 1) //yes
        {
            [self removeNotifi];
            [self addNotifi];
            [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Loading..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws block_follower:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] followerID:self.m_followerID];
        }
    }else if (alertView.tag == c_remove_follower)
    {
        if (buttonIndex == 0) //no
        {
        }else if (buttonIndex == 1) //yes
        {
            [self removeNotifi2];
            [self addNotifi2];
            [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Loading..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws remove_follower:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] followerID:self.m_followerID];
        }
    }
}

- (void)redirectController{
    FollowerVC *vc = [[FollowerVC alloc] init];
    UINavigationController *navigationController = self.parent.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}


//==============WEBSERVICE(block follower)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockFollowers_Success:) name:k_block_follower_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockFollowers_Fail:) name:k_block_follower_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_follower_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_follower_fail object:nil];
}
-(void) BlockFollowers_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        //[Common showAlert:@"Successfully Blocked"];
        [self removeNotifi];
        [self redirectController];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}
-(void) BlockFollowers_Fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}


//==============WEBSERVICE(remove follower)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveFollowers_Success:) name:k_remove_follower_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveFollowers_Fail:) name:k_remove_follower_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_follower_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_follower_fail object:nil];
}
-(void) RemoveFollowers_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        //[Common showAlert:@"Successfully Removed"];
        [self removeNotifi2];
        [self redirectController];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi2];
}
-(void) RemoveFollowers_Fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi2];
}
@end
