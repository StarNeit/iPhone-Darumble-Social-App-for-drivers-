//
//  AddPhotoVC.m
//  DaRumble
//
//  Created by Vidic Phan on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "UploadPhotoVC.h"
#import "Define.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "VehiclesVC.h"
#import "ManagePhotosVC.h"
#import "ManageEventsVC.h"
#import "EventSearchResult.h"
#import "AddMyEventVC.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface UploadPhotoVC ()<UIGestureRecognizerDelegate, UITextViewDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UIImageView *_imgPhoto;
    __weak IBOutlet UILabel *_lblTitle;
    CGPoint velocityF;
    CGPoint velocityL;
    __weak IBOutlet UIView *subAddPhoto;
    __weak IBOutlet UIView *subPhotoIpad;
    NSMutableData *respData;
    NSURLConnection *urlconnection;
    
    __weak IBOutlet UIView *uploadPhotoType;
    __weak IBOutlet UIView *uploadButtons;
    __weak IBOutlet UIView *addEventPhotoView;
    __weak IBOutlet UIView *addToSthElseview;
    __weak IBOutlet UIImageView *demoImage;
    
    int is_other_category;
    int uploaded_photoID;
    
    IBOutlet UIView *view_image_upload_type;
    IBOutlet UIView *view_multiple_image_type;
    IBOutlet UIView *view_multiple_image_forevent;
}
@end

@implementation UploadPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (IS_IPAD) {
        [_scrMain setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1024)];
        subPhotoIpad.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 1100);
    }
    else
    {
        [_scrMain setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 700)];
        subAddPhoto.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 800);
    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [_scrMain addGestureRecognizer:singleTap];
    if (_photoObj) {
        _lblTitle.text = @"Edit Photo";
        [btAdd setImage:[UIImage imageNamed:@"ic_btn_edit.png"] forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:self.photoObj.URL];
        UIImage *holder = [UIImage imageNamed:@""];
        if(url) {
            [_imgPhoto setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                             placeholderImage:holder
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          _imgPhoto.contentMode = UIViewContentModeScaleAspectFill;
                                          _imgPhoto.clipsToBounds = YES;
                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          _imgPhoto.image = holder;
                                      }];
        }else
        {
            _imgPhoto.image = holder;
        }
        
        
        
    }else
    {
        _lblTitle.text = @"Add Photo";
        [btAdd setImage:[UIImage imageNamed:@"ic_btn_add_d.png"] forState:UIControlStateNormal];
    }
    [self removeNotifi];
    [self addNotifi];
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
    
    is_other_category = 0;
    uploaded_photoID = -1;
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
    if (IS_IPAD) {
        [_scrMain setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1024)];
    }
    else
    {
        [_scrMain setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 700)];
    }
    
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
//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Add_photo_success:) name:k_add_photo_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Add_photo_fail:) name:k_add_photo_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_photo_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_photo_fail object:nil];
}
-(void) Add_photo_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [Common showAlert:@"Add new photo successfully"];
        [self removeNotifi];
        [self .navigationController popViewControllerAnimated:YES];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void) Add_photo_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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


- (IBAction)clickBrowse:(id)sender {
    //view_image_upload_type.hidden = NO;
    
    
    view_image_upload_type.hidden = YES;
    // Create the image picker
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 15; //Set the maximum number of images to select, defaults to 4
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
    elcPicker.imagePickerDelegate = self;
    
    //Present modally
    [self presentViewController:elcPicker animated:YES completion:nil];
}
- (IBAction)clickSingleButton:(id)sender {
    view_image_upload_type.hidden = YES;
    [self ShouldStartPhotoLibrary];
}
- (IBAction)clickMultipleButton:(id)sender {
    view_image_upload_type.hidden = YES;
    
    // Create the image picker
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 15; //Set the maximum number of images to select, defaults to 4
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
    elcPicker.imagePickerDelegate = self;
    
    //Present modally
    [self presentViewController:elcPicker animated:YES completion:nil];
}


- (IBAction)clickTakePhoto:(id)sender {
    [self ShouldStartCamera];
}

-(void) ShouldStartCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage])
    {
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
        {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
        else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else return;
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
}


-(void) ShouldStartPhotoLibrary
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage])
    {
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:
                  UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage])
    {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
    }
    else return;
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    imgData = [self encodeToBase64String:image];
    _imgPhoto.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    uploadPhotoType.hidden = NO;
    uploadButtons.hidden = YES;
    demoImage.hidden = YES;
}
- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(NSString *)makeImageName
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger mounth = [components month];
    NSInteger year = [components year];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    NSString *imgName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld.png", (long)day, (long)mounth, (long)year, (long)hour, (long)minutes, (long)seconds];
    return imgName;
}
- (IBAction)clickAdd:(id)sender {
    is_other_category = 0;
    NSString *imgName = [self makeImageName];
    if (_photoObj.id) {
        if (imgData) {
            [self uploadImage:imgName];
        }
        else
        {
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            [self addPhotoUser:[NSString stringWithFormat:@"%d", _photoObj.id]];
        }
    }
    
    else
    {
        if (imgData.length == 0) {
            [Common showAlert:@"Don't have any a photo"];
        }else{
            [self uploadImage:imgName];
        }
    }
}

