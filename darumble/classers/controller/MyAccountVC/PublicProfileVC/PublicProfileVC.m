//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "PublicProfileVC.h"
#import "UIImageView+AFNetworking.h"
// Views
#import "TAExampleDotView.h"
#import "TAPageControl.h"
#import "PhotosContentVC.h"
#import "VideosContentVC.h"
#import "EventsContentVC.h"
#import "VehiclesContentVC.h"
#import "ShopsContentVC.h"
#import "MessageComposeVC.h"
#import "VehicleDetailsVC.h"
#import "PhotoDetailsVC.h"
#import "VideoDetailsVC.h"
#import "EventDetailsVC.h"

@interface PublicProfileVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    IBOutlet UIView *view_block;
    
    IBOutlet UILabel *m_userName;
    IBOutlet UILabel *m_country;
    IBOutlet UILabel *m_city;
    IBOutlet UITextView *m_followerNum;
    IBOutlet UILabel *m_clubName;
    IBOutlet UIImageView *_imgAvatar;
    
    PublicProfileResponse *profileRes;
    NSInteger m_scrollCntList[4];
    IBOutlet UIButton *btn_follow;
    IBOutlet UIButton *btn_message;
    IBOutlet UIButton *btn_block;
    IBOutlet UIButton *btn_report;
    
    int m_garageIndex;
    int m_photoIndex;
    int m_videoIndex;
    int m_eventIndex;
    
    
    IBOutlet UILabel *label_nothing_garage;
    IBOutlet UILabel *label_nothing_photo;
    IBOutlet UILabel *label_nothing_video;
    IBOutlet UILabel *label_nothing_events;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView1;   //vehicles
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView2;   //photos
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView3;   //videos
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView4;   //events
@property (strong, nonatomic) IBOutletCollection(UIScrollView) NSArray *scrollViews;

@property (strong, nonatomic) TAPageControl *customPageControl1;    //vehicles
@property (strong, nonatomic) TAPageControl *customPageControl2;    //photos
@property (strong, nonatomic) TAPageControl *customPageControl3;    //videos
@property (strong, nonatomic) TAPageControl *customPageControl4;    //events

@property (strong, nonatomic) IBOutlet UIView *vehiclesView;
@property (strong, nonatomic) IBOutlet UIView *photosView;
@property (strong, nonatomic) IBOutlet UIView *videosView;
@property (strong, nonatomic) IBOutlet UIView *eventsView;
@property (strong, nonatomic) IBOutlet UIView *controlbarView;

@property (strong, nonatomic) NSMutableArray *vehicleImages;
@property (strong, nonatomic) NSMutableArray *photoImages;
@property (strong, nonatomic) NSMutableArray *videoImages;
@property (strong, nonatomic) NSMutableArray *eventImages;

@end

