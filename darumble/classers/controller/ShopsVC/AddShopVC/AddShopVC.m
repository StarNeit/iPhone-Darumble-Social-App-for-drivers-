//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "AddShopVC.h"
#import "UIImageView+AFNetworking.h"
#import "MyShopsVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "PickerView.h"
#import "JSON.h"
#import "ShopManagerVC.h"

@interface AddShopVC ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIActionSheetDelegate,PickerViewDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UIButton *toggleGroup;
    IBOutlet UIScrollView *_scrView;
    
    IBOutlet UIView *approvedView;
    IBOutlet UITextField *tf_shopname;
    IBOutlet UITextField *tf_contactinfo;
    IBOutlet UITextField *tf_city;
    IBOutlet UITextView *tf_description;
    
    UIImage *imageChoosePicker;
    NSMutableArray *_arrCountries;
    
    IBOutlet UIImageView *_imgAvatar;
    
    IBOutlet UILabel *m_title_shop;
    IBOutlet UIButton *btn_createshop;
    IBOutlet UIButton *btn_editshop;
    
    IBOutlet UIButton *btn_removeshop;
    
    IBOutlet UIView *controlBar;
}
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txfConutry;
@property(nonatomic,retain) PickerView *pickerView;
@end

@implementation AddShopVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization	
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    [_scrView setContentSize:CGSizeMake(_scrView.frame.size.width,900)];
    toggleGroup.tag = 1002;
    
    approvedView.hidden = YES;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    
    [_scrView addGestureRecognizer:singleTap];
    [self loadAllCountry];
    
    m_title_shop.text = self.title_name;
    if (self.flagOfShop == 1) //add shop
    {
        btn_createshop.hidden = NO;
        btn_editshop.hidden = YES;
        controlBar.hidden = YES;
        
        btn_removeshop.hidden= YES;
    }else if (self.flagOfShop == 2) //edit shop
    {
        btn_createshop.hidden = YES;
        btn_editshop.hidden = NO;
        controlBar.hidden = NO;
        
        btn_removeshop.hidden= NO;
        
        //---fill required parameters---
        tf_shopname.text = self.m_shop_detail_info.shop_name;
        tf_contactinfo.text = self.m_shop_detail_info.contact_info;
        _txfConutry.text = self.m_shop_detail_info.country;
        if ([_txfConutry.text isEqualToString:@"United States"])
        {
            tf_city.text = self.m_shop_detail_info.zip;
        }else{
            tf_city.text = self.m_shop_detail_info.city;
        }
        
        if (self.m_shop_detail_info.is_private == 1){
            [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
            toggleGroup.tag = 1003;
        }else
        {
            [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
            toggleGroup.tag = 1002;
        }
        
        tf_description.text = self.m_shop_detail_info.desc;
    }
}

- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [_scrView setContentOffset:CGPointMake(0, 0) animated:YES];
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
//            AppDelegate *app = [Common appDelegate];
//            [app initSideMenu];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickGroupMember:(id)sender {
    ShopManagerVC *vc = [[ShopManagerVC alloc] init];
    vc.m_shopid = self.m_shop_detail_info.shop_id;
    vc.m_shop_detail_info = self.m_shop_detail_info;
    vc.flagOfSwitchView = 0;
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickRequestGroup:(id)sender {
    ShopManagerVC *vc = [[ShopManagerVC alloc] init];
    vc.m_shopid = self.m_shop_detail_info.shop_id;
    vc.m_shop_detail_info = self.m_shop_detail_info;
    vc.flagOfSwitchView = 1;
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickGroupInvite:(id)sender {
    ShopManagerVC *vc = [[ShopManagerVC alloc] init];
    vc.m_shopid = self.m_shop_detail_info.shop_id;
    vc.m_shop_detail_info = self.m_shop_detail_info;
    vc.flagOfSwitchView = 2;
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickGroupToggle:(id)sender {
    if (toggleGroup.tag == 1002){
        [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleGroup.tag = 1003;
    }else
    if (toggleGroup.tag == 1003){
        [toggleGroup setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        toggleGroup.tag = 1002;
    }
}
- (IBAction)clickRequestApproval:(id)sender {
    tf_shopname.text = trimString(tf_shopname.text);
    tf_contactinfo.text = trimString(tf_contactinfo.text);
    _txfConutry.text = trimString(_txfConutry.text);
    tf_city.text = trimString(tf_city.text);
    tf_description.text = trimString(tf_description.text);
    
    if (tf_shopname.text.length == 0){
        [Common showAlert:@"Shop name is empty"];
        [tf_shopname becomeFirstResponder];
        return;
    }
    if (tf_contactinfo.text.length == 0){
        [Common showAlert:@"Contact info is empty"];
        [tf_contactinfo becomeFirstResponder];
        return;
    }
    if (_txfConutry.text.length == 0){
        [Common showAlert:@"Country is empty"];
        [_txfConutry becomeFirstResponder];
        return;
    }
    if (tf_city.text.length == 0){
        [Common showAlert:@"City is empty"];
        [tf_city becomeFirstResponder];
        return;
    }
    if (tf_description.text.length == 0){
        [Common showAlert:@"Description is empty"];
        [tf_description becomeFirstResponder];
        return;
    }
    
    
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
        if (self.flagOfShop == 1)//Add
        {
            [self loadWS:0];
        }else if (self.flagOfShop == 2)//edit
        {
            [self loadWS:self.m_shop_detail_info.shop_photo_id];
        }
        
    }
}
- (IBAction)clickbacktomyshops:(id)sender {
    MyShopsVC *vc = [[MyShopsVC alloc] init];
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickRemoveShop:(id)sender {
    //---WS API Call(photo detail)---
    [self removeNotifi3];
    [self addNotifi3];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws remove_shop:APP_TOKEN shopID:self.m_shop_detail_info.shop_id];
}



//-------------
- (IBAction)clickUploadImage:(id)sender {
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
    if (_arrCountries.count>0) {
        _txfConutry.text = [_arrCountries objectAtIndex:index];
        if ([_txfConutry.text isEqualToString:@"United States"]) {
            tf_city.placeholder = @"Zipcode";
            tf_city.text = nil;
            [tf_city setKeyboardType:UIKeyboardTypeNumberPad];
        }
        else
        {
            tf_city.placeholder = @"City";
            tf_city.text = nil;
            [tf_city setKeyboardType:UIKeyboardTypeDefault];
        }
    }
    [_pickerView removeFromSuperview];
}
- (IBAction)doCountry:(id)sender {
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrCountries mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
}



//-------Image upload ws api------
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
                 int photoID = [[[jsons objectForKey:@"data"] objectForKey:@"photoID"] intValue];
            
                 [self addPhotoEvent:photoID];
                 
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

-(void) addPhotoEvent:(int) photoID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"categoryID":@"16",@"photoID":[NSString stringWithFormat:@"%d",photoID]};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/photo"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"REPONSE %@",responseObject);
        [self loadWS: photoID];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_Event: %@", error);
        
    }];
}

