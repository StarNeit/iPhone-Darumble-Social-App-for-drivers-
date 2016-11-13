//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "GlobalFeedVC.h"
#import "SearchItemsVC.h"
#import "UIImageView+AFNetworking.h"
// Views
#import "TAExampleDotView.h"
#import "TAPageControl.h"
#import "PhotosContentVC.h"
#import "VideosContentVC.h"
#import "EventsContentVC.h"
#import "VehiclesContentVC.h"
#import "ShopsContentVC.h"
#import "AsyncImageView.h"
#import "VehicleDetailsVC.h"
#import "PhotoDetailsVC.h"
#import "VideoDetailsVC.h"
#import "EventDetailsVC.h"
#import "ShopDetailsVC.h"

#import "AFHTTPClient.h"
#import "ELCImagePickerHeader.h"
#import "darumble-Swift.h"

@interface GlobalFeedVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    NSInteger m_scrollCntList[6];
    
    int m_bannerIndex;
    int m_photoIndex;
    int m_videoIndex;
    int m_eventIndex;
    int m_vehicleIndex;
    int m_shopIndex;
    
    IBOutlet UILabel *label_nothing_show_photo;
    IBOutlet UILabel *label_nothing_show_event;
    IBOutlet UILabel *label_nothing_show_vehicle;
    IBOutlet UILabel *label_nothing_show_shop;
    IBOutlet UILabel *label_nothing_show_video;
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView1;   //banner
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView2;   //photos
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView3;   //videos
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView4;   //events
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView5;   //vehicles
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView6;   //shops/clubs
@property (strong, nonatomic) IBOutletCollection(UIScrollView) NSArray *scrollViews;


@property (strong, nonatomic) IBOutlet TAPageControl *customStoryboardPageControl;  //banner
@property (strong, nonatomic) TAPageControl *customPageControl2;    //photos
@property (strong, nonatomic) TAPageControl *customPageControl3;    //videos
@property (strong, nonatomic) TAPageControl *customPageControl4;    //events
@property (strong, nonatomic) TAPageControl *customPageControl5;    //vehicles
@property (strong, nonatomic) TAPageControl *customPageControl6;    //shops/clubs

@property (strong, nonatomic) IBOutlet UIView *photosView;
@property (strong, nonatomic) IBOutlet UIView *videosView;
@property (strong, nonatomic) IBOutlet UIView *eventsView;
@property (strong, nonatomic) IBOutlet UIView *vehiclesView;
@property (strong, nonatomic) IBOutlet UIView *shopsView;

@property (strong, nonatomic) NSMutableArray *bannerImages;
@property (strong, nonatomic) NSMutableArray *photoImages;
@property (strong, nonatomic) NSMutableArray *videoImages;
@property (strong, nonatomic) NSMutableArray *eventImages;
@property (strong, nonatomic) NSMutableArray *vehicleImages;
@property (strong, nonatomic) NSMutableArray *shopImages;

@end