-(void) uploadImage:(NSString *) imageName
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    //NSData *imageToUpload = UIImageJPEGRepresentation(_imgPhoto.image, 1.0);//(uploadedImgView.image);
    NSData *imageToUpload = UIImageJPEGRepresentation([Common resizeImage:_imgPhoto.image], 0.0);
    
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
                 
                 uploaded_photoID = [[[jsons objectForKey:@"data"] objectForKey:@"photoID"] intValue];
                 if (is_other_category == 0)
                 {
                     [self addPhotoUser:photoID];
                 }else if (is_other_category == 1)
                 {
                     if (uploaded_photoID == -1)
                     {
                         [Common showAlert:@"Image Upload Failed"];
                         return;
                     }
                     //[Common showAlert:[NSString stringWithFormat:@"Image Upload Success-%d",uploaded_photoID]];
                     
                     //---Redirecting To My Event List---
                     ManageEventsVC *vc = [[ManageEventsVC alloc] init];
                     vc.is_add_image = 1;//add single image to my event
                     vc.addedImageID = uploaded_photoID;
                     [self.navigationController pushViewController:vc animated:NO];
                     
                     return;
                 }else if (is_other_category == 2)
                 {
                     if (uploaded_photoID == -1)
                     {
                         [Common showAlert:@"Image Upload Failed"];
                         return;
                     }
                     //[Common showAlert:[NSString stringWithFormat:@"Image Upload Success-%d",uploaded_photoID]];
                     
                     //---Redirecting To Event Search List---
                     EventSearchResult *vc = [[EventSearchResult alloc] init];
                     vc.is_add_image = 1;//add single image to other's one event
                     vc.addedImageID = uploaded_photoID;
                     
                     vc.m_event_name = @"";
                     vc.m_event_startDate = @"";
                     vc.m_event_endDate = @"";
                     vc.m_event_fname = @"";
                     vc.m_event_lname = @"";
                     vc.m_event_shop = @"";
                     vc.m_event_city = @"";
                     vc.m_event_country = @"";
                     vc.m_event_zipcode = @"";
                     vc.m_event_miles = @"";
                     vc.m_event_startDate = @"1900-01-01 0:0";
                     vc.is_use_mylocation = 0;
                     vc.m_event_type = 1;
                     
                     [self.navigationController pushViewController:vc animated:NO];
                     
                     return;
                 }else if (is_other_category == 3)
                 {
                     if (uploaded_photoID == -1)
                     {
                         [Common showAlert:@"Image Upload Failed"];
                         return;
                     }
                     //[Common showAlert:[NSString stringWithFormat:@"Image Upload Success-%d",uploaded_photoID]];
                     
                     //---Redirecting screen---
                     addToSthElseview.hidden = NO;
                     uploadPhotoType.hidden = YES;
                     subAddPhoto.hidden = YES;
                     
                     return;
                 }
             }
             else
             {
                 [Common showAlert:@"Upload error"];
                 uploaded_photoID = -1;
             }
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             uploaded_photoID = -1;
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
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":TXT_CATEGORY_OTHER,@"photoID":photoID,@"description":@"description"};
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


- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if (!IS_IPAD) {
        [_scrMain setContentOffset:CGPointMake(0,100) animated:YES];
    }
    
}

- (IBAction)goAddVehicle:(id)sender {
    VehiclesVC *vc = [[VehiclesVC alloc] init];
    vc.imageChoosePicker = _imgPhoto.image;
    vc.is_set_image = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goSelectEvent:(id)sender {
    addEventPhotoView.hidden = NO;
    uploadPhotoType.hidden = YES;
}

- (IBAction)goSomethingElse:(id)sender {
    is_other_category = 3;
    
    if (imgData.length == 0)
    {
        [Common showAlert:@"Don't have any photo"];
    }else
    {
        NSString *imgName = [self makeImageName];
        [self uploadImage:imgName];
    }
}

- (IBAction)goBackToMyPhotos:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi2];
        [self addNotifi2];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws set_photo_formembers:APP_TOKEN formember:1 photoID:uploaded_photoID userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
}

