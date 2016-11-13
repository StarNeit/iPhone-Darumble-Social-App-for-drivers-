//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "RequestCell.h"

@implementation RequestCell
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
- (IBAction)clickAccept:(id)sender
{
    if (self.requesterID == 0){
        [Common showAlert:@"Couldn't accept this user"];
        return;
    }
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws accept_member:APP_TOKEN userID:self.requesterID shopID:self.parent.m_shopid];
    }
}
- (IBAction)clickDecline:(id)sender
{
    if (self.requesterID == 0){
        [Common showAlert:@"Couldn't decline this user"];
        return;
    }
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to decline this member?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = 7001;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}
- (IBAction)clickBlock:(id)sender
{
    if (self.requesterID == 0){
        [Common showAlert:@"Couldn't block this user"];
        return;
    }
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to block this member?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = 7002;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7001)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            //---WS API CALL(decline requester)---
            [self removeNotifi2];
            [self addNotifi2];
            
            [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws decline_member:APP_TOKEN userID:self.requesterID shopID:self.parent.m_shopid];
        }
    }else if (alertView.tag == 7002)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            //---WS API CALL(block requester)---
            [self removeNotifi3];
            [self addNotifi3];
            
            [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws block_member:APP_TOKEN userID:self.requesterID shopID:self.parent.m_shopid];
        }
    }
}


//==============WEBSERVICE(Accept Requester)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AcceptRequester_Success:) name:k_accept_member_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AcceptRequester_Fail:) name:k_accept_member_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_accept_member_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_accept_member_fail object:nil];
}
-(void) AcceptRequester_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"AcceptRequester_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        ShopManagerVC *vc = [[ShopManagerVC alloc] init];
        vc.m_shopid = self.parent.m_shopid;
        vc.m_shop_detail_info = self.m_shop_detail_info;
        vc.flagOfSwitchView = 1;
        
        [self.parent.navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}
-(void) AcceptRequester_Fail:(NSNotification*)notif
{
    NSLog(@"AcceptRequester_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}



//==============WEBSERVICE(Decline Requester)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeclineRequester_Success:) name:k_decline_member_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeclineRequester_Fail:) name:k_decline_member_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_decline_member_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_decline_member_fail object:nil];
}
-(void) DeclineRequester_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"DeclineRequester_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        ShopManagerVC *vc = [[ShopManagerVC alloc] init];
        vc.m_shopid = self.parent.m_shopid;
        vc.m_shop_detail_info = self.m_shop_detail_info;
        vc.flagOfSwitchView = 1;
        
        [self.parent.navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}
-(void) DeclineRequester_Fail:(NSNotification*)notif
{
    NSLog(@"DeclineRequester_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}



//==============WEBSERVICE(Block Requester)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockRequester_Success:) name:k_block_member_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockRequester_Fail:) name:k_block_member_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_member_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_member_fail object:nil];
}
-(void) BlockRequester_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"BlockRequester_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        ShopManagerVC *vc = [[ShopManagerVC alloc] init];
        vc.m_shopid = self.parent.m_shopid;
        vc.m_shop_detail_info = self.m_shop_detail_info;
        vc.flagOfSwitchView = 1;
        
        [self.parent.navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi3];
}
-(void) BlockRequester_Fail:(NSNotification*)notif
{
    NSLog(@"BlockRequester_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi3];
}

@end