@implementation PublicProfileVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        if (self.m_userID == 0)
        {
            [Common showAlert:@"userID is Invalid"];
            return;
        }
        if (self.m_userID == [[USER_DEFAULT objectForKey:@"userID"] intValue])
        {
            self.controlbarView.hidden = true;
        }
        //---WS API Call---//
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws load_public_profile:APP_TOKEN userID:self.m_userID];
    }
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    
    [self addGestureRecognizers];
    if (IS_IPAD)
    {
        [self->_srcMain setContentSize:CGSizeMake(self->_srcMain.frame.size.width,2400)];
    }else{
        [self->_srcMain setContentSize:CGSizeMake(self->_srcMain.frame.size.width,950)];
    }
    
    for (NSInteger i = 0; i < 4; i++)
        m_scrollCntList[i] = 0;
    
    for (UIScrollView *scrollView in self.scrollViews) {
        scrollView.delegate = self;
    }
    
    btn_follow.tag = 0;
    btn_message.tag = 0;
    btn_block.tag = 0;
    btn_report.tag = 0;
    
    m_garageIndex = 0;
    m_photoIndex = 0;
    m_videoIndex = 0;
    m_eventIndex = 0;
    
    //-------------Vehicles--------------
    self.customPageControl1                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView1.frame) - 40, CGRectGetWidth(self.scrollView1.frame), 40)];
    
    //-------------Photos----------------
    // Progammatically init a TAPageControl with a custom dot view.
    self.customPageControl2               = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView2.frame) - 40, CGRectGetWidth(self.scrollView2.frame), 40)];
    
    //-------------Videos----------------
    self.customPageControl3                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView3.frame) - 40, CGRectGetWidth(self.scrollView3.frame), 40)];
    
    //-------------Events----------------
    self.customPageControl4                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView4.frame) - 40, CGRectGetWidth(self.scrollView4.frame), 40)];
    
    
    
    //---Add touch event to UIScrollView---
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGarageClick:)];
    [self.scrollView1 addGestureRecognizer:singleTap1];
    
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoClick:)];
    [self.scrollView2 addGestureRecognizer:singleTap2];
    
    
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoClick:)];
    [self.scrollView3 addGestureRecognizer:singleTap3];
    
    
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEventClick:)];
    [self.scrollView4 addGestureRecognizer:singleTap4];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    int ind = 0;
    for (UIScrollView *scrollView in self.scrollViews) {
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame) * m_scrollCntList[ind++], CGRectGetHeight(scrollView.frame));
    }
}


//---Gesture Recognize---
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

- (void)onGarageClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"garage:%d",m_garageIndex]);
        PhotoObj *obj = self.vehicleImages[m_garageIndex];
        if (obj.id == 0){
            [Common showAlert:@"No garages found"];
            return;
        }
        VehicleDetailsVC *vc = [[VehicleDetailsVC alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:YES];
}
- (void)onPhotoClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"photo:%d",m_photoIndex]);
        PhotoObj *obj = self.photoImages[m_photoIndex];
        if (obj.id == 0){
            [Common showAlert:@"No photos found"];
            return;
        }
        PhotoDetailsVC *vc = [[PhotoDetailsVC alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:YES];
}
- (void)onVideoClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"video:%d",m_videoIndex]);
        PhotoObj *obj = self.videoImages[m_videoIndex];
    if (obj.id == 0){
        [Common showAlert:@"No videos found"];
        return;
    }
        VideoDetailsVC *vc = [[VideoDetailsVC alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:YES];
}
- (void)onEventClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"event:%d",m_eventIndex]);
        PhotoObj *obj = self.eventImages[m_eventIndex];
    if (obj.id == 0){
        [Common showAlert:@"No events found"];
        return;
    }
        EventDetailsVC *vc = [[EventDetailsVC alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:YES];

}

//---Device Orientation---
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



