//
//  RegisterVC.m
//  DaRumble
//
//  Created by Vidic Phan on 3/29/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "RegisterVC.h"
#import "Common.h"
#import "Define.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
#import "PickerView.h"
#import "LoginVC.h"

@interface RegisterVC ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate,PickerViewDelegate>
{
    BOOL isCheck;
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UITextField *_txfUsername;
    __weak IBOutlet UITextField *_txfFirst;
    __weak IBOutlet UITextField *_txfLast;
    __weak IBOutlet UITextField *_txfEmail;
    __weak IBOutlet UITextField *_txfPass;
    __weak IBOutlet UITextField *_txfRePass;
    __weak IBOutlet UITextField *_txfAge;
    __weak IBOutlet UITextField *_txfPhone;
    __weak IBOutlet UIButton *_btnCheck;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UITextField *_txfZipCode;
    
    NSMutableArray *_arrCountries;
    BOOL PORTRAIT_ORIENTATION;
    NSString *strTermOfCondition;
}

@property (weak, nonatomic) IBOutlet UITextField *txfCountry;
- (IBAction)doCountry:(id)sender;
@property(nonatomic,retain) PickerView *pickerView;
@end

@implementation RegisterVC

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
    [_scrMain setContentSize:CGSizeMake(0, IS_IPAD?1100:800)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    
    [self loadTermAndCondition];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (IBAction)clickClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickCheck:(id)sender {
    if (isCheck) {
        [_btnCheck setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        isCheck = NO;
    }else
    {
        [_btnCheck setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
        isCheck = YES;
    }
}

- (IBAction)clickSend:(id)sender {
    _txfUsername.text = trimString(_txfUsername.text);
    _txfFirst.text = trimString(_txfFirst.text);
    _txfLast.text = trimString(_txfLast.text);
    _txfEmail.text = trimString(_txfEmail.text);
    _txfPass.text = trimString(_txfPass.text);
    _txfRePass.text = trimString(_txfRePass.text);
    _txfAge.text = trimString(_txfAge.text);
    _txfPhone.text = trimString(_txfPhone.text);
    _txfZipCode.text = trimString(_txfZipCode.text);
    if (_txfUsername.text.length == 0) {
        [Common showAlert:EROOR_MISS_USERNAME];
        [_txfUsername becomeFirstResponder];
    }else if (_txfFirst.text.length == 0) {
        [Common showAlert:EROOR_MISS_FIRSTNAME];
        [_txfFirst becomeFirstResponder];
    }else if (_txfLast.text.length == 0) {
        [Common showAlert:EROOR_MISS_LASTNAME];
        [_txfLast becomeFirstResponder];
    }else if (_txfEmail.text.length == 0) {
        [Common showAlert:ERROR_MISS_EMAIL];
        [_txfEmail becomeFirstResponder];
    }else if (![Common checkEmailFormat:_txfEmail.text]) {
        [Common showAlert:ERROR_EMAIL_FORMAT];
        [_txfEmail becomeFirstResponder];
    }else if (_txfPass.text.length == 0) {
        [Common showAlert:ERROR_MISS_PASSWORD];
        [_txfPass becomeFirstResponder];
    }else if (![_txfPass.text isEqualToString:_txfRePass.text]) {
        [Common showAlert:ERROR_MISS_CURRENT_PASSWORD_MATCH];
        [_txfRePass becomeFirstResponder];
    }/*else if (_txfAge.text.length == 0) {
        [Common showAlert:EROOR_MISS_AGE];
        [_txfAge becomeFirstResponder];
    }else if (_txfPhone.text.length == 0) {
        [Common showAlert:EROOR_MISS_PHONE];
        [_txfPhone becomeFirstResponder];
    }*/
    
    /*else if([_txfCountry.text isEqualToString:@"United States"] && _txfZipCode.text.length == 0)
    {
     
        
    }else if(![_txfCountry.text isEqualToString:@"United States"])
    {
        if (_txfZipCode.text.length == 0) {
            [Common showAlert:EROOR_MISS_CITY];
            [_txfZipCode becomeFirstResponder];
        }
    }*/
    else if (!isCheck) {
        [Common showAlert:EROOR_MISS_TERM];
    }else
    {
        /*
        if([_txfCountry.text isEqualToString:@"United States"])
        {
            if (_txfZipCode.text.length == 0) {
                [Common showAlert:EROOR_MISS_ZIPCODE];
                [_txfZipCode becomeFirstResponder];
            }
            else
            {
                [self loadWS];
            }
        }
        else
        {
            if (_txfZipCode.text.length == 0) {
            [Common showAlert:EROOR_MISS_CITY];
            [_txfZipCode becomeFirstResponder];
        }
        else
        {
            [self loadWS];
        }
            
        }*/
        
        [self loadWS];
    }
}

- (void) loadWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    if([_txfCountry.text isEqualToString:@"United States"])
    {
         [ws add_user:APP_TOKEN username:_txfUsername.text fname:_txfFirst.text lname:_txfLast.text email:_txfEmail.text password:_txfPass.text repassword:_txfRePass.text age:[_txfAge.text intValue] terms_agreed:@"1" phone:_txfPhone.text zip:_txfZipCode.text clubName:@"" andCountry:_txfCountry.text andType:1];
    }
    else
    {
         [ws add_user:APP_TOKEN username:_txfUsername.text fname:_txfFirst.text lname:_txfLast.text email:_txfEmail.text password:_txfPass.text repassword:_txfRePass.text age:[_txfAge.text intValue] terms_agreed:@"1" phone:_txfPhone.text zip:_txfZipCode.text clubName:@"" andCountry:_txfCountry.text andType:2];
    }   
}

//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Register_success:) name:k_add_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Register_fail:) name:k_add_user_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_user_fail object:nil];
}

-(void) Register_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    NSLog(@"DIC %@",dic);
    if ([[dic objectForKey:@"code"] intValue] == 200) {
       
        /*[ParseUtil parse_add_userDic:dic andPass:_txfPass.text];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [USER_DEFAULT setValue:@"1" forKey:@"DaRumble_Login"];
        AppDelegate *app = [Common appDelegate];
         [app closeLogin];
        [app enableTabbar];*/
        //[self.navigationController popToRootViewControllerAnimated:YES];
        // AppDelegate *app = [Common appDelegate];
         //[app initLogin];
        
        
        [Common showAlert:@"Successfully registered"];
        LoginVC *vc = [[LoginVC alloc] init];
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
  
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Register_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txfUsername) {
        [_txfFirst becomeFirstResponder];
    }else if(textField == _txfFirst)
    {
        [_txfLast becomeFirstResponder];
    }else if(textField == _txfLast)
    {
        [_txfEmail becomeFirstResponder];
    }else if(textField == _txfEmail)
    {
        [_txfPass becomeFirstResponder];
    }else if(textField == _txfPass)
    {
        [_txfRePass becomeFirstResponder];
    }else if(textField == _txfRePass)
    {
        [_txfAge becomeFirstResponder];
    }else if(textField == _txfAge)
    {
        [_txfPhone becomeFirstResponder];
    }else if(textField == _txfPhone)
    {
        [_txfZipCode becomeFirstResponder];
    }
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
   if (!IS_IPAD) {
        if (textField ==_txfUsername || textField ==_txfFirst  || textField ==_txfLast ||textField == _txfEmail) {
            [_scrMain setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else if(textField ==_txfPass)
        {
            [_scrMain setContentOffset:CGPointMake(0,60) animated:YES];
        }
        else if(textField ==_txfRePass)
        {
            [_scrMain setContentOffset:CGPointMake(0,120) animated:YES];
        }
        else if(textField ==_txfAge)
        {
            [_scrMain setContentOffset:CGPointMake(0,180) animated:YES];
        }
        else if(textField ==_txfPhone)
        {
            [_scrMain setContentOffset:CGPointMake(0,240) animated:YES];
        }
        else if(textField ==_txfZipCode)
        {
            [_scrMain setContentOffset:CGPointMake(0,300) animated:YES];
        }
    }
    else
    {
      
    }
}
-(void) loadTermAndCondition
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/terms/"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/terms"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        if ([[response objectForKey:@"code"] integerValue]==200) {
            NSLog(@"REPONSE %@",response);
            strTermOfCondition = [[response objectForKey:@"data"] objectForKey:@"termsText"];
            [self loadAllCountry];
        }
       
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"add_garage: %@", error);
    }];
    
}


