//
//  ManageProfileVC.m
//  DaRumble
//
//  Created by Vidic Phan on 3/31/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ManageProfileVC.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "PickerView.h"
#import "JSON.h"
#import "MyAccountVC.h"

@interface ManageProfileVC ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIActionSheetDelegate,PickerViewDelegate>
{
    
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UIImageView *_imgAvatar;
    
    __weak IBOutlet UITextField *_txfUserName;
    __weak IBOutlet UITextField *_txfFirstName;
    __weak IBOutlet UITextField *_txfLastName;
    __weak IBOutlet UITextField *_txfPhone;
    __weak IBOutlet UITextField *_txfEmail;
    __weak IBOutlet UITextField *_txfAge;
    __weak IBOutlet UITextField *_txfZipCode;
    __weak IBOutlet UITextField *_txfClubName;
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    UIImage *imageChoosePicker;
    NSMutableArray *_arrCountries;
}
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txfConutry;
@property(nonatomic,retain) PickerView *pickerView;
- (IBAction)doCountry:(id)sender;

@end

@implementation ManageProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [_scrMain setContentSize:CGSizeMake(0, IS_IPAD?1400:750)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    [self ShowData];
    
    UIImage *holder = [UIImage imageNamed:@"avatar.png"];
    NSLog(@"--->%@",[USER_DEFAULT objectForKey:@"photo_url"]);
    NSURL *url = [NSURL URLWithString:[USER_DEFAULT objectForKey:@"photo_url"]];
    if(url) {
        [_imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                              placeholderImage:holder
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           _imgAvatar.layer.cornerRadius =_imgAvatar.frame.size.width/2;
                                           _imgAvatar.layer.masksToBounds = YES;
                                           
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           
                                       }];
    }else
    {
        _imgAvatar.image = holder;
    }
    
    [self addGestureRecognizers];
    [self loadAllCountry];
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
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) ShowData
{
     _txfUserName.text = ![[USER_DEFAULT objectForKey:@"username"] isEqualToString:@"(null)"]?[USER_DEFAULT objectForKey:@"username"]:@"";
    _txfFirstName.text = [USER_DEFAULT objectForKey:@"fname"];
    _txfLastName.text = [USER_DEFAULT objectForKey:@"lname"];
    _txfPhone.text = [USER_DEFAULT objectForKey:@"phone"];
    _txfEmail.text = [USER_DEFAULT objectForKey:@"email"];
    
    NSString *age = [USER_DEFAULT objectForKey:@"age"];
    
    @try {
        _txfAge.text = age;
    } @catch (NSException *exception) {
        _txfAge.text = @"0";
    }
    
    if([[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"United States"])
    {
        _txfZipCode.text = [USER_DEFAULT objectForKey:@"zip"];
       
    }
    else
    {
        _txfZipCode.text = ![[USER_DEFAULT objectForKey:@"city"] isEqualToString:@"(null)"]?[USER_DEFAULT objectForKey:@"city"]:@"";
        
    }
    _txfConutry.text = ![[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"(null)"]?[USER_DEFAULT objectForKey:@"country"]:@"";
    _txfClubName.text = ![[USER_DEFAULT objectForKey:@"clubName"] isEqualToString:@"(null)"]?[USER_DEFAULT objectForKey:@"clubName"]:@"";
    
    if ([_txfConutry.text isEqualToString:@"United States"]) {
        _txfZipCode.placeholder = @"Zipcode";
         [_txfZipCode setKeyboardType:UIKeyboardTypeNumberPad];
    }
    else
    {
        _txfZipCode.placeholder = @"City";
        [_txfZipCode setKeyboardType:UIKeyboardTypeDefault];
    }
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}


- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)clickSelectAvatar:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Photo"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:picker animated:YES completion:nil];
            });

            
        }else if (buttonIndex == 1)
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:picker animated:YES completion:nil];
            });

        }
    }
}


