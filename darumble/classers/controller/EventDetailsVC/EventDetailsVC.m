//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "EventDetailsVC.h"
#import "UIImageView+AFNetworking.h"

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
// Views
#import "TAExampleDotView.h"
#import "TAPageControl.h"
#import "PhotosContentVC.h"
#import "PublicProfileVC.h"
#import "CommentCell.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "PhotoDetailsVC.h"
#import "VideoDetailsVC.h"
#import "ELCImagePickerHeader.h"
#import "darumble-Swift.h"
#import "VideosContentVC.h"
/*
#import "FBSDKShareKit/FBSDKShareOpenGraphObject.h"
#import "FBSDKShareKit/FBSDKShareOpenGraphAction.h"
#import "FBSDKShareKit/FBSDKShareDialog.h"
#import "FBSDKShareKit/FBSDKShareOpenGraphContent.h"*/

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface EventDetailsVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UIButton *btn_like;
    IBOutlet UIButton *btn_share;
    IBOutlet UIButton *btn_flag;
    IBOutlet UITextView *tv_eventName;
    IBOutlet UITextView *tv_eventLocation;
    IBOutlet UITextView *tv_eventDate;
    IBOutlet UIButton *btn_organizerName;
    IBOutlet UITextView *tv_contact_info;
    
    NSMutableArray *commentArray;
    IBOutlet UITableView *commentListTableView;
    
    NSString *flyer;
    IBOutlet UIImageView *flyerImageView;
    IBOutlet UIView *flyerView;
    
    int count_otherimage;
    int count_videos;
    IBOutlet UILabel *label_no_photos_toshow;
    
    IBOutlet UILabel *label_no_image;
    int m_photoIndex;
    int m_videoIndex;
    
    FBSDKShareButton *shareButton;
    
    
    //---event videos---//
    IBOutlet UILabel *label_no_videos_toshow;
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (strong, nonatomic) IBOutlet TAPageControl *bannerPageControl;
@property (strong, nonatomic) IBOutlet UIImageView *mainEventPhoto;

@property (strong, nonatomic) IBOutlet TAPageControl *bannerVideoPageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *bannerVideoScrollView;

@end

@implementation EventDetailsVC
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
        //---WS API Call(load event detail)---
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        NSLog([NSString stringWithFormat:@"%d,--- %d",self.photoObj.id,self.photoObj.uid]);
        [ws get_event_details:APP_TOKEN eventID:self.photoObj.id userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
        
        //---WS API Call(load comments)---
        [self removeNotifi6];
        [self addNotifi6];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws2 = [[DataCenter alloc] init];
        [ws2 load_comments:APP_TOKEN catID:self.photoObj.categoryID contentID:self.photoObj.id];
        
        //---WS API Call(load event other photo)---
        [self removeNotifi7];
        [self addNotifi7];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws3 = [[DataCenter alloc] init];
        [ws3 get_event_otherimage:APP_TOKEN eventID:self.photoObj.id];
        
        
        //---WS API Call(load event other photo)---
        [self removeNotifi8];
        [self addNotifi8];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws8 = [[DataCenter alloc] init];
        [ws8 get_event_videos:APP_TOKEN eventID:self.photoObj.id];
    }
    [self restrictRotation:YES];
    
    
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    if (IS_IPAD)
    {
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,3500)];
    }else{
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,2500)];
    }
    
    btn_like.tag = 0;
    btn_share.tag = 0;
    btn_flag.tag = 0;
    m_photoIndex = 0;
    m_videoIndex = 0;
    count_otherimage = 0;
    
//---Share Button---//
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    //        content.contentURL = [NSURL URLWithString:self.photoObj.URL];
//    content.imageURL = [NSURL URLWithString:self.photoObj.URL];
    content.imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.darumble.com/event-details/?eid=%d", self.photoObj.id]];
    content.contentTitle = tv_eventName.text;
    content.contentDescription = tv_eventName.text;
    shareButton = [[FBSDKShareButton alloc] init];
    shareButton.shareContent = content;
    shareButton.center = self.view.center;
    shareButton.hidden = YES;
    [self.view addSubview:shareButton];
    
    
