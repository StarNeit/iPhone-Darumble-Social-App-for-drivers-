//
//  VehiclesVC.m
//  DaRumble
//
//  Created by Vidic Phan on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "VehiclesVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Common.h"
#import "UIImageView+AFNetworking.h"

@interface VehiclesVC ()<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,UITextFieldDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UITextField *_txfMake;
    __weak IBOutlet UITextField *_txfModel;
    __weak IBOutlet UITextField *_txfYear;
    __weak IBOutlet UILabel *_lblTitle;
    __weak IBOutlet UIButton *_btnType;
    __weak IBOutlet UIButton *_btnAdd;
    __weak IBOutlet UIButton *_btnForImage;
    IBOutlet UIImageView *_btnImage;
    CGPoint velocityF;
    CGPoint velocityL;
    
    NSString *photoID;
    
    __weak IBOutlet UIView *_subVehicle;
    
    NSString *imageURL;
    
    int flagOfImageViewSet;
}

@end

@implementation VehiclesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_scrMain setContentSize:CGSizeMake(0, 900)];
    //_subVehicle.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 950);
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    
    flagOfImageViewSet = 0;
    
    if (_photoObj)
    {
        _lblTitle.text = @"Edit Vehicles";
        _txfMake.text = _photoObj.make;
        [_btnType setTitle:_photoObj.type forState:UIControlStateNormal];
        _txfModel.text = _photoObj.model;
        _txfYear.text = _photoObj.year;
        _btnImage.image = [UIImage imageNamed:@"ic_btn_edit.png"];
        
        
        NSURL *url = [NSURL URLWithString:self.photoObj.URL];
        imageURL = self.photoObj.URL;
        UIImage *holder = [UIImage imageNamed:@""];
        if(url) {
            [self._imgPhoto setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                             placeholderImage:holder
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          //self.imageChoosePicker =image;
                                          self._imgPhoto.image = image;
                                          flagOfImageViewSet = 1;
                                          self._imgPhoto.contentMode = UIViewContentModeScaleAspectFill;
                                          self._imgPhoto.clipsToBounds = YES;
                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          self._imgPhoto.image = holder;
                                      }];
        }else
        {
            self._imgPhoto.image = holder;
        }

    }else
    {
        _lblTitle.text = @"Add Vehicles";
        _btnImage.image = [UIImage imageNamed:@"ic_btn_add_g.png"];
        
    //---When user upload image from photo upload screen, image selection here is no needed---
        
        if (self.is_set_image == 1)
        {
            self._imgPhoto.image = self.imageChoosePicker;
            flagOfImageViewSet = 1;
            _btnForImage.hidden = YES;
        }else{
            _btnForImage.hidden = NO;
        }
    }
    [self addGestureRecognizers];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    if (self.is_set_image != 1)
    {
        self.is_set_image = 0;
    }
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

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSelectPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Photo"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

- (IBAction)clickSelectTitle:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"import", @"domestic", @"other", nil];
    actionSheet.tag = 101;
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
    }else if (actionSheet.tag == 101)
    {
        if (buttonIndex == 0) {
            [_btnType setTitle:@"import" forState:UIControlStateNormal];
        }else if (buttonIndex == 1) {
            [_btnType setTitle:@"domestic" forState:UIControlStateNormal];
        }else if (buttonIndex == 2) {
            [_btnType setTitle:@"other" forState:UIControlStateNormal];
        }
    }
    
}
#pragma mark - imagepicker controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        self._imgPhoto.image = [info valueForKey:UIImagePickerControllerEditedImage];
        self.imageChoosePicker  =  [info valueForKey:UIImagePickerControllerEditedImage];
        flagOfImageViewSet = 1;
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickAdd:(id)sender {
    _txfMake.text = [Common stringByTrimString:_txfMake.text];
    _txfModel.text =[Common stringByTrimString:_txfModel.text];
    _txfYear.text  =[Common stringByTrimString:_txfYear.text];
    if (flagOfImageViewSet == 0) {
        [Common showAlert:@"Image is required"];
        return;
    }
    if (_txfMake.text.length ==0) {
        [Common showAlert:@"Make is required"];
        return;
    }
    if (_txfModel.text.length ==0) {
        [Common showAlert:@"Model is required"];
        return;
    }
    if (_txfYear.text.length ==0) {
        [Common showAlert:@"Year is required"];
        return;
    }
    if ([_btnType.titleLabel.text isEqualToString:@"Select Type"]) {
        [Common showAlert:@"Type is required"];
        return;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger mounth = [components month];
    NSInteger year = [components year];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    NSString *imgName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld.png", (long)day, (long)mounth, (long)year, (long)hour, (long)minutes, (long)seconds];
    if (_photoObj.id)
    {
        if (self.imageChoosePicker) {
            [self uploadImage:imgName];
        }
        else
        {
            //[self addPhotoVeclie:[NSString stringWithFormat:@"%d", _photoObj.id]];
            [self loadWS];
        }
    }
    else
    {
        [self uploadImage:imgName];
    }
}

- (void) loadWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    if (_photoObj.id) {
        [ws edit_vehicle:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] type:_btnType.currentTitle make:_txfMake.text model:_txfModel.text categoryID:[NSString stringWithFormat:@"%d", Cat_Vehicles] year:_txfYear.text description:@"" vehicleID:[NSString stringWithFormat:@"%d", _photoObj.id]];
    }else
    {
        [ws add_vehicle:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] type:_btnType.currentTitle make:_txfMake.text model:_txfModel.text categoryID:[NSString stringWithFormat:@"%d", Cat_Vehicles] year:_txfYear.text description:@""];
    }
}

//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Vehicle_success:) name:k_add_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Vehicle_fail:) name:k_add_vehicle_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Vehicle_success:) name:k_edit_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Vehicle_fail:) name:k_edit_vehicle_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_vehicle_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_vehicle_fail object:nil];
}

-(void) Vehicle_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        NSString *vehicleID = [[dic objectForKey:@"data"] objectForKey:@"vehicleID"];
        [self addPhotoVeclie:vehicleID];
        
        [Common showAlert:@"Your vehicle was added"];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Vehicle_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) uploadImage:(NSString *) imageName
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    //NSData *imageToUpload = UIImageJPEGRepresentation(self._imgPhoto.image, 1.0);//(uploadedImgView.image);
    NSData *imageToUpload = UIImageJPEGRepresentation([Common resizeImage:self._imgPhoto.image], 0.0);
    
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
               
                 photoID = [[jsons objectForKey:@"data"] objectForKey:@"photoID"];
                 [self loadWS];
             }
             else
             {
             }
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if([operation.response statusCode] == 403)
             {
                 return;
             }
             
         }];
        
        [operation start];
    }
}

-(void) addPhotoVeclie:(NSString *) vehicleID
{
    if (photoID == nil)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":TXT_CATEGORY_VEHICLEID,@"photoID":photoID,@"vehicleID":vehicleID};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"JSON %@",jsons);
       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_vehicle: %@", error);
        
    }];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField==_txfMake) {
        [_scrMain setContentOffset:CGPointMake(0,100) animated:YES];
    }else if (textField==_txfModel) {
        [_scrMain setContentOffset:CGPointMake(0,150) animated:YES];
    }else if (textField==_txfYear) {
        [_scrMain setContentOffset:CGPointMake(0,200) animated:YES];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField ==_txfMake) {
        [_txfModel becomeFirstResponder];
    }
    else if (textField ==_txfModel)
    {
        [_txfYear becomeFirstResponder];
    }
    else if (textField==_txfYear)
    {
        [_txfYear resignFirstResponder];
    }
    return YES;
}
@end