//---Add Image To Event---
- (IBAction)addImageToMyExistEvent:(id)sender
{
    is_other_category = 1;
    
    if (imgData.length == 0)
    {
        [Common showAlert:@"Don't have any a photo"];
    }else
    {
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
}

- (IBAction)addImageToElseEvent:(id)sender
{
    is_other_category = 2;
    
    if (imgData.length == 0)
    {
        [Common showAlert:@"Don't have any photo"];
    }else
    {
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
}


- (IBAction)addImageForNewEvent:(id)sender
{
    if (imgData.length == 0)
    {
        [Common showAlert:@"Don't have any photo"];
    }else
    {
        AddMyEventVC *vc = [[AddMyEventVC alloc] init];
        vc.image = _imgPhoto.image;
        vc.is_redirecting_calendar = 1;
        
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
    }
}


- (IBAction)clickGroupMembersOnly:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi2];
        [self addNotifi2];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws set_photo_formembers:APP_TOKEN formember:2 photoID:uploaded_photoID userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
}


- (IBAction)clickPublicFeed:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi2];
        [self addNotifi2];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws set_photo_formembers:APP_TOKEN formember:1 photoID:uploaded_photoID userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
}

- (IBAction)clickAreTheseEvents:(id)sender
{
    view_multiple_image_forevent.hidden = NO;
    view_multiple_image_type.hidden = YES;
}
- (IBAction)clickAreTheseElse:(id)sender
{
    //multiple image uploading with userID....
    [self uploadMultiImage];
}
- (IBAction)clickMultipleImageToMyEvent:(id)sender
{
    view_multiple_image_forevent.hidden = YES;
    
    //---Redirecting To My Event List---
    ManageEventsVC *vc = [[ManageEventsVC alloc] init];
    vc.is_add_image = 2; //add multiple images to my event
    vc.chosenImages = self.chosenImages;
    [self.navigationController pushViewController:vc animated:NO];
}
- (IBAction)clickMultipleImageToOtherEvt:(id)sender
{
    view_multiple_image_forevent.hidden = YES;
    
    
    //Redirecting to event search page
    EventSearchResult *vc = [[EventSearchResult alloc] init];
    vc.is_add_image = 2; //add multiple images to other's event
    vc.chosenImages = self.chosenImages;
    
    vc.m_event_name = @"";
    vc.m_event_startDate = @"";
    vc.m_event_endDate = @"";
    vc.m_event_fname = @"";
    vc.m_event_lname = @"";
    vc.m_event_shop = @"";
    vc.m_event_city = @"";
    vc.m_event_country = @"";
    vc.m_event_zipcode = @"";
    vc.m_event_miles = @"";
    vc.m_event_startDate = @"1900-01-01 0:0";
    vc.is_use_mylocation = 0;
    vc.m_event_type = 1;
    [self.navigationController pushViewController:vc animated:NO];
}



-(void) uploadMultiImage
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    if (self.chosenImages.count > 0)
    {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:APP_TOKEN, @"token",
                                    [USER_DEFAULT objectForKey:@"userID"], @"userID",
                                    [NSString stringWithFormat:@"%d", self.chosenImages.count], @"image_cnt",
                                    nil];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://test-api.darumble.com"]];
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://test-api.darumble.com/api/upload/multiphoto/" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            for (int i = 0 ; i < self.chosenImages.count; i ++)
            {
                NSData *imageToUpload = UIImageJPEGRepresentation([Common resizeImage:self.chosenImages[i]], 0.0);
                [formData appendPartWithFileData: imageToUpload name:[NSString stringWithFormat:@"imagedata%d", i] fileName:[NSString stringWithFormat:@"%d%@.jpeg",i,[self makeImageName]] mimeType:@"image/jpeg"];
            }
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"response: %@",jsons);
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             if ([[jsons objectForKey:@"code"] integerValue]==200)
             {
                 //---redirecting---
                 ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
                 vc.menu_type = 1;
                 UINavigationController *navigationController = self.navigationController;
                 NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
                 [activeViewControllers removeLastObject];
                 
                 // Reset the navigation stack
                 [navigationController setViewControllers:activeViewControllers];
                 [navigationController pushViewController:vc animated:NO];
             }
             else
             {
                 [Common showAlert:@"Upload error"];
                 uploaded_photoID = -1;
             }
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             uploaded_photoID = -1;
             if([operation.response statusCode] == 403)
             {
                 //NSLog(@"Upload Failed");
                 return;
             }
             
         }];
        
        [operation start];
    }
}



//==============WEBSERVICE(MemberPublic_Success)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MemberPublic_Success:) name:k_set_photo_formember_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MemberPublic_Fail:) name:k_set_photo_formember_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_set_photo_formember_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_set_photo_formember_fail object:nil];
}
-(void) MemberPublic_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"MemberPublic_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully uploaded"];
        
        ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
        vc.menu_type = 1;
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) MemberPublic_Fail:(NSNotification*)notif
{
    NSLog(@"MemberPublic_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}


//************************//
//*      multipleImage   *//
//************************//
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
                
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                
                [images addObject:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    
    self.chosenImages = images;
    
    view_multiple_image_type.hidden = NO;
    
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