@implementation GlobalFeedVC
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
    
    
//---WS API Call---
    [self removeNotifi];
    [self addNotifi];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws load_global_feed:APP_TOKEN];
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    
    m_bannerIndex = 0;
    m_photoIndex = 0;
    m_videoIndex = 0;
    m_eventIndex = 0;
    m_vehicleIndex = 0;
    m_shopIndex = 0;
    
    [self addGestureRecognizers];
    if (IS_IPAD){
        [self->_srcMain setContentSize:CGSizeMake(self->_srcMain.frame.size.width,2400)];
    }else{
        [self->_srcMain setContentSize:CGSizeMake(self->_srcMain.frame.size.width,1200)];
    }

    for (NSInteger i = 0; i < 6; i++)
        m_scrollCntList[i] = 0;
    
    for (UIScrollView *scrollView in self.scrollViews) {
        scrollView.delegate = self;
    }
    
    
    //-------------Photos----------------
    // Progammatically init a TAPageControl with a custom dot view.
    self.customPageControl2               = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView2.frame) - 40, CGRectGetWidth(self.scrollView2.frame), 40)];
    
    //-------------Videos----------------
    self.customPageControl3                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView3.frame) - 40, CGRectGetWidth(self.scrollView3.frame), 40)];
    
    //-------------Events----------------
    self.customPageControl4                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView4.frame) - 40, CGRectGetWidth(self.scrollView4.frame), 40)];
  
    //-------------Vehicles----------------
    self.customPageControl5                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView5.frame) - 40, CGRectGetWidth(self.scrollView5.frame), 40)];
    
    //-------------Shops/Clubs----------------
    self.customPageControl6                 = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView6.frame) - 40, CGRectGetWidth(self.scrollView6.frame), 40)];
    
    
    
    
    //---Add touch event to UIScrollView---
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBannerClick:)];
    [self.scrollView1 addGestureRecognizer:singleTap1];
    
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoClick:)];
    [self.scrollView2 addGestureRecognizer:singleTap2];
    
    
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoClick:)];
    [self.scrollView3 addGestureRecognizer:singleTap3];
    
    
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEventClick:)];
    [self.scrollView4 addGestureRecognizer:singleTap4];
    
    
    UITapGestureRecognizer *singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVehicleClick:)];
    [self.scrollView5 addGestureRecognizer:singleTap5];
    
    
    UITapGestureRecognizer *singleTap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShopClick:)];
    [self.scrollView6 addGestureRecognizer:singleTap6];
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
            AppDelegate *app = [Common appDelegate];
            [app initSideMenu];
//            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)onBannerClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"garage:%d",m_bannerIndex]);
    PhotoObj *obj = self.bannerImages[m_bannerIndex];
    if (obj.id == 0){
        [Common showAlert:@"No banners found"];
        return;
    }
    switch (obj.categoryID) {
        case 1:
        {
            PhotoDetailsVC *vc = [[PhotoDetailsVC alloc] init];
            vc.photoObj = obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
//            VideoDetailsVC *vc = [[VideoDetailsVC alloc] init];
//            vc.photoObj = obj;
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            VehicleDetailsVC *vc = [[VehicleDetailsVC alloc] init];
            vc.photoObj = obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            EventDetailsVC *vc = [[EventDetailsVC alloc] init];
            vc.photoObj = obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 16:
        {
            ShopDetailsVC *vc = [[ShopDetailsVC alloc] init];
            vc.photoObj = obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            [Common showAlert:@"No information found on this category"];
            NSLog([NSString stringWithFormat:@"%d", obj.categoryID]);
            break;
    }
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
- (void)onVehicleClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"garage:%d",m_garageIndex]);
    PhotoObj *obj = self.vehicleImages[m_vehicleIndex];
    if (obj.id == 0){
        [Common showAlert:@"No vehicles found"];
        return;
    }
    VehicleDetailsVC *vc = [[VehicleDetailsVC alloc] init];
    vc.photoObj = obj;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)onShopClick:(UITapGestureRecognizer *)gesture
{
    //NSLog([NSString stringWithFormat:@"garage:%d",m_garageIndex]);
    PhotoObj *obj = self.shopImages[m_shopIndex];
    if (obj.id == 0){
        [Common showAlert:@"No shops found"];
        return;
    }
    ShopDetailsVC *vc = [[ShopDetailsVC alloc] init];
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
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (IBAction)clickSearch:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [app initSideMenu];
}

