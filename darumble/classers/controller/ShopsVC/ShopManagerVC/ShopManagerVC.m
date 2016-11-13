//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ShopManagerVC.h"
#import "UIImageView+AFNetworking.h"
#import "MemberCell.h"
#import "RequestCell.h"
#import "AddShopVC.h"

@interface ShopManagerVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;

    IBOutlet UIButton *btnMember;
    IBOutlet UIButton *btnRequest;
    IBOutlet UIButton *btnInvite;
    IBOutlet UIButton *btnEdit;
    
    IBOutlet UIButton *toggleGroup;
    
    IBOutlet UIView *memberView;
    IBOutlet UIView *requestView;
    IBOutlet UIView *inviteView;
    
    IBOutlet UIImageView *ShopManageTitle;
    NSArray *userNameData;
    NSArray *thumbnails;
    
    NSMutableArray *memberArray;
    IBOutlet UITableView *memberListTableView;

    NSMutableArray *requestArray;
    IBOutlet UITableView *requestListTableView;

    IBOutlet UITextField *invite_username;
    IBOutlet UITextField *invite_email;
}
@end

@implementation ShopManagerVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    toggleGroup.tag = 1002;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    
    [self._srcMain addGestureRecognizer:singleTap];
}



//---Gesture Recognizer---
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [self._srcMain setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)addGestureRecognizers
{
    [[self view] addGestureRecognizer:[self panGestureRecognizer]];
}
- (UIPanGestureRecognizer *)panGestureRecognizer
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    return recognizer;
}
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        velocityF = [recognizer velocityInView:self.view];
        velocityL = [recognizer velocityInView:self.view];
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        velocityL = [recognizer velocityInView:self.view];
        
        if(velocityL.x > velocityF.x + 200)
        {
//            AppDelegate *app = [Common appDelegate];
//            [app initSideMenu];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}




//---Device Orientation---
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    
    //[self GetClubMembers];
    
    if (self.flagOfSwitchView == 0)
    {
        [self clickMemberList:0];
    }else if (self.flagOfSwitchView == 1)
    {
        [self clickRequestList:0];
    }else if (self.flagOfSwitchView == 2)
    {
        [self clickInvite:0];
    }    
    
    memberListTableView.tableFooterView = [[UIView alloc] init];
    requestListTableView.tableFooterView = [[UIView alloc] init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}




//---UI Controller---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickMemberList:(id)sender {
    [btnMember setImage:[UIImage imageNamed:@"btn_action_members_on.png"] forState:UIControlStateNormal];
    [btnRequest setImage:[UIImage imageNamed:@"btn_action_request.png"] forState:UIControlStateNormal];
    [btnInvite setImage:[UIImage imageNamed:@"btn_action_invite.png"] forState:UIControlStateNormal];
    [btnEdit setImage:[UIImage imageNamed:@"ic_crown.png"] forState:UIControlStateNormal];
    
    ShopManageTitle.image = [UIImage imageNamed:@"title_members"];
    
    memberView.hidden = false;
    requestView.hidden = true;
    inviteView.hidden = true;
    
    
    [self GetClubMembers];
}
- (IBAction)clickRequestList:(id)sender {
    [btnMember setImage:[UIImage imageNamed:@"btn_action_members.png"] forState:UIControlStateNormal];
    [btnRequest setImage:[UIImage imageNamed:@"btn_action_request_on.png"] forState:UIControlStateNormal];
    [btnInvite setImage:[UIImage imageNamed:@"btn_action_invite.png"] forState:UIControlStateNormal];
    [btnEdit setImage:[UIImage imageNamed:@"ic_crown.png"] forState:UIControlStateNormal];
    
    ShopManageTitle.image = [UIImage imageNamed:@"title_request"];
    
    memberView.hidden = true;
    requestView.hidden = false;
    inviteView.hidden = true;
    
    [self GetRequestList];
}
- (IBAction)clickInvite:(id)sender {
    [btnMember setImage:[UIImage imageNamed:@"btn_action_members.png"] forState:UIControlStateNormal];
    [btnRequest setImage:[UIImage imageNamed:@"btn_action_request.png"] forState:UIControlStateNormal];
    [btnInvite setImage:[UIImage imageNamed:@"btn_action_invite_on.png"] forState:UIControlStateNormal];
    [btnEdit setImage:[UIImage imageNamed:@"ic_crown.png"] forState:UIControlStateNormal];
    
    ShopManageTitle.image = [UIImage imageNamed:@"title_invite"];
    
    memberView.hidden = true;
    requestView.hidden = true;
    inviteView.hidden = false;
}
- (IBAction)clickEdit:(id)sender {
    AddShopVC *vc = [[AddShopVC alloc] init];
    vc.title_name = @"Edit Shops/Clubs";
    vc.m_shop_detail_info = self.m_shop_detail_info;
    vc.flagOfShop = 2;
    
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}
- (IBAction)clickGroupToggle:(id)sender {
    int l_switch = 0;
    if (toggleGroup.tag == 1002){
        [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleGroup.tag = 1003;
        l_switch = 1;
    }else
        if (toggleGroup.tag == 1003){
            [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
            toggleGroup.tag = 1002;
            l_switch = 0;
        }
    
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi4];
        [self addNotifi4];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws disable_group_request:APP_TOKEN shopID:self.m_shopid];
        
    }
}
- (IBAction)clickSendInvite:(id)sender {
    invite_email.text = [Common trimString:invite_email.text];
    invite_username.text = [Common trimString:invite_username.text];
    if (invite_username.text.length == 0 && invite_email.text.length == 0)
    {
        [Common showAlert:@"Username or Email are empty"];
        return;
    }
    if (invite_email.text.length > 0 && ![Common checkEmailFormat:invite_email.text])
    {
        [Common showAlert:@"Invalid email"];
        return;
    }
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi3];
        [self addNotifi3];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws invite_user:APP_TOKEN username:invite_username.text email:invite_email.text shopID:self.m_shopid];
    }
}



