//
//  AddEventVC.m
//  DaRumble
//
//  Created by Colin on 4/22/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "AddMyEventVC.h"
#import "SearchItemsVC.h"
#import "IQActionSheetPickerView.h"
#import "DatePicker.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"
#import "UploadFlyerVC.h"
#import "CalendarVC.h"
#import "PickerView.h"
#import "UIImage+Resize.h"

#define loadNib(nibName) [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0]
@interface AddMyEventVC ()<UIGestureRecognizerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate,IQActionSheetPickerViewDelegate,DatePickerDelegate>
{
    
    __weak  IBOutlet UITextField *txfName;
    __weak  IBOutlet UIImageView *imgPhoto;
    __weak  IBOutlet UITextField *txfAddress;
    __weak  IBOutlet UITextField *txfState;
    __weak  IBOutlet UITextField *txfCityZip;
    __weak  IBOutlet UITextField *txfContactInfo;
    __weak  IBOutlet UIButton *toggleButton;
    __weak IBOutlet UITextField *txfFlyerName;
    
    IBOutlet UIImageView *_btnImage;

    __weak IBOutlet UIScrollView *scrollPage;
    //__weak IBOutlet UITextField *txfEventType;
    
    NSMutableArray *arrType;
    UIImage *imageChoosePicker;
    NSString *photoID;
    CGPoint velocityF;
    CGPoint velocityL;
    BOOL PORTRAIT_ORIENTATION;
    NSTimer *timer;
    __weak IBOutlet UIView *_subAddEvent;
    
    NSMutableArray *_arrCountries;
    NSMutableArray *_arrStates;
    
    int flagOfPickerView;
    IBOutlet UIButton *btn_picker_state;
}
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *m_event_country;
@property(nonatomic,retain) PickerView *pickerView;
@property(nonatomic,retain) DatePicker *datePicker;
- (IBAction)doEventType:(id)sender;
- (IBAction)doAdd:(id)sender;


@end

@implementation AddMyEventVC



- (void)viewDidLoad {
    
    
    if (!IS_IPAD) {
        [scrollPage setContentSize:CGSizeMake(scrollPage.frame.size.width,900)];
         _subAddEvent.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 900);
    }else{
        [scrollPage setContentSize:CGSizeMake(scrollPage.frame.size.width,1500)];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    
    toggleButton.tag = 3000;
    
    [scrollPage addGestureRecognizer:singleTap];
    [super viewDidLoad];
    arrType = [[NSMutableArray alloc] initWithObjects:@"car show", @"bike show", @"race",@"off road",@"swap meet",@"rally",@"seminar",@"class",@"workshop",@"ride",@"course", nil];
    
    if (self.flagOfEvent == 1) {
        self.lblTitleEvent.text =@"Add Event";
        
        _btnImage.image = [UIImage imageNamed:@"ic_btn_add_g.png"];
        
    }
    else if (self.flagOfEvent == 2)
    {
        self.lblTitleEvent.text =@"Edit Event";
        
        txfName.text = self.photoObj.eventName;
        txfAddress.text = self.photoObj.location;
        self.m_event_country.text = self.photoObj.event_country;
        txfState.text = self.photoObj.event_state;
        txfContactInfo.text = self.photoObj.event_contact_info;
        self.flyerID = self.photoObj.event_flyer;
        self.eventType = self.photoObj.event_type;
        self.event_startDate = self.photoObj.start_date;
        self.is_reucrring = self.photoObj.is_recurring;
        self.event_recurring_value = self.photoObj.recurring_count;
        self.event_recurring_value_type = self.photoObj.recurring_time;
        self.event_recurring_end_period = self.photoObj.recurring_count;
        self.event_recurring_end_period_type = self.photoObj.recurring_end_time;
        //sphotoID = self.photoObj.event_photo_id;
        txfCityZip.text = self.photoObj.event_zip;
        
        _btnImage.image = [UIImage imageNamed:@"ic_btn_update.png"];
        
        NSURL *url = [NSURL URLWithString: self.photoObj.URL];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imgPhoto.image = image;
                    });
                }
            }
        }];
        [task resume];
        
        toggleButton.tag = self.is_reucrring == 1 ? 3001 : 3000;
        if(toggleButton.tag == 3001){
            [toggleButton setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        }else if (toggleButton.tag == 3000){
            [toggleButton setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        }
    }
     [self addGestureRecognizers];
    

    
//---calendar redirecting values saves restoring---
    if (self.is_redirecting_calendar != 1)
    {
        self.is_redirecting_calendar = 0;
    }
    if (self.is_redirecting_calendar == 1)
    {
        txfName.text = self.strName;
        imgPhoto.image = self.image;
        imageChoosePicker = self.image;
        txfAddress.text = self.strAddress;
        txfState.text = self.strState;
        self.m_event_country.text = self.strCountry;
        txfCityZip.text = self.strCityZip;
        txfContactInfo.text = self.strContactInfo;
        toggleButton.tag = self.is_reucrring == 1 ? 3001 : 3000;
        txfFlyerName.text = self.flyerName;
        
        if(toggleButton.tag == 3001){
            [toggleButton setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        }else if (toggleButton.tag == 3000){
            [toggleButton setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        }        
        self.is_redirecting_calendar = 0;
    }
    
    [self loadAllCountry];
    
    NSLog(@"ViewDid called");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)addItemViewController:(UploadFlyerVC *)controller didFinishEnteringItem:(NSString *)image_name flyer_id:(int)flyer_id
{
    NSLog(@"This was returned from ViewControllerB %@,%d",image_name, flyer_id);
    txfFlyerName.text = [NSString stringWithFormat:@"%@", image_name];
    self.flyerID = flyer_id;
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

- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    //[scrollPage setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [txfName resignFirstResponder];
    [self.m_event_country resignFirstResponder];
    [txfContactInfo resignFirstResponder];
    [txfState resignFirstResponder];
}

- (IBAction)doPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
    
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)doMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (IBAction)doSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) removeDateTimePicker
{
    //[self.datePicker removeFromSuperview];
    [self.datePicker removeFromSuperview];
}