//---Gesture---//
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self._srcMain addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoClick:)];
    [self.bannerScrollView addGestureRecognizer:singleTap2];
    
    
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoClick:)];
    [self.bannerVideoScrollView addGestureRecognizer:singleTap3];
    
//---Event Detail Image---
    if (self.photoObj.URL.length > 0)
    {
        [self.indicator startAnimating];
        [Common downloadImageWithURL:[NSURL URLWithString: self.photoObj.URL] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                self.mainEventPhoto.contentMode = UIViewContentModeScaleAspectFill;
                self.mainEventPhoto.clipsToBounds = YES;
                
                self.mainEventPhoto.image = image;
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
            }
        }];
    }
    
//---Event List---
    self.bannerScrollView.delegate = self;
    self.bannerVideoScrollView.delegate = self;
    //self.bannerPageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bannerScrollView.frame) - 40, CGRectGetWidth(self.bannerScrollView.frame), 40)];
    
    
//---Comment List---
    commentListTableView.tableFooterView = [[UIView alloc] init];
    commentListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    flyerView.hidden = YES;
}

- (void)onPhotoClick:(UITapGestureRecognizer *)gesture
{
    NSLog([NSString stringWithFormat:@"photo:%d",m_photoIndex]);
    PhotoObj *obj = bannerImages[m_photoIndex];
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
    NSLog([NSString stringWithFormat:@"video:%d",m_videoIndex]);
    PhotoObj *obj = bannerVideos[m_videoIndex];
    if (obj.id == 0){
        [Common showAlert:@"No photos found"];
        return;
    }
    VideoDetailsVC *vc = [[VideoDetailsVC alloc] init];
    vc.photoObj = obj;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)doShowImage:(id)sender
{
    if(self.mainEventPhoto)
    {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = self.mainEventPhoto.image;
        imageInfo.referenceRect = self.mainEventPhoto.frame;
        imageInfo.referenceView = self.mainEventPhoto.superview;
        imageInfo.referenceContentMode = self.mainEventPhoto.contentMode;
        
        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}


- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    //[self._srcMain setContentOffset:CGPointMake(0, 0) animated:YES];
}


//---add gesture---
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.bannerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bannerScrollView.frame) * count_otherimage, CGRectGetHeight(self.bannerScrollView.frame));
    self.bannerVideoScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bannerVideoScrollView.frame) * count_videos, CGRectGetHeight(self.bannerVideoScrollView.frame));
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


//---device orientatioin---
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

-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
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
    
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}


//---UI Controller---
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == c_like_content)
    {
        if (buttonIndex == 0) //no
        {
            if (btn_like.tag == 0) return;
            [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi3];
            [self addNotifi3];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:1 creatorid:self.photoObj.uid];
            btn_like.tag = 0;
        }else if (buttonIndex == 1) //yes
        {
            if (btn_like.tag == 1) return;
            [btn_like setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi3];
            [self addNotifi3];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:2 creatorid:self.photoObj.uid];
            btn_like.tag = 1;
        }
    }
    if (alertView.tag == c_flag_content)
    {
        if (buttonIndex == 0) //no
        {
            if (btn_flag.tag == 0) return;
            [btn_flag setImage:[UIImage imageNamed:@"flag.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi4];
            [self addNotifi4];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws flag_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isFlag:1];
            
            btn_flag.tag = 0;
        }else if (buttonIndex == 1) //yes
        {
            if (btn_flag.tag == 1) return;
            [btn_flag setImage:[UIImage imageNamed:@"flag_on.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi4];
            [self addNotifi4];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws flag_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isFlag:2];
            
            btn_flag.tag = 1;
        }
    }
}
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
- (IBAction)clickLike:(id)sender
{
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Do you like this content?",nil)
//                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
//    errorAlert.tag = c_like_content;
//    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
//    [errorAlert show];
    
    if (btn_like.tag == 1) //no
    {
        [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        
        //---WS API CALL(like content)---
        [self removeNotifi3];
        [self addNotifi3];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:1 creatorid:self.photoObj.uid];
        btn_like.tag = 0;
    }else if (btn_like.tag == 0) //yes
    {
        [btn_like setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
        
        //---WS API CALL(like content)---
        [self removeNotifi3];
        [self addNotifi3];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:2 creatorid:self.photoObj.uid];
        btn_like.tag = 1;
    }
}
- (IBAction)clickFlag:(id)sender
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to flag this content?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_flag_content;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}