-(void)loadWS:(int) photoID
{
    tf_shopname.text = trimString(tf_shopname.text);
    tf_contactinfo.text = trimString(tf_contactinfo.text);
    _txfConutry.text = trimString(_txfConutry.text);
    tf_city.text = trimString(tf_city.text);
    tf_description.text = trimString(tf_description.text);
    
    if (self.flagOfShop == 1) // Add Shop
    {
        [self removeNotifi];
        [self addNotifi];
    }else if (self.flagOfShop == 2) // Edit Shop
    {
        [self removeNotifi2];
        [self addNotifi2];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    if ([_txfConutry.text isEqualToString:@"United States"])
    {
        if (self.flagOfShop == 1) // Add Shop
        {
            [ws add_shop:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] shop_name:tf_shopname.text contact_info:tf_contactinfo.text country:_txfConutry.text city:@"" zip:tf_city.text private:toggleGroup.tag == 1003 ? 2 : 1 description:tf_description.text photo_id:photoID shop_status:@"Approved"];
        }else if (self.flagOfShop == 2) // Edit Shop
        {
            [ws edit_shop:APP_TOKEN shop_name:tf_shopname.text contact_info:tf_contactinfo.text country:_txfConutry.text city:@"" zip:tf_city.text private:toggleGroup.tag == 1003 ? 2 : 1 description:tf_description.text shop_id:self.m_shop_detail_info.shop_id photo_id:photoID];
        }
    }else{
        if (self.flagOfShop == 1) // Add Shop
        {
            [ws add_shop:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] shop_name:tf_shopname.text contact_info:tf_contactinfo.text country:_txfConutry.text city:tf_city.text zip:@"" private:toggleGroup.tag == 1003 ? 2 : 1 description:tf_description.text photo_id:photoID shop_status:@"Approved"];
        }else if (self.flagOfShop == 2) // Edit Shop
        {
            [ws edit_shop:APP_TOKEN shop_name:tf_shopname.text contact_info:tf_contactinfo.text country:_txfConutry.text city:tf_city.text zip:@"" private:toggleGroup.tag == 1003 ? 2 : 1 description:tf_description.text shop_id:self.m_shop_detail_info.shop_id photo_id:photoID];
        }
    }
    
}


-(void) textFieldDidBeginEditing:(UITextField *)textField

{
    if (IS_IPAD) {
    }
    else
    {
        if (textField == tf_contactinfo) {
            [_scrView setContentOffset:CGPointMake(0,100) animated:YES];
        }
        else if (textField == tf_city) {
            [_scrView setContentOffset:CGPointMake(0,200) animated:YES];
        }
    }
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == tf_shopname) {
        [tf_contactinfo becomeFirstResponder];
    }else if (textField == tf_contactinfo){
        [tf_city becomeFirstResponder];
    }else if (textField ==tf_city) {
        [tf_city resignFirstResponder];
    }
    return YES;
}


//==============WEBSERVICE(add shop)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddShop_Success:) name:k_add_shop_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddShop_Fail:) name:k_add_shop_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_shop_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_shop_fail object:nil];
}
-(void) AddShop_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"AddShop_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        approvedView.hidden = NO;
        _scrView.hidden = YES;
        controlBar.hidden = YES;
        
        [Common showAlert:@"Your shop was created"];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) AddShop_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

//==============WEBSERVICE(edit shop)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EditShop_Success:) name:k_edit_shop_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EditShop_Fail:) name:k_edit_shop_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_shop_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_shop_fail object:nil];
}
-(void) EditShop_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"EditShop_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully updated"];
        //[self.navigationController popViewControllerAnimated:YES];
        
        MyShopsVC *vc = [[MyShopsVC alloc] init];
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
-(void) EditShop_Fail:(NSNotification*)notif
{
    NSLog(@"EditShop_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}



//==============WEBSERVICE(remove shop)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveShop_Success:) name:k_remove_shop_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveShop_Fail:) name:k_remove_shop_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_shop_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_shop_fail object:nil];
}
-(void) RemoveShop_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"RemoveShop_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully removed"];
        //[self.navigationController popViewControllerAnimated:YES];
        
        MyShopsVC *vc = [[MyShopsVC alloc] init];
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
    [self removeNotifi3];
}
-(void) RemoveShop_Fail:(NSNotification*)notif
{
    NSLog(@"RemoveShop_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}
@end