#pragma mark - imagepicker controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        _imgAvatar.image = [info valueForKey:UIImagePickerControllerEditedImage];
        imageChoosePicker  =  [info valueForKey:UIImagePickerControllerEditedImage];
        _imgAvatar.layer.cornerRadius =_imgAvatar.frame.size.width/2;
        _imgAvatar.layer.masksToBounds = YES;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clickUpdate:(id)sender {
    _txfUserName.text = trimString(_txfUserName.text);
    _txfFirstName.text = trimString(_txfFirstName.text);
    _txfLastName.text = trimString(_txfLastName.text);
    _txfEmail.text = trimString(_txfEmail.text);
    _txfAge.text = trimString(_txfAge.text);
    _txfPhone.text = trimString(_txfPhone.text);
    _txfZipCode.text = trimString(_txfZipCode.text);
    if (_txfUserName.text.length == 0) {
        [Common showAlert:EROOR_MISS_USERNAME];
        [_txfUserName becomeFirstResponder];
    }else if (_txfFirstName.text.length == 0) {
        [Common showAlert:EROOR_MISS_FIRSTNAME];
        [_txfFirstName becomeFirstResponder];
    }else if (_txfLastName.text.length == 0) {
        [Common showAlert:EROOR_MISS_LASTNAME];
        [_txfLastName becomeFirstResponder];
    }else if (_txfEmail.text.length == 0) {
        [Common showAlert:ERROR_MISS_EMAIL];
        [_txfEmail becomeFirstResponder];
    }else if (![Common checkEmailFormat:_txfEmail.text]) {
        [Common showAlert:ERROR_EMAIL_FORMAT];
        [_txfEmail becomeFirstResponder];
    }/*else if (_txfAge.text.length == 0) {
        [Common showAlert:EROOR_MISS_AGE];
        [_txfAge becomeFirstResponder];
    }else if (_txfPhone.text.length == 0) {
        [Common showAlert:EROOR_MISS_PHONE];
        [_txfPhone becomeFirstResponder];
    }*/
    /*else if (_txfZipCode.text.length == 0) {
        [Common showAlert:EROOR_MISS_ZIPCODE];
        [_txfZipCode becomeFirstResponder];
    }*/
     
     else
    {
        /*
        if (_txfConutry.text.length==0) {
            [Common showAlert:@"Country is required"];
            return;
        }*/
        if([_txfConutry.text isEqualToString:@"United States"])
        {
            if (_txfZipCode.text.length == 0) {
//                [Common showAlert:EROOR_MISS_ZIPCODE];
//                [_txfZipCode becomeFirstResponder];
            }
            //else
            {
                if (imageChoosePicker) {
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
                    NSInteger day = [components day];
                    NSInteger mounth = [components month];
                    NSInteger year = [components year];
                    NSInteger hour = [components hour];
                    NSInteger minutes = [components minute];
                    NSInteger seconds = [components second];
                    NSString *imgName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld.png", (long)day, (long)mounth, (long)year, (long)hour, (long)minutes, (long)seconds];
                    [self uploadImage:imgName];
                }
                else
                {
                    [self loadWS];
                }
            }
        }
        else
        {
            
            if (_txfZipCode.text.length == 0) {
//                [Common showAlert:EROOR_MISS_CITY];
//                [_txfZipCode becomeFirstResponder];
            }
//            else
            {
                if (imageChoosePicker) {
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
                    NSInteger day = [components day];
                    NSInteger mounth = [components month];
                    NSInteger year = [components year];
                    NSInteger hour = [components hour];
                    NSInteger minutes = [components minute];
                    NSInteger seconds = [components second];
                    NSString *imgName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld.png", (long)day, (long)mounth, (long)year, (long)hour, (long)minutes, (long)seconds];
                    [self uploadImage:imgName];
                }
                else
                {
                    [self loadWS];
                }
            }
        }
    }
    
}

- (void) loadWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    NSLog([USER_DEFAULT objectForKey:@"userID"]);
    
    if([_txfConutry.text isEqualToString:@"United States"])
    {
        [ws edit_user:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] username:_txfUserName.text fname:_txfFirstName.text lname:_txfLastName.text email:_txfEmail.text password:[USER_DEFAULT objectForKey:@"password"] repassword:[USER_DEFAULT objectForKey:@"password"] age:[_txfAge.text intValue] phone:_txfPhone.text zip:_txfZipCode.text clubName:_txfClubName.text andCountry:_txfConutry.text andType:1];
    }
    else
    {
        [ws edit_user:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] username:_txfUserName.text fname:_txfFirstName.text lname:_txfLastName.text email:_txfEmail.text password:[USER_DEFAULT objectForKey:@"password"] repassword:[USER_DEFAULT objectForKey:@"password"] age:[_txfAge.text intValue] phone:_txfPhone.text zip:_txfZipCode.text clubName:_txfClubName.text andCountry:_txfConutry.text andType:2];
    }
}

//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Update_success:) name:k_edit_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Update_fail:) name:k_edit_user_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_user_fail object:nil];
}