- (IBAction)clickShare:(id)sender {
    if (btn_share.tag == 0){
        btn_share.tag = 1;
        [btn_share setImage:[UIImage imageNamed:@"share_on.png"] forState:UIControlStateNormal];
        
        /*
        
        // Create an object
        NSDictionary *properties = @{
                                     @"og:type": @"books.book",
                                     @"og:title": @"A Game of Thrones",
                                     @"og:description": @"In the frozen wastes to the north of Winterfell, sinister and supernatural forces are mustering.",
                                     @"books:isbn": @"0-553-57340-3",
                                     };
        FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
        
        // Create an action
        FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
        action.actionType = @"books.reads";
        [action setObject:object forKey:@"books:book"];
        
        
        // Create the content
        FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
        content.action = action;
        content.previewPropertyName = @"books:book";

        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];*/
        
        [shareButton sendActionsForControlEvents:UIControlEventTouchUpInside];

        
    }else if (btn_share.tag == 1){
        btn_share.tag = 0;
        [btn_share setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)clickMore:(id)sender {
    PhotosContentVC *vc = [[PhotosContentVC alloc] init];
    self.flagOfAddedComment = 0;
    vc.event_photosArray = bannerImages;
    vc.flag_from_event = 2;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickVideoMore:(id)sender {
    VideosContentVC *vc = [[VideosContentVC alloc] init];
    vc.eventsVideos = bannerVideos;
    vc.flag_from_event = 2;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickAdderName:(id)sender {
    //---WS API CALL(check blocked status)---
    [self removeNotifi5];
    [self addNotifi5];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    if (self.photoObj.uid == 0 || [[USER_DEFAULT objectForKey:@"userID"] intValue] == 0)
    {
        [Common showAlert:@"Couldn't access this user."];
        return;
    }
    [ws check_blocked_status:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] userID2:self.photoObj.uid];
}
- (void)setLikeFlagButton{
    if (btn_like.tag == 0){
        [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    }else if (btn_like.tag == 1){
        [btn_like setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
    }
    
    /*if (btn_share.tag == 0){
        [btn_share setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    }else if (btn_share.tag == 1){
        [btn_share setImage:[UIImage imageNamed:@"share_on.png"] forState:UIControlStateNormal];
    }*/
    
    if (btn_flag.tag == 0){
        [btn_flag setImage:[UIImage imageNamed:@"flag.png"] forState:UIControlStateNormal];
    }else if (btn_flag.tag == 1){
        [btn_flag setImage:[UIImage imageNamed:@"flag_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)clickViewFlyer:(id)sender {
    if ([flyer isEqualToString:@""])
    {
        [Common showAlert:@"No flyer found"];
        return;
    }
    flyerView.hidden = NO;
    [flyerView setFrame:CGRectMake(flyerView.frame.origin.x,
                                       100,flyerView.frame.size.width
                                       ,flyerView.frame.size.height)];
}

- (IBAction)cancelViewFlyer:(id)sender {
    flyerView.hidden = YES;
    [flyerView setFrame:CGRectMake(flyerView.frame.origin.x,
                                   -2000,flyerView.frame.size.width
                                   ,flyerView.frame.size.height)];
}





//---Scroll View---
#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //banner scroll indexing
    int pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    NSLog([NSString stringWithFormat:@"%d" , pageIndex]);
//    if (pageIndex < bannerImages.count){
//        self.bannerPageControl.currentPage = pageIndex;
//        m_photoIndex = (long)pageIndex;
//    }
    
    if (scrollView == self.bannerScrollView) {
        if (pageIndex < bannerImages.count){
            self.bannerPageControl.currentPage = pageIndex;
            m_photoIndex = (long)pageIndex;
        }
    } else if (scrollView == self.bannerVideoScrollView) {
        if (pageIndex < bannerVideos.count){
            self.bannerVideoPageControl.currentPage = pageIndex;
            m_videoIndex = (long)pageIndex;
        }
    }
}

- (void)TAPageControl:(TAPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index
{
//    NSLog(@"Bullet index %ld", (long)index);
//    [self.bannerScrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.bannerScrollView.frame) * index, 0, CGRectGetWidth(self.bannerScrollView.frame), CGRectGetHeight(self.bannerScrollView.frame)) animated:YES];
}

- (void)setupScrollViewImages
{
    UIImage *holder = [UIImage imageNamed:@""];
    
    NSMutableArray* imageData = [[NSMutableArray alloc] init];
    imageData = bannerImages;
    
    for (int idx = 0 ; idx < imageData.count; idx ++)
    {
        NSString *imageURL = ((PhotoObj*)imageData[idx]).URL!=[NSNull null]?((PhotoObj*)imageData[idx]).URL:@"";
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bannerScrollView.frame) * idx, 0, CGRectGetWidth(self.bannerScrollView.frame), CGRectGetHeight(self.bannerScrollView.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        NSURL *url = [NSURL URLWithString:imageURL];
        /*if(url)
         {
         
         [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url]
         placeholderImage:holder
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
         imageView.contentMode = UIViewContentModeScaleAspectFill;
         imageView.clipsToBounds = YES;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
         imageView.image = holder;
         }];
         
         }else
         {
         imageView.image = holder;
         }*/
        
        
        //---Event Image---
        
        imageView.image = nil;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                    });
                }
            }
        }];
        [task resume];
        
        [self.bannerScrollView addSubview:imageView];
    }
}

- (void)setupScrollViewVideos
{
    UIImage *holder = [UIImage imageNamed:@""];
    
    NSMutableArray* imageData = [[NSMutableArray alloc] init];
    imageData = bannerVideos;
    
    for (int idx = 0 ; idx < imageData.count; idx ++)
    {
        NSString *imageURL = ((PhotoObj*)imageData[idx]).videoThumbnailURL!=[NSNull null]?((PhotoObj*)imageData[idx]).videoThumbnailURL:@"";
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bannerVideoScrollView.frame) * idx, 0, CGRectGetWidth(self.bannerVideoScrollView.frame), CGRectGetHeight(self.bannerVideoScrollView.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        NSURL *url = [NSURL URLWithString:imageURL];
        
        
        //---Video Image---
        imageView.image = nil;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                    });
                }
            }
        }];
        [task resume];
        
        [self.bannerVideoScrollView addSubview:imageView];
    }
}