//---UITableView---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 3000){
        return [memberArray count];
    }
    else //3001
    {
        return [requestArray count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 180;
    return 78;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 3000) // 3000 : Members
    {
        NSLog(@"test!");
        static NSString *simpleTableIdentifier = @"MemberCell";
        
        MemberCell *cell = (MemberCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MemberCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UserObj *obj = [memberArray objectAtIndex:indexPath.row];
        cell.userName.text = [NSString stringWithFormat:@"%@ %@", obj.fname, obj.lname];
        cell.memberID = obj.userID;
        cell.parent = self;
        cell.m_shop_detail_info = self.m_shop_detail_info;
        
        //---Image---
        UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
        NSURL *url = [NSURL URLWithString:obj.profile_pic_url];
        
        [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                               placeholderImage:holder
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             cell.thumbnails.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
             cell.thumbnails.layer.masksToBounds = YES;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             cell.thumbnails.image = holder;
         }];
        return cell;
    }
    else //3001 : Request
    {
        NSLog(@"test!");
        static NSString *simpleTableIdentifier = @"RequestCell";
        
        RequestCell *cell = (RequestCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RequestCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UserObj *obj = [requestArray objectAtIndex:indexPath.row];
        cell.userName.text = [NSString stringWithFormat:@"%@ %@", obj.fname, obj.lname];
        cell.requesterID = obj.userID;
        cell.parent = self;
        cell.m_shop_detail_info = self.m_shop_detail_info;
        
        //---Image---
        UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
        NSURL *url = [NSURL URLWithString:obj.profile_pic_url];
        
        [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                               placeholderImage:holder
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             cell.thumbnails.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
             cell.thumbnails.layer.masksToBounds = YES;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             cell.thumbnails.image = holder;
         }];

        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2000)
    {
        NSLog(@"didSelectRowAtIndexPath");
        /*UIAlertView *messageAlert = [[UIAlertView alloc]
         initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];*/
        UIAlertView *messageAlert = [[UIAlertView alloc]
                                     initWithTitle:@"Row Selected" message:[userNameData objectAtIndex:indexPath.row] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        //[messageAlert show];
    }
    // Checked the selected row
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}








//---WS CALL---
-(void)GetClubMembers
{
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        if (self.m_shopid == 0){
            [Common showAlert:@"Couldn't get this group information"];
            return;
        }
        //---WS API Call(photo detail)---
        [self removeNotifi];
        [self addNotifi];
    
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_clubmembers:APP_TOKEN shopID:self.m_shopid];
    }
}