- (IBAction)clickPhotoContentView:(id)sender {
    PhotosContentVC *vc = [[PhotosContentVC alloc] init];
    vc.flag_global_local = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickVideoContentView:(id)sender {
    VideosContentVC *vc = [[VideosContentVC alloc] init];
    vc.flag_global_local = 0;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickEventContentView2:(id)sender {
    [Common showAlert:@"sss"];
}

- (IBAction)clickEventContentView:(id)sender {
    EventsContentVC *vc = [[EventsContentVC alloc] init];
    vc.flag_global_local = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickVehicleContentView:(id)sender {
    VehiclesContentVC *vc = [[VehiclesContentVC alloc] init];
    vc.flag_global_local = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickShopContentView:(id)sender {
    ShopsContentVC *vc = [[ShopsContentVC alloc] init];
    vc.flag_global_local = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickAddPhoto:(id)sender {
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

- (IBAction)clickAddVideo:(id)sender {
    SwiftInterface *inter = [[SwiftInterface alloc] init];
    UIViewController* controller = [inter test];
    [self.navigationController pushViewController:controller animated:NO];
}





//---scroll view---
- (void)TAPageControl:(TAPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index
{
    NSLog(@"Bullet index %ld", (long)index);
    [self.scrollView2 scrollRectToVisible:CGRectMake(CGRectGetWidth(self.scrollView2.frame) * index, 0, CGRectGetWidth(self.scrollView2.frame), CGRectGetHeight(self.scrollView2.frame)) animated:YES];
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    
    if (scrollView == self.scrollView1) {
        if (pageIndex == [_bannerImages count] - 1)
        {
            pageIndex = 0;
            [_scrollView1 setContentOffset: CGPointMake(0,0) animated: false];
            self.customStoryboardPageControl.currentPage = 0;
            return;
        }
        self.customStoryboardPageControl.currentPage = pageIndex;
        m_bannerIndex = (long)pageIndex;
    } else if (scrollView == self.scrollView2) {
        if (pageIndex == [_photoImages count] - 1)
        {
            pageIndex = 0;
            [_scrollView2 setContentOffset: CGPointMake(0,0) animated:false];
            return;
        }
        m_photoIndex = (long)pageIndex;
    } else if (scrollView == self.scrollView3) {
        if (pageIndex == [_videoImages count] - 1)
        {
            pageIndex = 0;
            [_scrollView3 setContentOffset: CGPointMake(0,0) animated:false];
            return;
        }
        m_videoIndex = (long)pageIndex;
    } else if (scrollView == self.scrollView4) {
        if (pageIndex == [_eventImages count] - 1)
        {
            pageIndex = 0;
            [_scrollView4 setContentOffset: CGPointMake(0,0) animated:false];
            return;
        }
        m_eventIndex = (long)pageIndex;
    } else if (scrollView == self.scrollView5) {
        if (pageIndex == [_vehicleImages count] - 1)
        {
            pageIndex = 0;
            [_scrollView5 setContentOffset: CGPointMake(0,0) animated:false];
            return;
        }
        m_vehicleIndex = (long)pageIndex;
    } else if (scrollView == self.scrollView6) {
        if (pageIndex == [_shopImages count] - 1)
        {
            pageIndex = 0;
            [_scrollView6 setContentOffset: CGPointMake(0,0) animated:false];
            return;
        }
        m_shopIndex = (long)pageIndex;
    }
}

#pragma mark - Utils
- (void)setupScrollViewImages
{
    UIImage *holder = [UIImage imageNamed:@""];
    
    int i = 0;
    for (UIScrollView *scrollView in self.scrollViews)
    {
        NSMutableArray* imageData = [[NSMutableArray alloc] init];
        if(i==0) imageData = self.bannerImages;
        if(i==1) imageData = self.photoImages;
        if(i==2) {
            imageData = self.videoImages;
        }
        if(i==3) imageData = self.eventImages;
        if(i==4) imageData = self.vehicleImages;
        if(i==5) imageData = self.shopImages;
        
        for (int idx = 0 ; idx < imageData.count; idx ++)
        {
            NSString *imageURL;
            if (i == 2)
            {
                imageURL = ((PhotoObj*)imageData[idx]).videoThumbnailURL!=nil?((PhotoObj*)imageData[idx]).videoThumbnailURL:@"";
            }else{
                imageURL = ((PhotoObj*)imageData[idx]).URL!=nil?((PhotoObj*)imageData[idx]).URL:@"";
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(scrollView.frame) * idx, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.center=imageView.center;
            [activityIndicator startAnimating];
            [imageView addSubview:activityIndicator];
           
            
            
            NSURL *url = [NSURL URLWithString:imageURL];
            if(url)
            {
                [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                 placeholderImage:holder
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                 {
                     imageView.contentMode = UIViewContentModeScaleAspectFill;
                     imageView.clipsToBounds = YES;
                     [activityIndicator setHidden:TRUE];
                     [activityIndicator removeFromSuperview];
                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                 {
                     imageView.image = holder;
                     [activityIndicator setHidden:TRUE];
                     [activityIndicator removeFromSuperview];
                 }];
            }else
            {
                imageView.image = holder;
            }
            /*
            NSURL *url = [NSURL URLWithString:imageURL];
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = image;
                            [activityIndicator setHidden:TRUE];
                            [activityIndicator removeFromSuperview];
                        });
                    }else{
                        [activityIndicator setHidden:TRUE];
                        [activityIndicator removeFromSuperview];
                    }
                }else{
                    [activityIndicator setHidden:TRUE];
                    [activityIndicator removeFromSuperview];
                }
            }];
            [task resume];*/
            
            [scrollView addSubview:imageView];
        }
        i ++;
    }
}

//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetGlobalFeed_Success:) name:k_globalfeed_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetGlobalFeed_Fail:) name:k_globalfeed_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalfeed_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalfeed_fail object:nil];
}

-(void) GetGlobalFeed_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data0 = [dic objectForKey:@"data"];
        NSDictionary *fulldata = [data0 objectForKey:@"fulldata"];
        NSDictionary *featured_items = [data0 objectForKey:@"featured_items"];
        
        NSDictionary *photos = [fulldata objectForKey:@"photos"];
        NSDictionary *events = [fulldata objectForKey:@"events"];
        NSDictionary *videos = [fulldata objectForKey:@"videos"];
        NSDictionary *vehicles = [fulldata objectForKey:@"vehicles"];
        NSDictionary *shops = [fulldata objectForKey:@"shops"];
        
        NSDictionary *featured_photos = [featured_items objectForKey:@"photos"];
        NSDictionary *featured_videos = [featured_items objectForKey:@"videos"];
        NSDictionary *featured_events = [featured_items objectForKey:@"events"];
        NSDictionary *featured_vehicles = [featured_items objectForKey:@"vehicles"];
        NSDictionary *featured_shops = [featured_items objectForKey:@"shops"];
        
        //---setting Banner Images----
        self.bannerImages = [[NSMutableArray alloc] init];
        if (featured_events != [NSNull null] && featured_events.count > 0)
        {
            for (NSDictionary *data in featured_events)
            {
                if ([data objectForKey:@"url"] != [NSNull null])
                {
                    //[self.bannerImages addObject:[data objectForKey:@"url"]];
                    
                    PhotoObj *obj = [[PhotoObj alloc] init];
                    obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                    obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                    obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                    obj.categoryID = 5;//[data objectForKey:@"type"] != [NSNull null]?[[data objectForKey:@"type"] intValue] : 0;
                    [self.bannerImages addObject:obj];
                }
            }
        }
        if (featured_vehicles != [NSNull null] && featured_vehicles.count > 0)
        {
            for (NSDictionary *data in featured_vehicles)
            {
                if ([data objectForKey:@"url"] != [NSNull null])
                {
                    //[self.bannerImages addObject:[data objectForKey:@"url"]];
                    
                    PhotoObj *obj = [[PhotoObj alloc] init];
                    obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                    obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                    obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                    obj.categoryID = 3;//[data objectForKey:@"type"] != [NSNull null]?[[data objectForKey:@"type"] intValue] : 0;
                    [self.bannerImages addObject:obj];
                }
            }
        }
        if (featured_shops != [NSNull null] && featured_shops.count > 0)
        {
            for (NSDictionary *data in featured_shops)
            {
                if ([data objectForKey:@"url"] != [NSNull null])
                {
                    //[self.bannerImages addObject:[data objectForKey:@"url"]];
                    
                    PhotoObj *obj = [[PhotoObj alloc] init];
                    obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                    obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                    obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                    obj.categoryID = 16;//[data objectForKey:@"type"] != [NSNull null]?[[data objectForKey:@"type"] intValue] : 0;
                    [self.bannerImages addObject:obj];
                }
            }
        }
        if (featured_photos != [NSNull null] && featured_photos.count > 0)
        {
            for (NSDictionary *data in featured_photos)
            {
                if ([data objectForKey:@"url"] != [NSNull null])
                {
                    //[self.bannerImages addObject:[data objectForKey:@"url"]];
                    
                    PhotoObj *obj = [[PhotoObj alloc] init];
                    obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                    obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                    obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                    obj.categoryID = 1;//[data objectForKey:@"type"] != [NSNull null]?[[data objectForKey:@"type"] intValue] : 0;
                    if (obj.categoryID > 0)
                        [self.bannerImages addObject:obj];
                }
            }
        }
        
        self.customStoryboardPageControl.numberOfPages = self.bannerImages.count;
        if (self.bannerImages.count > 0)
        {
            [self.bannerImages addObject:[self.bannerImages objectAtIndex:0]];
        }
        m_scrollCntList[0] = self.bannerImages.count;
        
        //---setting Photo Images----
        if (photos != [NSNull null] && photos.count > 0)
        {
            self.photoImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in photos)
            {
                //[self.photoImages addObject:[data objectForKey:@"url"]];
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 1;
                [self.photoImages addObject:obj];
            }
            [self.photoImages addObject:[self.photoImages objectAtIndex:0]];
            m_scrollCntList[1] = self.photoImages.count;
            label_nothing_show_photo.hidden = YES;
        }else{
            label_nothing_show_photo.hidden = NO;
        }
        
        //---setting Video Images----
        if (videos != [NSNull null] && videos.count > 0)
        {
            self.videoImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in videos)
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
            [self.videoImages addObject:[self.videoImages objectAtIndex:0]];
            m_scrollCntList[2] = self.videoImages.count;
            label_nothing_show_video.hidden = YES;
        }else{
            label_nothing_show_video.hidden = NO;
        }
        
        //---setting Events Images----
        if (events != [NSNull null] && events.count > 0)
        {
            self.eventImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in events)
            {
                //[self.eventImages addObject:[data objectForKey:@"url"]];
                
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 5;
                [self.eventImages addObject:obj];
            }
            [self.eventImages addObject:[self.eventImages objectAtIndex:0]];
            m_scrollCntList[3] = self.eventImages.count;
            label_nothing_show_event.hidden = YES;
        }else{
            label_nothing_show_event.hidden = NO;
        }
        
        //---setting Vehicle Images----
        if (vehicles != [NSNull null] && vehicles.count > 0)
        {
            self.vehicleImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in vehicles)
            {
                //[self.vehicleImages addObject:[data objectForKey:@"url"]];
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 3;
                
                [self.vehicleImages addObject:obj];
            }
            [self.vehicleImages addObject:[self.vehicleImages objectAtIndex:0]];
            m_scrollCntList[4] = self.vehicleImages.count;
            label_nothing_show_vehicle.hidden = YES;
        }else{
            label_nothing_show_vehicle.hidden = NO;
        }
        
        //---setting Shops Images----
        if (shops != [NSNull null] && shops.count > 0)
        {
            self.shopImages = [[NSMutableArray alloc] init];
            for (NSDictionary *data in shops)
            {
                //[self.shopImages addObject:[data objectForKey:@"url"]];
                
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [data objectForKey:@"id"] != [NSNull null]?[[data objectForKey:@"id"] intValue] : 0;
                obj.uid = [data objectForKey:@"uid"] != [NSNull null] ? [[data objectForKey:@"uid"] intValue] : 0;
                obj.URL = [data objectForKey:@"url"] != [NSNull null] ? [data objectForKey:@"url"] : @"";
                obj.categoryID = 16;
                
                [self.shopImages addObject:obj];
            }
            [self.shopImages addObject:[self.shopImages objectAtIndex:0]];
            m_scrollCntList[5] = self.shopImages.count;
            label_nothing_show_shop.hidden = YES;
        }else{
            label_nothing_show_shop.hidden = NO;
        }
        [self setupScrollViewImages];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) GetGlobalFeed_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
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
//---upload multiple images----
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
                 [Common showAlert:@"Successfully uploaded"];
                 [self.navigationController popViewControllerAnimated:true];
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
             
         }];
        
        [operation start];
    }
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
    
    [self uploadMultiImage];
    
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
