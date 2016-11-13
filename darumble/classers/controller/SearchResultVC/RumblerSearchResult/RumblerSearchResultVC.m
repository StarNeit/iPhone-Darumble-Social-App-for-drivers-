//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "RumblerSearchResultVC.h"
#import "RumblerCell.h"
#import "UIImageView+AFNetworking.h"
#import "PublicProfileVC.h"

@interface RumblerSearchResultVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UITableView *rumblerListTableView;
    NSMutableArray *rumblerArray;
    IBOutlet UITextField *rumblername_filter;
    IBOutlet UILabel *label_no_result;
    
    int m_selectedUserID;
}
@end

@implementation RumblerSearchResultVC
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
    
    //---WS API Call(search rumbler)---//
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws search_rumbler:APP_TOKEN username:self.username email:@"" firstname:self.firstname lastname:self.lastname];
    }
    rumblername_filter.hidden = YES;
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"Rumblers";
    [self addGestureRecognizers];
    
//    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,1100)];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self._srcMain addGestureRecognizer:singleTap];
    
    
    rumblerListTableView.tableFooterView = [[UIView alloc] init];
}

//---Gesture Recognizer----
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [self._srcMain setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)addGestureRecognizers {
    [[self view] addGestureRecognizer:[self panGestureRecognizer]];
}
- (UIPanGestureRecognizer *)panGestureRecognizer {
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


//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rumblerArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 180;
    return 78;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---MessageHistoryList---
    NSLog(@"test!");
    static NSString *simpleTableIdentifier = @"RumblerCell";
    
    RumblerCell *cell = (RumblerCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RumblerCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    UserObj *rumbler = [rumblerArray objectAtIndex:indexPath.row];
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", rumbler.fname, rumbler.lname];
    cell.email.text = rumbler.email;
    
    //---Rumbler Image---
    UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
    NSURL *url = [NSURL URLWithString:rumbler.profile_pic_url];
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserObj *rumbler = [rumblerArray objectAtIndex:indexPath.row];
    
    m_selectedUserID = rumbler.userID;
  
    //---WS API CALL(check blocked status)---
    [self removeNotifi5];
    [self addNotifi5];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws check_blocked_status:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] userID2:rumbler.userID];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == rumblername_filter)
    {
        [rumblername_filter resignFirstResponder];
        
        rumblername_filter.text = [Common trimString:rumblername_filter.text];
        
        if (rumblername_filter.text.length == 0)
        {
            return true;
        }
        
        RumblerSearchResultVC *vc = [[RumblerSearchResultVC alloc] init];
        vc.username = @"";
        vc.firstname = rumblername_filter.text;
        vc.lastname = rumblername_filter.text;
        [self.navigationController pushViewController:vc animated:NO];
    }
    return true;
}



//---UI Controller---
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1991)//unblock user
    {
        if (buttonIndex == 0)//no
        {
            
        }else if (buttonIndex == 1)//yes
        {
            //---WS API CALL(block user)---
            [self removeNotifi7];
            [self addNotifi7];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws block_user:APP_TOKEN blocker_id:[[USER_DEFAULT objectForKey:@"userID"] intValue] blockee_id:m_selectedUserID status:2];
        }
    }
}



//==============WEBSERVICE(Rumbler Search)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RumblerSearch_Success:) name:k_search_rumbler_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RumblerSearch_Fail:) name:k_search_rumbler_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_rumbler_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_rumbler_fail object:nil];
}
-(void) RumblerSearch_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"RumblerSearch_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        rumblername_filter.hidden = NO;
        rumblerArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"search_info"] != [NSNull null])
        {
            NSArray *arr = [data objectForKey:@"search_info"];
            for (NSDictionary *s in arr)
            {
                UserObj* obj = [[UserObj alloc] init];
                obj.userID = [s objectForKey:@"id"] != [NSNull null] ? [[s objectForKey:@"id"] intValue] : 0;
                obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                obj.username = [s objectForKey:@"username"] != [NSNull null] ? [s objectForKey:@"username"] : @"";
                obj.email = [s objectForKey:@"email"] != [NSNull null] ? [s objectForKey:@"email"] : @"";
                obj.profile_pic_url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                [rumblerArray addObject:obj];
            }
            [self removeNotifi];
            [rumblerListTableView reloadData];
            label_no_result.hidden = YES;
            rumblername_filter.hidden = NO;
        }else{
            [Common showAlert:@"No rumblers found"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeNotifi];
            label_no_result.hidden = NO;
            
            rumblername_filter.hidden = YES;
            return;
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
        label_no_result.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) RumblerSearch_Fail:(NSNotification*)notif
{
    NSLog(@"RumblerSearch_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}


//==============WEBSERVICE(check blocked status)============
- (void)addNotifi5
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckBlockedStatus_Success:) name:k_check_blocked_status_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckBlockedStatus_Fail:) name:k_check_blocked_status_fail object:nil];
}
- (void)removeNotifi5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_check_blocked_status_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_check_blocked_status_fail object:nil];
}
-(void) CheckBlockedStatus_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"CheckBlockedStatus_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        PublicProfileVC *vc = [[PublicProfileVC alloc] init];
        vc.m_userID = m_selectedUserID;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        int result;
        
        result = [[dic objectForKey:@"data"] objectForKey:@"Result"] != NULL ? [[[dic objectForKey:@"data"] objectForKey:@"Result"] intValue] : 0;
        if (result == 1)//you did block
        {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"You did block this user. Are you sure to unblock now?",nil)
                                       delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
            errorAlert.tag = 1991;
            [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
            [errorAlert show];
        }else if (result == 2)//you're blocked
        {
            [Common showAlert:@"You were blocked from this user."];
        }
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}
-(void) CheckBlockedStatus_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}



//==============WEBSERVICE(Unblock User)============
- (void)addNotifi7
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Unblock_Success:) name:k_block_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Unblock_Fail:) name:k_block_user_fail object:nil];
}
- (void)removeNotifi7
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_user_fail object:nil];
}
-(void) Unblock_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"Unblock_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"This user is unblocked now."];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi7];
}
-(void) Unblock_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi7];
}
@end
