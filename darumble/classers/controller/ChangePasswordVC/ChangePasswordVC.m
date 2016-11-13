//
//  ChangePasswordVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ChangePasswordVC.h"

@interface ChangePasswordVC ()<UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UITextField *_txfOldPass;
    __weak IBOutlet UITextField *_txfNewPass;
    __weak IBOutlet UITextField *_txfRePass;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIImageView *_bgTopBar;
    BOOL PORTRAIT_ORIENTATION;
    CGPoint velocityF;
    CGPoint velocityL;
}
@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //---Setting ScrollView Size---
    [_scrMain setContentSize:CGSizeMake(0, 500)];
    
    //---Getting SingleTap Gesture---
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    
    [self removeNotifi];
    [self addNotifi];
    [self addGestureRecognizers];
}

//---Gesture Recognizer Process---
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
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//---Memory Process---
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Change_password_success:) name:k_edit_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Change_password_fail:) name:k_edit_user_fail object:nil];
}

- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_user_fail object:nil];
}

-(void) Change_password_success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Change password successfully"];
        [USER_DEFAULT setValue:_txfNewPass.text forKey:@"password"];
        [self removeNotifi];
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void) Change_password_fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

//---Functions for Device Orientation Process---
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

//---SingleTap Gesture Process---
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    //---Close keyboard for any text edit views that are children of the main view---
    [gestureRecognizer.view endEditing:YES];
    //---Set Scroll Pos to (0,0)---
    [_scrMain setContentOffset:CGPointMake(0, 0) animated:YES];
}

//---SideMenuProcess---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

//---UI Process---
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txfOldPass)
    {
        [_txfNewPass becomeFirstResponder];
    }else if (textField == _txfNewPass)
    {
        [_txfRePass becomeFirstResponder];
    }else if (textField == _txfRePass)
    {
        [self clickUpdate:nil];
    }
    return YES;
}

//---WS API---
- (IBAction)clickUpdate:(id)sender
{
    _txfOldPass.text = trimString(_txfOldPass.text);
    _txfNewPass.text = trimString(_txfNewPass.text);
    _txfRePass.text = trimString(_txfRePass.text);
    
    if (![_txfOldPass.text isEqualToString:[USER_DEFAULT objectForKey:@"password"]])
    {
        [Common showAlert:@"Old password is incorrect"];
    }else if (_txfNewPass.text.length == 0)
    {
        [Common showAlert:@"New password cannot be empty"];
    }else if (_txfRePass.text.length == 0)
    {
        [Common showAlert:@"Re-New password cannot be empty"];
    }else if (![_txfNewPass.text isEqualToString:_txfRePass.text])
    {
        [Common showAlert:@"Re-New password did not match"];
    }else
    {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        
        DataCenter *ws = [[DataCenter alloc] init];
        [ws edit_user:APP_TOKEN
            userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]
            username:[USER_DEFAULT objectForKey:@"username"]
            fname:[USER_DEFAULT objectForKey:@"fname"]
            lname:[USER_DEFAULT objectForKey:@"lname"]
            email:[USER_DEFAULT objectForKey:@"email"]
            password:_txfNewPass.text
            repassword:_txfRePass.text
            age:([[USER_DEFAULT objectForKey:@"age"] intValue]<18)?(18):([[USER_DEFAULT objectForKey:@"age"] intValue])
            phone:([USER_DEFAULT objectForKey:@"phone"]!=nil)?([USER_DEFAULT objectForKey:@"phone"]):(@"")
            zip:([USER_DEFAULT objectForKey:@"zip"]!=nil)?([USER_DEFAULT objectForKey:@"zip"]):(@"")
            clubName:(![[USER_DEFAULT objectForKey:@"clubName"] isEqualToString:@"<null>"])?([USER_DEFAULT objectForKey:@"clubName"]):(@"")
            andCountry:([USER_DEFAULT objectForKey:@"zip"]!=nil)?([USER_DEFAULT objectForKey:@"country"]):(@"")
            andType:1
         ];
    }
}
@end
