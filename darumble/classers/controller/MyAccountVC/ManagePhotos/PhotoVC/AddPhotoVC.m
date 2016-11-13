//
//  AddPhotoVC.m
//  DaRumble
//
//  Created by Vidic Phan on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "AddPhotoVC.h"
#import "Define.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
@interface AddPhotoVC ()<UIGestureRecognizerDelegate, UITextViewDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIScrollView *_scrMain;
    __weak IBOutlet UIImageView *_imgPhoto;
    __weak IBOutlet UITextView *_txfDes;
    __weak IBOutlet UILabel *_lblTitle;
    CGPoint velocityF;
    CGPoint velocityL;
    __weak IBOutlet UIView *subAddPhoto;
    __weak IBOutlet UIView *subPhotoIpad;
    NSMutableData *respData;
    NSURLConnection *urlconnection;
}
@end

@implementation AddPhotoVC

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
        _txfDes.text = _photoObj.des;
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
        _txfDes.text = @"";
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
    [self ShouldStartPhotoLibrary];
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
    
    return;
}


-(void) ShouldStartPhotoLibrary{
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
}
- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
- (IBAction)clickAdd:(id)sender {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger mounth = [components month];
    NSInteger year = [components year];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    NSString *imgName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld.png", (long)day, (long)mounth, (long)year, (long)hour, (long)minutes, (long)seconds];
    if (_photoObj.id) {
        if(_txfDes.text.length == 0) {
            [Common showAlert:@"Description cannot be empty"];
        }else{
            if (imgData) {
                [self uploadImage:imgName];
            }
            else
            {
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
                [self addPhotoUser:[NSString stringWithFormat:@"%d", _photoObj.id]];
            }

        }
    }
    
    else
    {
        if (imgData.length == 0) {
            [Common showAlert:@"Don't have any a photo"];
        }else if(_txfDes.text.length == 0) {
            [Common showAlert:@"Description cannot be empty"];
        }else{           
            [self uploadImage:imgName];
        }
    }
}


-(void) uploadImage:(NSString *) imageName
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
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
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":TXT_CATEGORY_OTHER,@"photoID":photoID,@"description":_txfDes.text};
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
@end