//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD)
    {
        if (indexPath.row == [commentArray count] - 1)
            return 445;
        return 310;
    }else{
        if (indexPath.row == [commentArray count] - 1)
            return 200;
        return 158;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---PhotoList---
    NSLog(@"test!");
    
    static NSString *simpleTableIdentifier = @"CommentCell";
    
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    UserObj *comment = [commentArray objectAtIndex:indexPath.row];
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", comment.fname, comment.lname];
    cell.comment.text = comment.c_description;
    if (IS_IPAD)
    {
        UIFont *font = cell.userName.font;
        cell.userName.font = [font fontWithSize:30];
        [cell.comment setFont: [font fontWithSize:30]];
    }
    
    if (indexPath.row != [commentArray count] - 1)
    {
        cell.comment.editable = false;
    }else cell.comment.editable = true;
    
    
    cell.btnPostComment.tag = indexPath.row;
    [cell.btnPostComment addTarget:self action:@selector(clickPostComment:) forControlEvents:UIControlEventTouchUpInside];
    
    //---Photo Image---
    UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
    NSURL *url = [NSURL URLWithString:comment.profile_pic_url];
    
    [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                           placeholderImage:holder
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         cell.thumbnails.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
         cell.thumbnails.layer.masksToBounds = YES;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         cell.thumbnails.image = holder;
     }];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}

