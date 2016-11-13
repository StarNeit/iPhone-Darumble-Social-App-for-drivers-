//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "LeaveGroupButCell.h"

@implementation LeaveGroupButCell

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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 6000)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
                //---WS API Call(photo detail)---
                [self removeNotifi];
                [self addNotifi];
                
                [MBProgressHUD showHUDAddedTo:self.parent.view WithTitle:@"Waiting..." animated:YES];
                DataCenter *ws = [[DataCenter alloc] init];
                [ws remove_member:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] shopID:self.parent.photoObj.id];
                
            }
        }
    }
}

- (IBAction)clickLeaveGroup:(id)sender {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to leave this group?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = 6000;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];    
}

- (void)redirectController{
    ShopsContentVC *vc = [[ShopsContentVC alloc] init];
    [self.parent.navigationController pushViewController:vc animated:NO];
}


//==============WEBSERVICE(leave group[remove member])============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LeaveGroup_Success:) name:k_remove_member_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LeaveGroup_Fail:) name:k_remove_member_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_member_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_member_fail object:nil];
}
-(void) LeaveGroup_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [self redirectController];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}
-(void) LeaveGroup_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.parent.view animated:YES];
    [self removeNotifi];
}
@end
