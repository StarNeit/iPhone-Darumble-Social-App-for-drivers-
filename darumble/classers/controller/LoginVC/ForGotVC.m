//
//  ForGotVC.m
//  DaRumble
//
//  Created by Vidic Phan on 3/29/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ForGotVC.h"

@interface ForGotVC ()<UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UITextField *_txfEmail;
    __weak IBOutlet UIImageView *_bgMain;
    BOOL PORTRAIT_ORIENTATION;
}
@end

@implementation ForGotVC

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
    [_scrMain setContentSize:CGSizeMake(0, 500)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    [self removeNotifi];
    [self addNotifi];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Forgot_password_success:) name:k_forgot_password_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Forgot_password_fail:) name:k_forgot_password_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_forgot_password_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_forgot_password_fail object:nil];
}
-(void) Forgot_password_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [Common showAlert:@"Email was sent, please check new password in your inbox mail."];
        [self removeNotifi];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void) Forgot_password_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [_scrMain setContentOffset:CGPointMake(0, 0) animated:YES];
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

- (IBAction)clickSendPass:(id)sender {
    _txfEmail.text = trimString(_txfEmail.text);
    if (_txfEmail.text.length == 0) {
        [Common showAlert:ERROR_MISS_EMAIL];
        [_txfEmail becomeFirstResponder];
    }else if (![Common checkEmailFormat:_txfEmail.text])
    {
        [Common showAlert:ERROR_EMAIL_FORMAT];
        [_txfEmail becomeFirstResponder];
    }else
    {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws forgot_password:APP_TOKEN email:_txfEmail.text];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txfEmail) {
        [self clickSendPass:nil];
    }
    return YES;
}

- (IBAction)clickClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