-(void) showDateTimePicker:(NSDate *)date
{
    NSDateFormatter *formatter;
    NSString        *dateString;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        
        dateString = [formatter stringFromDate:date];
    //[self.datePicker removeFromSuperview];
    [self.datePicker removeFromSuperview];
    }

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    NSLog(@"%@", pickerView.date);
   // NSDateFormatter *df = [[NSDateFormatter alloc] init];
   // [df setDateFormat:@"yyyy-MM-dd"];
   // _photoObj.date = [df stringFromDate:pickerView.date];
    //[_btnDate setTitle:_photoObj.date forState:UIControlStateNormal];
}

- (IBAction)doEventType:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"car show", @"bike show", @"race",@"off road",@"swap meet",@"rally",@"seminar",@"class",@"workshop",@"ride",@"course", nil];
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
        if (buttonIndex<10) {
            //txfEventType.text = [arrType objectAtIndex:buttonIndex];
        }
    }
    
}


#pragma mark - imagepicker controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        imgPhoto.image = [info valueForKey:UIImagePickerControllerEditedImage];
        imageChoosePicker  =  [info valueForKey:UIImagePickerControllerEditedImage];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)doAdd:(id)sender {
    txfName.text =[Common stringByTrimString:txfName.text];
    self.m_event_country.text =[Common stringByTrimString:self.m_event_country.text];
    //txfEventType.text =[Common stringByTrimString:txfEventType.text];
    txfContactInfo.text =[Common stringByTrimString:txfContactInfo.text];
    txfState.text =[Common stringByTrimString:txfState.text];
    txfAddress.text = [Common trimString:txfAddress.text];
    txfCityZip.text = [Common trimString:txfCityZip.text];
    self.event_startDate = [Common trimString:self.event_startDate];
    
    
    if (!self.photoObj.id)
    {
        if (imageChoosePicker==nil)
        {
            [Common showAlert:@"Please choose photo"];
            return;
        }
    }
    if (txfName.text.length ==0) {
        [Common showAlert:@"Name event is required"];
        //[txfName becomeFirstResponder];
        return;
    }
    if (self.m_event_country.text.length ==0) {
        [Common showAlert:@"Location is required"];
        //[self.m_event_country becomeFirstResponder];
        return;
    }
    /*
    if (txfEventType.text.length ==0) {
        [Common showAlert:@"Type event is required"];
        return;
    }*/
    if (txfContactInfo.text.length ==0) {
        [Common showAlert:@"Contact info is required"];
        //[txfContactInfo becomeFirstResponder];
        return;
    }
    if (txfState.text.length ==0) {
        [Common showAlert:@"State event is required"];
        [txfState becomeFirstResponder];
        return;
    }
    if (txfAddress.text.length ==0) {
        [Common showAlert:@"Address is required"];
        //[txfAddress becomeFirstResponder];
        return;
    }
    if (txfCityZip.text.length ==0) {
        [Common showAlert:@"City/Zipcode is required"];
        //[txfCityZip becomeFirstResponder];
        return;
    }
    if (self.event_startDate.length == 0){
        [Common showAlert:@"Event start time is required"];
        return;
    }
    if (self.is_reucrring == 1)
    {
        self.event_recurring_value_type = [Common trimString:self.event_recurring_value_type];
        self.event_recurring_end_period_type = [Common trimString:self.event_recurring_end_period_type];
        if (self.event_recurring_value == 0 || self.event_recurring_end_period == 0 || self.event_recurring_value_type.length == 0 || self.event_recurring_end_period_type.length == 0)
        {
            [Common showAlert:@"Invalid Recurring Info Input"];
            return;
        }
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
    if (self.photoObj.id)
    {
        if (imageChoosePicker) {
            [self uploadImage:imgName];
        }
        else
        {
            [self createEvent];
        }
    }
    else
    {
        [self uploadImage:imgName];
    }
}


-(void) textFieldDidBeginEditing:(UITextField *)textField

{
    if (IS_IPAD) {
        
    }
    else
    {
        if (textField ==txfName) {
            [scrollPage setContentOffset:CGPointMake(0,100) animated:YES];
        }
        else if (textField ==txfAddress) {
            [scrollPage setContentOffset:CGPointMake(0,200) animated:YES];
        }else if (textField ==txfState) {
            [scrollPage setContentOffset:CGPointMake(0,300) animated:YES];
        }
        else if (textField ==txfContactInfo) {
            [scrollPage setContentOffset:CGPointMake(0,350) animated:YES];
        }
    }
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField ==txfName) {
        [txfAddress becomeFirstResponder];
    }else if (textField == txfAddress){
        [txfState becomeFirstResponder];
    }else if (textField ==txfState) {
        [txfContactInfo becomeFirstResponder];
    }else if (textField == txfContactInfo){
        [txfContactInfo resignFirstResponder];
        [scrollPage setContentOffset:CGPointMake(0,0) animated:YES];
    }
    return YES;
}