-(void)GetRequestList
{
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        if (self.m_shopid == 0){
            [Common showAlert:@"Couldn't get this group information"];
            return;
        }
        //---WS API Call(photo detail)---
        [self removeNotifi2];
        [self addNotifi2];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_request_member_list:APP_TOKEN shopID:self.m_shopid];
    }
}



//==============WEBSERVICE(Get Club Members)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetClubMembers_Success:) name:k_get_clubmembers_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetClubMembers_Fail:) name:k_get_clubmembers_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_clubmembers_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_clubmembers_fail object:nil];
}
-(void) GetClubMembers_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetClubMembers_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        memberArray = [[NSMutableArray alloc] init];
        [memberArray removeAllObjects];
        
        NSDictionary* data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"members"] == [NSNull null]){
            [Common showAlert:@"No membership request"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeNotifi];
            return;
        }
        NSArray *arr = [data objectForKey:@"members"];
        if (arr == [NSNull null])
        {
            [Common showAlert:@"No membership request"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeNotifi];
            return;
        }
        
        for (NSDictionary *s in arr)
        {
            UserObj *obj = [[UserObj alloc] init];
            obj.userID = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
            obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
            obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
            obj.profile_pic_url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            
            [memberArray addObject:obj];
        }
        [memberListTableView reloadData];
        [self removeNotifi];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) GetClubMembers_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

//==============WEBSERVICE(Get Request List)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetRequestList_Success:) name:k_get_request_member_list_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetRequestList_Fail:) name:k_get_request_member_list_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_request_member_list_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_request_member_list_fail object:nil];
}
-(void) GetRequestList_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        requestArray = [[NSMutableArray alloc] init];
        [requestArray removeAllObjects];
        
        NSDictionary* data = [dic objectForKey:@"data"];
        int shop_status = [data objectForKey:@"shop_status"]!=[NSNull null] ? [[data objectForKey:@"shop_status"] intValue] : 0;
        if (shop_status == 0)
        {
            [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
            toggleGroup.tag = 1002;
        }else{
            [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
            toggleGroup.tag = 1003;
        }
        NSArray *arr = [data objectForKey:@"result"];
        if (arr == [NSNull null])
        {
            [Common showAlert:@"No membership requests"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeNotifi2];
            return;
        }
        
        for (NSDictionary *s in arr)
        {
            UserObj *obj = [[UserObj alloc] init];
            obj.userID = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
            obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
            obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
            obj.profile_pic_url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            
            [requestArray addObject:obj];
        }
        [requestListTableView reloadData];
        [self removeNotifi2];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) GetRequestList_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}



//==============WEBSERVICE(Invite user)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InviteUser_Success:) name:k_invite_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InviteUser_Fail:) name:k_invite_user_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_invite_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_invite_user_fail object:nil];
}
-(void) InviteUser_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully Invited"];
        [self removeNotifi3];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}
-(void) InviteUser_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}



//==============WEBSERVICE(Disable Request)============
- (void)addNotifi4
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DisableRequest_Success:) name:k_disable_group_request_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DisableRequest_Fail:) name:k_disable_group_request_fail object:nil];
}
- (void)removeNotifi4
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_disable_group_request_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_disable_group_request_fail object:nil];
}
-(void) DisableRequest_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"DisableRequest_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully Disabled"];
        [self removeNotifi4];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}
-(void) DisableRequest_Fail:(NSNotification*)notif
{
    NSLog(@"DisableRequest_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}
@end