//---UI Controller---
- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}
- (IBAction)clickMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
- (IBAction)clickSearch:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickPhotoContentView:(id)sender
{
    PhotosContentVC *vc = [[PhotosContentVC alloc] init];
    vc.filtered_userId = _m_userID;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickVideoContentView:(id)sender
{
    VideosContentVC *vc = [[VideosContentVC alloc] init];
    vc.filtered_userId = _m_userID;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickEventContentView:(id)sender
{
    EventsContentVC *vc = [[EventsContentVC alloc] init];
    vc.filtered_userId = self.m_userID;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickVehicleContentView:(id)sender
{
    VehiclesContentVC *vc = [[VehiclesContentVC alloc] init];
    vc.filtered_userId = _m_userID;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickShopContentView:(id)sender
{
    ShopsContentVC *vc = [[ShopsContentVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}




- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == c_block_user)
    {
        if (buttonIndex == 0) //no
        {
          
        }else if (buttonIndex == 1) //yes
        {
            //---WS API CALL(block user)---
            [self removeNotifi2];
            [self addNotifi2];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws block_user:APP_TOKEN blocker_id:[[USER_DEFAULT objectForKey:@"userID"] intValue] blockee_id:self.m_userID status:1];
        }
    }
    if (alertView.tag == c_report_user)
    {
        if (buttonIndex == 0) //no
        {
        }else if (buttonIndex == 1)
        {
            MessageComposeVC *vc = [[MessageComposeVC alloc] init];
            vc.from_user = [[USER_DEFAULT objectForKey:@"userID"] intValue];
            vc.to_user = self.m_userID;
            vc.is_report = 2;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}


//---ControlBar UI---
- (IBAction)FollowUser:(id)sender
{
    //---WS API CALL(follow user)---
    [self removeNotifi4];
    [self addNotifi4];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    int action = 2;     // 2 : follow user, 1: unfollow user
    [ws follow_user:APP_TOKEN uid:self.m_userID followerid:[[USER_DEFAULT objectForKey:@"userID"] intValue] action:action];
}
- (IBAction)SendMessage:(id)sender
{
    MessageComposeVC *vc = [[MessageComposeVC alloc] init];
    vc.from_user = [[USER_DEFAULT objectForKey:@"userID"] intValue];
    vc.to_user = self.m_userID;
    vc.is_report = 0;
    [self.navigationController pushViewController:vc animated:NO];
}
- (IBAction)BlockUser:(id)sender {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to block this user?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_block_user;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}
- (IBAction)ReportUser:(id)sender {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to report this user?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_report_user;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}



//---Scroll View---
#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
   
    if (scrollView == self.scrollView1){
        m_garageIndex = (long)pageIndex;
    }else if (scrollView == self.scrollView2){
        m_photoIndex = (long)pageIndex;
    }else if (scrollView == self.scrollView3){
        m_videoIndex = (long)pageIndex;
    }else if (scrollView == self.scrollView4){
        m_eventIndex = (long)pageIndex;
    }
}
- (void)TAPageControl:(TAPageControl *)pageControl  :(NSInteger)index
{
    NSLog(@"Bullet index %ld", (long)index);
//    [self.scrollView2 scrollRectToVisible:CGRectMake(CGRectGetWidth(self.scrollView2.frame) * index, 0, CGRectGetWidth(self.scrollView2.frame), CGRectGetHeight(self.scrollView2.frame)) animated:YES];
}
- (void)setupScrollViewImages
{
    UIImage *holder = [UIImage imageNamed:@""];
    
    int i = 0;
    for (UIScrollView *scrollView in self.scrollViews)
    {
        NSMutableArray* imageData = [[NSMutableArray alloc] init];
        if(i==0) imageData = self.vehicleImages;
        if(i==1) imageData = self.photoImages;
        if(i==2) imageData = self.videoImages;
        if(i==3) imageData = self.eventImages;
        
        for (int idx = 0 ; idx < imageData.count; idx ++)
         {
             
             NSString *imageURL;
             if (i == 2)
             {
                 imageURL = ((PhotoObj*)imageData[idx]).videoThumbnailURL!=[NSNull null]?((PhotoObj*)imageData[idx]).videoThumbnailURL:@"";
             }else{
                 imageURL = ((PhotoObj*)imageData[idx]).URL!=[NSNull null]?((PhotoObj*)imageData[idx]).URL:@"";
             }
             UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(scrollView.frame) * idx, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
             imageView.contentMode = UIViewContentModeScaleAspectFill;
             
             //---loading indicator---
             UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
             
             activityView.center=imageView.center;
             [activityView startAnimating];
             [imageView addSubview:activityView];
             
             
             NSURL *url = [NSURL URLWithString:imageURL];
             if(url)
             {
                 [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                  placeholderImage:holder
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                  {
                      imageView.contentMode = UIViewContentModeScaleAspectFill;
                      imageView.clipsToBounds = YES;
                      [activityView setHidden:TRUE];
                      [activityView removeFromSuperview];
                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                  {
                      imageView.image = holder;
                      [activityView setHidden:TRUE];
                      [activityView removeFromSuperview];
                  }];
             }else
             {
                 imageView.image = holder;
                 [activityView setHidden:TRUE];
                 [activityView removeFromSuperview];
             }
             
             [scrollView addSubview:imageView];
         }
        i ++;
    }
}


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetPublicProfile_Success:) name:k_publicprofile_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetPublicProfile_Fail:) name:k_publicprofile_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_publicprofile_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_publicprofile_fail object:nil];
}

-(void) GetPublicProfile_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetPublicProfile SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        profileRes = [ParseUtil parse_get_publicprofile:dic];
        //---Setting Basic Info On Top---
        m_userName.text = [NSString stringWithFormat:@"%@ %@", profileRes.fname, profileRes.lname];
        NSLog(profileRes.city);
        m_country.text = ![profileRes.country isEqualToString:@""]?profileRes.country:@"N/A";
        m_city.text = ![profileRes.city isEqualToString:@""]?profileRes.city:profileRes.zip;
        m_city.text = ![m_city.text isEqualToString:@""]?m_city.text:@"N/A";
        m_clubName.text = ![profileRes.clubName isEqualToString:@""]?profileRes.clubName:@"N/A";
        m_clubName.text = ![m_clubName.text isEqualToString:@"(null)"]?m_clubName.text:@"N/A";

        
        UIImage *holder = [UIImage imageNamed:@"avatar.png"];
        NSLog(@"--->%@",profileRes.url);
        NSURL *url = [NSURL URLWithString:profileRes.url];
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
        
        [m_followerNum setTextColor:[UIColor whiteColor]];
        m_followerNum.text = [NSString stringWithFormat:@"%d",profileRes.followers];
        
        if (profileRes.garages.count > 0)
        {
            self.vehicleImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in profileRes.garages)
            {
                //[self.vehicleImages addObject:[data objectForKey:@"url"]];
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 3;
                
                [self.vehicleImages addObject:obj];
            }
            m_scrollCntList[0] = profileRes.garages.count;
        }else{
            label_nothing_garage.hidden = NO;
        }
        
        if (profileRes.photos.count > 0)
        {
            self.photoImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in profileRes.photos)
            {
                //[self.photoImages addObject:[data objectForKey:@"url"]];
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 1;
                [self.photoImages addObject:obj];
            }
            m_scrollCntList[1] = profileRes.photos.count;
        }else{
            label_nothing_photo.hidden = NO;
        }
        
        if (profileRes.videos.count > 0)
        {
            self.videoImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in profileRes.videos)
            {
                //[self.videoImages addObject:[data objectForKey:@"url"]];
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.videoThumbnailURL = [data objectForKey:@"thumbnail"] != [NSNull null] ? [data objectForKey:@"thumbnail"] : @"";
                obj.categoryID = 2;
                [self.videoImages addObject:obj];
            }
            m_scrollCntList[2] = profileRes.videos.count;
            label_nothing_video.hidden = YES;
        }else{
            label_nothing_video.hidden = NO;
        }
        
        if (profileRes.events.count > 0)
        {
            self.eventImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in profileRes.events)
            {
                //[self.eventImages addObject:[data objectForKey:@"url"]];
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 5;
                [self.eventImages addObject:obj];
            }
            m_scrollCntList[3] = profileRes.events.count;
        }else{
            label_nothing_events.hidden = NO;
        }
        
        [self setupScrollViewImages];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) GetPublicProfile_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}


//==============WEBSERVICE(Block user)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockUser_Success:) name:k_block_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockUser_Fail:) name:k_block_user_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_block_user_fail object:nil];
}
-(void) BlockUser_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"BlockUser_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully Blocked"];
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) BlockUser_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}

//==============WEBSERVICE(Follow User)============
- (void)addNotifi4
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FollowUser_Success:) name:k_follow_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FollowUser_Fail:) name:k_follow_user_fail object:nil];
}
- (void)removeNotifi4
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_follow_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_follow_user_fail object:nil];
}
-(void) FollowUser_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"BlockUser_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully followed"];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}
-(void) FollowUser_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}

@end
