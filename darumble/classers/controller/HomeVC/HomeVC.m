//
//  HomeVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/26/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "HomeVC.h"
#import "AppDelegate.h"
#import "MyAccountVC.h"
#import "HomeCell.h"
#import "MessageHistoryVC.h"
#import "MessageComposeVC.h"

@interface HomeVC ()
{
    
    __weak IBOutlet UICollectionView *_clMenu;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIImageView *_imgBottom;
    BOOL PORTRAIT_ORIENTATION;
    
}
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    UINib *cellNib ;
    if (IS_IPAD) {
        cellNib = [UINib nibWithNibName:@"HomeCell_iPad" bundle:nil];
    }
    else
    {
        cellNib= [UINib nibWithNibName:@"HomeCell" bundle:nil];
    }
    [_clMenu registerNib:cellNib forCellWithReuseIdentifier:@"HomeCell"];

    
    
    //************************//
    //*         GCM          *//
    //************************//
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRegistrationStatus:)
                                                 name:appDelegate.registrationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showReceivedMessage:)
                                                 name:appDelegate.messageKey
                                               object:nil];
    NSString *token = [USER_DEFAULT objectForKey:@"registrationToken"];
    token = [Common trimString:token];    
    if (token.length == 0)
    {
//        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Registering Notification..." animated:YES]; //-----
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
        _imgBottom.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"img_ipad.png":@"img_landscape_ipad.png"];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
        _imgBottom.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"img_ipad.png":@"img_landscape_ipad.png"];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] == 0) {
        AppDelegate *app = [Common appDelegate];
        [app initLogin];
    }else
    {
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        }];
    }
}

- (IBAction)clickGallery:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] == 0) {
        AppDelegate *app = [Common appDelegate];
        [app initLogin];
    }else
    {
        AppDelegate *app = [Common appDelegate];
        //[Common showAlert:@"Global Feed"];
        [app openTabbar:0];
    }
}

- (IBAction)clickEvent:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] == 0) {
        AppDelegate *app = [Common appDelegate];
        [app initLogin];

    }
    else
    {
        AppDelegate *app = [Common appDelegate];
        //[Common showAlert:@"Local Feed"];
        [app openTabbar:1];
    }
    
}

- (IBAction)clickShopClub:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] == 0) {
        AppDelegate *app = [Common appDelegate];
        [app initLogin];
    }else
    {
        AppDelegate *app = [Common appDelegate];
        //[Common showAlert:@"Messages"];
        [app openTabbar:3];
    }
}

- (IBAction)clickAccount:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] == 0) {
        AppDelegate *app = [Common appDelegate];
        [app initLogin];
    }else
    {
        AppDelegate *app = [Common appDelegate];
        [app openTabbar:4];
    }
}


- (IBAction)clickSearch:(id)sender
{
    AppDelegate *app = [Common appDelegate];
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] == 0)
    {
        [app initLogin];
    }else
    {
        [app showSearchItems];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HomeCell";
    
    HomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.btnMenu.tag = indexPath.row;
    [cell.btnMenu addTarget:self action:@selector(clickSelectCat:) forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPAD) {
        switch (indexPath.row) {
            case 0:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_global_ipad@2x.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_global_on_ipad@2x.png"] forState:UIControlStateHighlighted];
                
                break;
            case 1:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_local_ipad@2x.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_local_on_ipad@2x.png"] forState:UIControlStateHighlighted];
                break;
            case 2:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_message_ipad@2x.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_message_on_ipad@2x.png"] forState:UIControlStateHighlighted];
                break;
            case 3:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_my_account_ipad@2x.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_my_account_on_ipad@2x.png"] forState:UIControlStateHighlighted];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_global.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_global_on.png"] forState:UIControlStateHighlighted];
                
                break;
            case 1:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_local.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_local_on.png"] forState:UIControlStateHighlighted];
                break;
            case 2:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_message.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_message_on.png"] forState:UIControlStateHighlighted];
                break;
            case 3:
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_my_account.png"] forState:UIControlStateNormal];
                [cell.btnMenu setImage:[UIImage imageNamed:@"ic_my_account_on.png"] forState:UIControlStateHighlighted];
                break;
                
                
            default:
                break;
        }

    }
    
    return cell;
}

- (IBAction)clickSelectCat:(id)sender {
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 0:
        {
            [self clickGallery:nil];
        }
            break;
        case 1:
        {
            [self clickEvent:nil];
        }
            break;
        case 2:
        {
            [self clickShopClub:nil];
        }
            break;
        case 3:
        {
            [self clickAccount:nil];
        }
            break;
        default:
            break;
    }
}
//==============WEBSERVICE============8965321478
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Add_user_success:) name:k_get_categories_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Add_user_fail:) name:k_get_garage_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_categories_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_garage_fail object:nil];
}
-(void) Add_user_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void) Add_user_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void)Call_services{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    //[ws add_user:APP_TOKEN username:@"thanh" fname:@"Phan" lname:@"Thanh" email:@"thanh@gmail.com" password:@"123456" repassword:@"123456" age:15 terms_agreed:@"yes" phone:@"0905123456" zip:@"590000" clubName:@""];
    [ws get_users:APP_TOKEN userID:12];
    [ws get_categories:APP_TOKEN];
}


//************************//
//*         GCM          *//
//************************//
- (void) updateRegistrationStatus:(NSNotification *) notification {
    if ([notification.userInfo objectForKey:@"error"]) {
        _registeringLabel.text = @"Error registering!";
//        [self showAlert:@"Error registering with GCM" withMessage:notification.userInfo[@"error"]];
    } else {
        _registeringLabel.text = @"Registered!";
        NSString *message = @"Check the xcode debug console for the registration token that you can"
        " use with the demo server to send notifications to your device";
//        [self showAlert:@"Registration Successful" withMessage:message];
    };
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) showReceivedMessage:(NSNotification *) notification
{
    NSString *messageBody = @"";
    NSString *sender = @"";
    @try{
        sender = [[notification.userInfo[@"aps"][@"alert"][@"body"] componentsSeparatedByString:@":"] objectAtIndex:2];
        messageBody = [NSString stringWithFormat:@"%@(%@)",[[notification.userInfo[@"aps"][@"alert"][@"body"] componentsSeparatedByString:@":"] objectAtIndex:1]
                       ,sender];
    }@catch(NSException *ex)
    {
        sender = @"";
        messageBody = [NSString stringWithFormat:@"%@",[[notification.userInfo[@"aps"][@"alert"][@"body"] componentsSeparatedByString:@":"] objectAtIndex:1]];
    }
    [self showAlert:notification.userInfo[@"aps"][@"alert"][@"title"] withMessage:messageBody];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *) message{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        //iOS 8 or later
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:nil];
        
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if ([title isEqualToString:@"Message"])
    {
        /*
         //---remove messagehistoryvc if this is opened----
         for (UIViewController *controller in self.navigationController.viewControllers)
         {
         if ([controller isKindOfClass:[MessageHistoryVC class]])
         {
         [self.navigationController popToViewController:controller animated:YES];
         break;
         }
         }
         //---Redirecting To MessageVC---
         MessageHistoryVC *vc = [[MessageHistoryVC alloc] init];
         [self.navigationController pushViewController:vc animated:NO];
         */
        
        AppDelegate *app = [Common appDelegate];
        app.msg_redir = 2;
        [app showMessages];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