-(void) uploadImage:(NSString *) imageName
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
       
    NSData *imageToUpload = UIImageJPEGRepresentation([Common resizeImage:imgPhoto.image], 0.0);
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
             if ([[jsons objectForKey:@"code"] integerValue]==200)
             {
                 NSLog(@"----->%@",[[jsons objectForKey:@"data"] objectForKey:@"photoID"]);
                 self.photoObj.event_photo_id = [[[jsons objectForKey:@"data"] objectForKey:@"photoID"] intValue];

                 [self createEvent];

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

-(void) addPhotoGarage:(NSString *) eventID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":TXT_CATEGORY_EVENTID,@"photoID":[NSString stringWithFormat:@"%d",self.photoObj.event_photo_id],@"eventID":eventID};
    // NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":TXT_CATEGORY_EVENTID,@"photoID":photoID};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"JSON %@",jsons);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        if (self.flagOfEvent == 1)
            [Common showAlert:@"Successfully Created"];
        else if (self.flagOfEvent == 2)
            [Common showAlert:@"Successfully Updated"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_vehicle: %@", error);
        
    }];
    
}


- (IBAction)clickAddFlyer:(id)sender {
    NSString *notf = @"Are you sure to add flyer?";
    if (self.photoObj.event_flyer > 0){
        notf = @"Are you sure to update flyer?";
    }
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(notf,nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = 6170;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 6170)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            UploadFlyerVC *vc = [[UploadFlyerVC alloc] init];
            vc.delegate = self;
            vc.flyerURL = self.photoObj.event_flyer_url;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

- (IBAction)clickCalendar:(id)sender {
    CalendarVC *vc = [[CalendarVC alloc] init];
    vc.strName = txfName.text;
    vc.image = imgPhoto.image;
    vc.strAddress = txfAddress.text;
    vc.strState = txfState.text;
    vc.strCountry = self.m_event_country.text;
    vc.strCityZip = txfCityZip.text;
    vc.strContactInfo = txfContactInfo.text;
    vc.is_reucrring = toggleButton.tag == 3000 ? 0 : 1;
    vc.flyerID = self.flyerID;
    vc.flyerName = txfFlyerName.text;
    vc.flagOfEvent = self.flagOfEvent;
    
    vc.photoObj = self.photoObj;
    
    UINavigationController *navigationController = self.navigationController;    
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];    
    [navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickToggleButton:(id)sender {
    if(toggleButton.tag == 3000){
        [toggleButton setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleButton.tag = 3001;
        self.is_reucrring = 1;
        
    }else if (toggleButton.tag == 3001){
        [toggleButton setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        toggleButton.tag = 3000;
        self.is_reucrring = 0;
    }
}

- (IBAction)doCountry:(id)sender {
    flagOfPickerView = 1;//country dropbox
    
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrCountries mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
}
//---Select Country---
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
    if (flagOfPickerView == 1)//country
    {
        if (_arrCountries.count>0) {
            self.m_event_country.text = [_arrCountries objectAtIndex:index];
            if ([self.m_event_country.text isEqualToString:@"United States"]) {
                txfCityZip.placeholder = @"Zipcode";
                txfCityZip.text = nil;
                [txfCityZip setKeyboardType:UIKeyboardTypeNumberPad];
                
                txfState.text = @"";
                btn_picker_state.hidden = NO;
            }
            else
            {
                txfCityZip.placeholder = @"City";
                txfCityZip.text = nil;
                [txfCityZip setKeyboardType:UIKeyboardTypeDefault];
                
                
                txfState.text = @"";
                btn_picker_state.hidden = YES;
            }
        }
    }else if (flagOfPickerView == 2)//state
    {
        txfState.text = [_arrStates objectAtIndex:index];
    }
    [_pickerView removeFromSuperview];
}
//---Select State---//
- (IBAction)doStates:(id)sender {
    flagOfPickerView = 2;//state dropbox
    
    NSArray* myList = [NSArray arrayWithObjects:@"Alabama",@"Alaska",@"Arizona",
                       @"Arkansas",@"California",@"Colorado",
                       @"Connecticut",@"Delaware",
                       @"District of Columbia",
                       @"Florida",
                       @"Georgia",
                       @"Hawaii",
                       @"Idaho",
                       @"Illinois",
                       @"Indiana",
                       @"Iowa",
                       @"Kansas",
                       @"Kentucky",
                       @"Louisiana",
                       @"Maine",
                       @"Maryland",
                       @"Massachusetts",
                       @"Michigan",
                       @"Minnesota",
                       @"Mississippi",
                       @"Missouri",
                       @"Montana",
                       @"Nebraska",
                       @"Nevada",
                       @"New Hampshire",
                       @"New Jersey",
                       @"New Mexico",
                       @"New York",
                       @"North Carolina",
                       @"North Dakota",
                       @"Ohio",
                       @"Oklahoma",
                       @"Oregon",
                       @"Pennsylvania",
                       @"Rhode Island",
                       @"South Carolina",
                       @"South Dakota",
                       @"Tennessee",
                       @"Texas",
                       @"Utah",
                       @"Vermont",
                       @"Virginia",
                       @"Washington",
                       @"West Virginia",
                       @"Wisconsin",
                       @"Wyoming",
                       @"Puerto Rico", nil];
    
    _arrStates = [[NSMutableArray alloc] init];
    for (NSString *str in myList) {
        [_arrStates addObject:str];
    }
    
    
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrStates mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
}



//---Create Event---
- (void)createEvent
{
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        
        NSLog([NSString stringWithFormat:@"%d",self.photoObj.event_photo_id]);
        
        if ([self.m_event_country.text isEqualToString:@"United States"])
        {
            [ws create_event:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] eventName:txfName.text eventLocation:txfAddress.text country:self.m_event_country.text state:txfState.text city:@"" contact_info:txfContactInfo.text flyer:[NSString stringWithFormat:@"%d", self.flyerID] eventType:self.eventType startDate:self.event_startDate is_recurring:self.is_reucrring recurringCount:self.event_recurring_value recurringTime:self.event_recurring_value_type recurringEndCount:self.event_recurring_end_period recurringEndTime:self.event_recurring_end_period_type photoID: self.photoObj.event_photo_id zip:txfCityZip.text event_id:self.flagOfEvent==1?0:self.photoObj.id];
        }else
        {
            [ws create_event:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] eventName:txfName.text eventLocation:txfAddress.text country:self.m_event_country.text state:txfState.text city:txfCityZip.text contact_info:txfContactInfo.text flyer:[NSString stringWithFormat:@"%d", self.flyerID] eventType:self.eventType startDate:self.event_startDate is_recurring:self.is_reucrring recurringCount:self.event_recurring_value recurringTime:self.event_recurring_value_type recurringEndCount:self.event_recurring_end_period recurringEndTime:self.event_recurring_end_period_type photoID: self.photoObj.event_photo_id zip:@"" event_id:self.flagOfEvent==1?0:self.photoObj.id];
        }
    }
}


//==============WEBSERVICE(CreateEvent_Success)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CreateEvent_Success:) name:k_create_event_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CreateEvent_Fail:) name:k_create_event_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_create_event_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_create_event_fail object:nil];
}
-(void) CreateEvent_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"CreateEvent_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        NSString *eventID = [data objectForKey:@"eventID"];
        
        [self addPhotoGarage:eventID];
        
//        [Common showAlert:@"Your event was added"];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) CreateEvent_Fail:(NSNotification*)notif
{
    NSLog(@"CreateEvent_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