- (void) clickPostComment:(id)sender
{
    int row = ((UIButton*)sender).tag;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // in case this row in in your first section
    CommentCell* cell = [commentListTableView cellForRowAtIndexPath:indexPath];
    cell.comment.text = [Common trimString:cell.comment.text];
    
    if (cell.comment.text.length == 0) {
        [Common showAlert:@"Comment is empty"];
        return;
    }
    
    //---WS API Call(add comment)---
    [self removeNotifi2];
    [self addNotifi2];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws add_comment:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id description:cell.comment.text creatorid:self.photoObj.uid];
}



//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEvents_Success:) name:k_event_details_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEvents_Fail:) name:k_event_details_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_event_details_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_event_details_fail object:nil];
}

-(void) GetEvents_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        NSDictionary *event_details = [data objectForKey:@"event_details"];
        
        int uid = [[event_details objectForKey:@"uid"] intValue];
        NSString *location = [event_details objectForKey:@"location"] != [NSNull null] ? [event_details objectForKey:@"location"] : @"";
        NSString *name = [event_details objectForKey:@"name"] != [NSNull null] ? [event_details objectForKey:@"name"] : @"";
        NSString *start_date = [event_details objectForKey:@"start_date"] != [NSNull null] ? [event_details objectForKey:@"start_date"] : @"";
        flyer = [event_details objectForKey:@"flyer"] != [NSNull null] ? [event_details objectForKey:@"flyer"] : @"";
        NSString *description = [event_details objectForKey:@"description"];
        NSString *contactinfo = [event_details objectForKey:@"contact_info"];
        NSString *fname = [event_details objectForKey:@"fname"] != [NSNull null] ? [event_details objectForKey:@"fname"] : @"";
        NSString *lname = [event_details objectForKey:@"lname"] != [NSNull null] ? [event_details objectForKey:@"lname"] : @"";
        int is_flagged = [event_details objectForKey:@"is_flagged"] != [NSNull null] ? [[event_details objectForKey:@"is_flagged"] intValue] : 0;
        int is_like = [event_details objectForKey:@"is_like"] != [NSNull null] ? [[event_details objectForKey:@"is_like"] intValue] : 0;
        
        btn_flag.tag = is_flagged;
        btn_like.tag = is_like;
        btn_share.tag = 0;
        [self setLikeFlagButton];
        
        [tv_eventName setTextColor:[UIColor whiteColor]];
        tv_eventName.text = name;
        
        [tv_eventLocation setTextColor:[UIColor whiteColor]];
        tv_eventLocation.text = location;
        
        [tv_eventDate setTextColor:[UIColor whiteColor]];
        
        tv_contact_info.text = contactinfo;
        
        NSDate *date = [Common convertStringToDate:start_date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"MMMM dd, yyyy hh:mm a"];
        NSString *dateDisplay = [dateFormat stringFromDate:date];
        tv_eventDate.text = dateDisplay;
        
        [btn_organizerName setTitle:[NSString stringWithFormat:@"%@ %@",fname, lname] forState:UIControlStateNormal];
        
        if (![flyer isEqualToString:@""])
        {
            //---Event Image---
            flyerImageView.image = nil;
            NSURL *url = [NSURL URLWithString: flyer];
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            flyerImageView.image = image;
                        });
                    }
                }
            }];
            [task resume];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) GetEvents_Fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}


//==============WEBSERVICE(Add Comment)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddComment_Success:) name:k_add_comment_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddComment_Fail:) name:k_add_comment_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_comment_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_comment_fail object:nil];
}
-(void) AddComment_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Your comment was posted!"];
        
        
        //--redirecting me---
        EventDetailsVC *vc = [[EventDetailsVC alloc] init];
        vc.photoObj = self.photoObj;
        vc.flagOfAddedComment = 1;
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
        
        
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) AddComment_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}