-(void) loadAllCountry
{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"/get/countries/"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"/get/countries/"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        if ([[response objectForKey:@"code"] integerValue]==200) {
            _arrCountries = [[NSMutableArray alloc] init];
            NSLog(@"REPONSE %@",response);
            NSArray *arrs = [[response objectForKey:@"data"] objectForKey:@"countries"];
            NSLog(@"ARRS -->%@",arrs);
            [_arrCountries addObject:@"United States"];
            for (NSString *str in arrs) {
                if (![str isEqualToString:@"United States"]) {
                     [_arrCountries addObject:str];
                }
               
            }
           
            
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_garage: %@", error);
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}


- (IBAction)doCheck:(id)sender {
//    UIAlertView *alert =[ [UIAlertView alloc] initWithTitle:nil message:strTermOfCondition delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
//    alert.tag = 1000;
//    [alert show];
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:nil message:NSLocalizedString(strTermOfCondition,nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = 4040;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 4040)
    {
        if (buttonIndex == 0) //no
        {
            [_btnCheck setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            isCheck = NO;
        }else if (buttonIndex == 1) //yes
        {
            [_btnCheck setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
            isCheck = YES;
        }
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==1000) {
        switch (buttonIndex) {
            case 0:
            {
                
                [_btnCheck setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
                isCheck = YES;
                
                
            }
                break;
                
            case 1:
            {
                [_btnCheck setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
                isCheck = NO;
                
                
            }
                break;
                
            default:
                break;
        }
    }
    
}


- (void)cancelPicker
{
    [_pickerView removeFromSuperview];
}

- (void)donePickerWithIndex:(int)index
{
    if (_arrCountries.count>0) {
        _txfCountry.text = [_arrCountries objectAtIndex:index];
        if ([_txfCountry.text isEqualToString:@"United States"]) {
            _txfZipCode.placeholder = @"Zipcode";
            _txfZipCode.text = nil;
             [_txfZipCode setKeyboardType:UIKeyboardTypeNumberPad];
        }
        else
        {
            _txfZipCode.placeholder = @"City";
             _txfZipCode.text = nil;
             [_txfZipCode setKeyboardType:UIKeyboardTypeDefault];
        }
    }
    [_pickerView removeFromSuperview];
}
- (IBAction)doCountry:(id)sender {
    [_txfUsername resignFirstResponder];
    [_txfFirst resignFirstResponder];
    [_txfLast resignFirstResponder];
    [_txfEmail resignFirstResponder];
    [_txfPass resignFirstResponder];
    [_txfRePass resignFirstResponder];
    [_txfAge resignFirstResponder];
    [_txfPhone resignFirstResponder];
    [_txfZipCode resignFirstResponder];
    [_scrMain setContentOffset:CGPointMake(0,0) animated:YES];
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrCountries mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];

}
@end
