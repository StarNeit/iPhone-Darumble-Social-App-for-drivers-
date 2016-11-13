//
//  LoginVC.m
//  DaRumble
//
//  Created by Vidic Phan on 3/29/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "LoginVC.h"
#import "ForGotVC.h"
#import "RegisterVC.h"
#import "FacebookUtility.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginVC ()<UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UITextField *_txfEmail;
    __weak IBOutlet UITextField *_txfPass;
    __weak IBOutlet UIImageView *_bgMain;
    BOOL PORTRAIT_ORIENTATION;
}
@end

@implementation LoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [_scrMain setContentSize:CGSizeMake(0, 550)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myNotificationMethod:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)myNotificationMethod:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    NSLog(@"%f", keyboardFrameBeginRect.size.height);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (IS_IPAD) {
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [_scrMain setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickLoginClose:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [app closeLogin];
}

- (IBAction)clickLoginFB:(id)sender {
    
    if ([FacebookUtility sharedObject].session.state!=FBSessionStateOpen)
    {
        [[FacebookUtility sharedObject]getFBToken];
    }
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        [self getFacebookUserDetails];
    }
    else
    {
        [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
         {
             if (success)
             {
                 if ([FacebookUtility sharedObject].session.state==FBSessionStateOpen)
                 {
                     [self getFacebookUserDetails];
                 }
             }
             else
             {
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Error"
                                           message:error.localizedDescription
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
    }
}

-(void)getFacebookUserDetails
{
    //me?fields=id,birthday,gender,first_name,age_range,last_name,name,picture.type(normal)
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        [[FacebookUtility sharedObject]fetchMeWithFields:@"id,birthday,email,gender,first_name,age_range,last_name,name,picture.type(large)" FBCompletionBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 [USER_DEFAULT setValue:[NSMutableDictionary dictionaryWithDictionary:response] forKey:UD_FB_USER_DETAIL];
                 [self parseLogin:response];
             }
             else
             {
                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 alert.tag = 202;
                 [alert show];
             }
         }];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}

#pragma mark -
#pragma mark -  login Parse methods
-(void)parseLogin :(NSDictionary*)FBUserDetailDict
{
    
    NSLog(@"%@", FBUserDetailDict);
    NSString *proPic=@"https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif";
    if ([[[FBUserDetailDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]!=nil)
    {
        proPic=[[[FBUserDetailDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    }
    
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    NSString *registration_key = [USER_DEFAULT objectForKey:@"registrationToken"];
    registration_key = @"test";//--------registration_key = @"test";
    
    if ([registration_key isEqualToString:@""] || registration_key == nil)
    {
        [Common showAlert:@"GCM token isn't assigned, please check your network status"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    DataCenter *ws = [[DataCenter alloc] init];
    [ws loginfb:[FBUserDetailDict objectForKey:@"id"] fb_email:[FBUserDetailDict objectForKey:@"email"] fb_fname:[FBUserDetailDict objectForKey:@"first_name"] fb_lname:[FBUserDetailDict objectForKey:@"last_name"] fb_age:[[FBUserDetailDict objectForKey:@"age_range"] objectForKey:@"min"] fb_zipcode:@"" fb_phone:@"" registration_key:registration_key];
}

- (IBAction)clickLoginNormal:(id)sender {
    [self.view endEditing:YES];
    _txfEmail.text = trimString(_txfEmail.text);
    _txfPass.text = trimString(_txfPass.text);
    if (_txfEmail.text.length == 0) {
        [Common showAlert:ERROR_MISS_EMAIL];
        [_txfEmail becomeFirstResponder];
    }else if (_txfPass.text.length == 0)
    {
        [Common showAlert:ERROR_MISS_PASSWORD];
        [_txfPass becomeFirstResponder];
    }else
    {
        [self loadWS];
    }
}

- (void) loadWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];

    NSString *registration_key = [USER_DEFAULT objectForKey:@"registrationToken"];
    registration_key = @"test";//-------
    
    if ([registration_key isEqualToString:@""] || registration_key == nil)
    {
        [Common showAlert:@"GCM token isn't assigned, please check your network status"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    DataCenter *ws = [[DataCenter alloc] init];
    [ws login:APP_TOKEN username:_txfEmail.text password:_txfPass.text registration_key:registration_key];
}

//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Login_success:) name:k_login_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Login_fail:) name:k_login_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Login_fb_success:) name:k_login_fb_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Login_fb_fail:) name:k_login_fb_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_login_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_login_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_login_fb_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_login_fb_fail object:nil];
}

-(void) Login_success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"LOGIN SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [ParseUtil parse_add_userDic:dic andPass:_txfPass.text];
        _txfEmail.text = @"";
        _txfPass.text = @"";
        [USER_DEFAULT setValue:@"1" forKey:@"DaRumble_Login"];
        NSLog(@"------>%@",[USER_DEFAULT objectForKey:@"country"]);
        if (![USER_DEFAULT objectForKey:@"country"] || [[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"(null)"] || [[USER_DEFAULT objectForKey:@"country"] length]==0)
        {
            AppDelegate *app = [Common appDelegate];
            app.isEditProfielMenu = YES;
            [app openTabbar:4];
            [[Common appDelegate].sideMenu loadAvatar];
        }
        else
        {
            if ([[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"United States"])
            {
                if (![USER_DEFAULT objectForKey:@"zip"] || [[USER_DEFAULT objectForKey:@"zip"] isEqualToString:@"(null)"] || [[USER_DEFAULT objectForKey:@"zip"] length]==0)
                {
                    AppDelegate *app = [Common appDelegate];
                    app.isEditProfielMenu = YES;
                    [app openTabbar:4];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
                else
                {
                    AppDelegate *app = [Common appDelegate];
                    [app closeLogin];
                    [app enableTabbar];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
            }
            else
            {
                if (![USER_DEFAULT objectForKey:@"city"] || [[USER_DEFAULT objectForKey:@"city"] isEqualToString:@"(null)"] || [[USER_DEFAULT objectForKey:@"city"] length]==0)
                {
                    AppDelegate *app = [Common appDelegate];
                    app.isEditProfielMenu = YES;
                    [app openTabbar:4];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
                else
                {
                    AppDelegate *app = [Common appDelegate];
                    [app closeLogin];
                    [app enableTabbar];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
            }
        }
        //[Common showAlert:@"Successfully logged in"];
        
        AppDelegate *app = [Common appDelegate];
        [app initSideMenu];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Login_fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) Login_fb_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [ParseUtil parse_add_userFacebbook:dic andPass:_txfPass.text];
        _txfEmail.text = @"";
        _txfPass.text = @"";
        [USER_DEFAULT setValue:@"1" forKey:@"DaRumble_Login"];
        NSLog(@"---->>%@",[USER_DEFAULT objectForKey:@"country"]);
        if (![USER_DEFAULT objectForKey:@"country"] || [[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"(null)"] || [[USER_DEFAULT objectForKey:@"country"] length]==0) {
            AppDelegate *app = [Common appDelegate];
            app.isEditProfielMenu = YES;
            [app openTabbar:4];
            [[Common appDelegate].sideMenu loadAvatar];
        }
        else
        {
            if ([[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"United States"]) {
                 if (![USER_DEFAULT objectForKey:@"zip"] || [[USER_DEFAULT objectForKey:@"zip"] isEqualToString:@"(null)"] || [[USER_DEFAULT objectForKey:@"zip"] length]==0) {
                     AppDelegate *app = [Common appDelegate];
                     app.isEditProfielMenu = YES;
                     [app openTabbar:4];
                     [[Common appDelegate].sideMenu loadAvatar];
                 }
                else
                {
                    AppDelegate *app = [Common appDelegate];
                    [app closeLogin];
                    [app enableTabbar];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
            }
            else
            {
                if (![USER_DEFAULT objectForKey:@"city"] || [[USER_DEFAULT objectForKey:@"city"] isEqualToString:@"(null)"] || [[USER_DEFAULT objectForKey:@"city"] length]==0)
                {
                    AppDelegate *app = [Common appDelegate];
                    app.isEditProfielMenu = YES;
                    [app openTabbar:4];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
                else
                {
                    AppDelegate *app = [Common appDelegate];
                    [app closeLogin];
                    [app enableTabbar];
                    [[Common appDelegate].sideMenu loadAvatar];
                }
            }
        }
        /*if ([dic objectForKey:@"city"] ) {
            
            AppDelegate *app = [Common appDelegate];
            [app closeLogin];
            [app enableTabbar];
            [[Common appDelegate].sideMenu loadAvatar];
        }
        else
        {
            AppDelegate *app = [Common appDelegate];
            app.isEditProfielMenu = YES;
            [app openTabbar:4];
            [[Common appDelegate].sideMenu loadAvatar];
         }*/
        
        //[Common showAlert:@"Successfully logged in"];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Login_fb_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (IBAction)clickForGot:(id)sender {
    ForGotVC *vc = [[ForGotVC alloc] initWithNibName:[NSString stringWithFormat:@"ForGotVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickRegister:(id)sender {
    RegisterVC *vc = [[RegisterVC alloc] initWithNibName:[NSString stringWithFormat:@"RegisterVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txfEmail) {
        [_txfPass becomeFirstResponder];
    }else if (textField == _txfPass)
    {
        [self clickLoginNormal:nil];
    }
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