//==============WEBSERVICE(Like Content)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LikeContent_Success:) name:k_like_content_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LikeContent_Fail:) name:k_like_content_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_like_content_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_like_content_fail object:nil];
}
-(void) LikeContent_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        int isLike = [data objectForKey:@"isLike"] != [NSNull null] ? [[data objectForKey:@"isLike"] intValue] : 1;
//        if (isLike == 1)
//        {
//            [Common showAlert:@"Staff will be notified. Thank you"];
//        }else if (isLike == 2)
//        {
//            [Common showAlert:@"Staff will be notified. Thank you"];
//        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}
-(void) LikeContent_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}


//==============WEBSERVICE(Flag Content)============
- (void)addNotifi4
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FlagContent_Success:) name:k_flag_content_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FlagContent_Fail:) name:k_flag_content_fail object:nil];
}
- (void)removeNotifi4
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_flag_content_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_flag_content_fail object:nil];
}
-(void) FlagContent_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        int isFlag = [data objectForKey:@"isFlag"] != [NSNull null] ? [[data objectForKey:@"isFlag"] intValue] : 1;
        /*if (isFlag == 1)
        {
            [Common showAlert:@"You have unflagged this event"];
        }else if (isFlag == 2)
        {
            [Common showAlert:@"You have flagged this event"];
        }*/
        [Common showAlert:@"Staff will be notified. Thank you"];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}
-(void) FlagContent_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}



//==============WEBSERVICE(check blocked status)============
- (void)addNotifi5
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckBlockedStatus_Success:) name:k_check_blocked_status_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckBlockedStatus_Fail:) name:k_check_blocked_status_fail object:nil];
}
- (void)removeNotifi5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_check_blocked_status_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_check_blocked_status_fail object:nil];
}
-(void) CheckBlockedStatus_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        PublicProfileVC *vc = [[PublicProfileVC alloc] init];
        vc.m_userID = self.photoObj.uid;
        self.flagOfAddedComment = 0;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}
-(void) CheckBlockedStatus_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}