-(void) Update_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [ParseUtil parse_add_userDicUpdate:dic andPass:[USER_DEFAULT objectForKey:@"password"]];
        [[Common appDelegate].sideMenu loadAvatar];
        [self ShowData];
        
    //---Redirecting To MyAccount---
        MyAccountVC *vc = [[MyAccountVC alloc] init];
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
        
        [Common showAlert:@"Successfully updated"];
        
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Update_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) uploadImage:(NSString *) imageName
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];    
    NSData *imageToUpload = UIImageJPEGRepresentation([Common resizeImage:_imgAvatar.image], 0.0);
    if (imageToUpload)
    {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:APP_TOKEN, @"token", nil];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://test-api.darumble.com"]];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://test-api.darumble.com/api/upload/photo/" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            [formData appendPartWithFileData: imageToUpload name:@"imagedata" fileName:[NSString stringWithFormat:@"%@.jpeg",imageName] mimeType:@"image/jpeg"];
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"response: %@",jsons);
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             if ([[jsons objectForKey:@"code"] integerValue]==200) {
                 NSLog(@"----->%@",[[jsons objectForKey:@"data"] objectForKey:@"photoID"]);
                 NSString *photoID = [[jsons objectForKey:@"data"] objectForKey:@"photoID"];
                 
                 [self addPhotoUser:photoID];
                 
             }
             else
             {
                 [Common showAlert:@"Upload error"];
             }
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if([operation.response statusCode] == 403)
             {
                 //NSLog(@"Upload Failed");
                 return;
             }
             //NSLog(@"error: %@", [operation error]);
             
         }];
        
        [operation start];
    }
}

-(void) addPhotoUser:(NSString *) photoID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":@"6",@"photoID":photoID};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"REPONSE %@",responseObject);
        [self loadWS];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_vehicle: %@", error);
        
    }];
    
}


#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    int modeDev = 100;
    if (textField==_txfUserName || textField==_txfFirstName || textField ==_txfLastName) {
        [_scrMain setContentOffset:CGPointMake(0,0+modeDev) animated:YES];
    }
    else if (textField ==_txfPhone)
    {
        [_scrMain setContentOffset:CGPointMake(0,50+modeDev) animated:YES];
    }
    else if (textField ==_txfEmail)
    {
        [_scrMain setContentOffset:CGPointMake(0,100+modeDev) animated:YES];
    }
    else if (textField ==_txfAge)
    {
        [_scrMain setContentOffset:CGPointMake(0,150+modeDev) animated:YES];
    }
    else if (textField ==_txfZipCode)
    {
        [_scrMain setContentOffset:CGPointMake(0,200+modeDev) animated:YES];
    }
    else if (textField ==_txfClubName)
    {
        [_scrMain setContentOffset:CGPointMake(0,250+modeDev) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_txfUserName) {
        [_txfFirstName becomeFirstResponder];
    }
    else if (textField ==_txfFirstName)
    {
        [_txfLastName becomeFirstResponder];
    }
    else if (textField ==_txfLastName)
    {
        [_txfPhone becomeFirstResponder];
    }
    else if (textField ==_txfPhone)
    {
        [_txfEmail becomeFirstResponder];
    }
    else if (textField ==_txfEmail)
    {
        [_txfAge becomeFirstResponder];
    }
    else if (textField ==_txfAge)
    {
        [_txfZipCode becomeFirstResponder];
    }
    else if (textField ==_txfZipCode)
    {
        [_txfClubName becomeFirstResponder];
    }
    else if (textField ==_txfClubName)
    {
        [_txfClubName resignFirstResponder];
    }
    return YES;
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
            NSArray *arrs = [[response objectForKey:@"data"] objectForKey:@"countries"];
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

- (void)cancelPicker
{
    [_pickerView removeFromSuperview];
}

- (void)donePickerWithIndex:(int)index
{
    if (_arrCountries.count>0) {
        _txfConutry.text = [_arrCountries objectAtIndex:index];
        if ([_txfConutry.text isEqualToString:@"United States"]) {
            _txfZipCode.placeholder = @"Zipcode";
//            _txfZipCode.text = nil;
            [_txfZipCode setKeyboardType:UIKeyboardTypeNumberPad];
        }
        else
        {
            _txfZipCode.placeholder = @"City";
//            _txfZipCode.text = nil;
            [_txfZipCode setKeyboardType:UIKeyboardTypeDefault];
        }
    }
    [_pickerView removeFromSuperview];
}

- (IBAction)doCountry:(id)sender {
    [_txfUserName resignFirstResponder];
    [_txfFirstName resignFirstResponder];
    [_txfLastName resignFirstResponder];
    [_txfEmail resignFirstResponder];
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