//==============WEBSERVICE(load comments)============
- (void)addNotifi6
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoadComments_Success:) name:k_load_comments_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoadComments_Fail:) name:k_load_comments_fail object:nil];
}
- (void)removeNotifi6
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_load_comments_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_load_comments_fail object:nil];
}
-(void) LoadComments_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"LoadComments_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        commentArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"comments"] != [NSNull null])
        {
            NSArray *arr = [data objectForKey:@"comments"];
            for (NSDictionary *s in arr)
            {
                UserObj* obj = [[UserObj alloc] init];
                obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                obj.profile_pic_url = [s objectForKey:@"profile_pic"] != [NSNull null] ? [s objectForKey:@"profile_pic"] : @"";
                obj.c_description = [s objectForKey:@"description"] != [NSNull null] ? [s objectForKey:@"description"] : @"";
                [commentArray addObject:obj];
            }
        }else{
            //[Common showAlert:@"No Comment exist"];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi6];
    
    
    //---new api---
    UserObj *me = [[UserObj alloc] init];
    me.fname = [USER_DEFAULT objectForKey:@"fname"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"fname"] : @"";
    me.lname = [USER_DEFAULT objectForKey:@"lname"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"lname"] : @"";
    me.c_description = @"";
    me.profile_pic_url = [USER_DEFAULT objectForKey:@"photo_url"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"photo_url"] : @"";
    [commentArray addObject:me];
    
    if (IS_IPAD)
    {
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,(310 *([commentArray count] - 1) + 445) + 2200)];
    }else{
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,(158 *([commentArray count] - 1) + 200) + 1500)];
    }
    
    
    if (self.flagOfAddedComment == 1)
    {
        [self._srcMain setContentOffset:CGPointMake(0.0,  570.0) animated:true];
    }
    [commentListTableView reloadData];
}
-(void) LoadComments_Fail:(NSNotification*)notif
{
    NSLog(@"LoadComments_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi6];
}


//==============WEBSERVICE(get event other images)============
- (void)addNotifi7
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEventOtherImages_Success:) name:k_get_event_otherimage_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEventOtherImages_Fail:) name:k_get_event_otherimage_fail object:nil];
}
- (void)removeNotifi7
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_event_otherimage_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_event_otherimage_fail object:nil];
}
-(void) GetEventOtherImages_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetEventOtherImages_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"result"] == [NSNull null])
        {
            //[Common showAlert:@"No additional photos"];
            label_no_photos_toshow.hidden = NO;
        }else{
            NSArray *arr = [[dic objectForKey:@"data"] objectForKey:@"result"];

            bannerImages = [[NSMutableArray alloc] init];
            for (NSDictionary *s in arr)
            {
                //---list---
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [s objectForKey:@"id"] != [NSNull null]?[[s objectForKey:@"id"] intValue] : 0;
                obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
                obj.URL = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                obj.categoryID = [s objectForKey:@"type"] != [NSNull null]?[[data objectForKey:@"type"] intValue] : 0;
                
                [bannerImages addObject:obj];
            }
            
            self.bannerPageControl.numberOfPages = bannerImages.count;
            count_otherimage = bannerImages.count;
            if (count_otherimage == 0)
            {
                label_no_photos_toshow.hidden = NO;
            }
            [self setupScrollViewImages];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi7];
}
-(void) GetEventOtherImages_Fail:(NSNotification*)notif
{
    NSLog(@"LoadComments_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi7];
}



//==============WEBSERVICE(get event other videos)============
- (void)addNotifi8
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEventVideos_Success:) name:k_get_event_videos_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetEventVideos_Fail:) name:k_get_event_videos_fail object:nil];
}
- (void)removeNotifi8
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_event_videos_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_event_videos_fail object:nil];
}
-(void) GetEventVideos_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetEventVideos_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"result"] == [NSNull null])
        {
            label_no_videos_toshow.hidden = NO;
        }else{
            NSArray *arr = [[dic objectForKey:@"data"] objectForKey:@"result"];
            
            bannerVideos = [[NSMutableArray alloc] init];
            for (NSDictionary *s in arr)
            {
                //---list---
                PhotoObj *obj = [[PhotoObj alloc] init];
                obj.id = [s objectForKey:@"id"] != [NSNull null]?[[s objectForKey:@"id"] intValue] : 0;
                obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
                obj.URL = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                obj.categoryID = [s objectForKey:@"catid"] != [NSNull null]?[[data objectForKey:@"catid"] intValue] : 0;
                obj.videoThumbnailURL = [s objectForKey:@"thumbnail"] != [NSNull null] ? [s objectForKey:@"thumbnail"] : @"";
                
                [bannerVideos addObject:obj];
            }
            
            self.bannerVideoPageControl.numberOfPages = bannerVideos.count;
            count_videos = bannerVideos.count;
            if (count_videos == 0)
            {
                label_no_videos_toshow.hidden = NO;
            }
            [self setupScrollViewVideos];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi8];
}
-(void) GetEventVideos_Fail:(NSNotification*)notif
{
    NSLog(@"GetEventVideos_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi8];
}





//----------
- (IBAction)onClickAddPhoto:(id)sender {
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


- (IBAction)onClickAddVideo:(id)sender {
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%d", self.photoObj.id] forKey:@"video_eventID"];
    
    SwiftInterface *inter = [[SwiftInterface alloc] init];
    UIViewController* controller = [inter test];
    [self.navigationController pushViewController:controller animated:NO];
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
                                    [NSString stringWithFormat:@"%d", self.photoObj.id], @"eventID",
                                    [NSString stringWithFormat:@"%d", self.photoObj.uid], @"creatorid",
                                    nil];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://test-api.darumble.com"]];
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://test-api.darumble.com/api/upload/multiphoto_to_event/" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
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
                 [Common showAlert:@"Successfully added images to event"];
                 
                 //---Reload---//
                 EventDetailsVC *vc = [[EventDetailsVC alloc] init];
                 vc.photoObj = self.photoObj;
                 vc.chosenImages = self.chosenImages;
                 vc.flagOfAddedComment = _flagOfAddedComment;
                 
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
    }else{
        [Common showAlert:@"No images selected"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
