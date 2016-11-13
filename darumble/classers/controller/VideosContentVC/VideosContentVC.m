//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "VideosContentVC.h"
#import "VideoDetailsVC.h"
#import "UIImageView+AFNetworking.h"
// Views
#import "TAExampleDotView.h"
#import "TAPageControl.h"

@interface VideosContentVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UILabel *label_no_videos;
}
@property (strong, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (strong, nonatomic) IBOutlet TAPageControl *bannerPageControl;
@end

@implementation VideosContentVC
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
    
    videosArray = [[NSMutableArray alloc] init];
    
    //---collectionView---
    UINib *cellNib = [UINib nibWithNibName:@"VideoCell" bundle:nil];
    [collectView registerNib:cellNib forCellWithReuseIdentifier:@"VideoCell"];
    
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        if (self.flag_from_event == 2)
        {
            [videosArray removeAllObjects];
            [collectView reloadData];
            
            bannerImages = [[NSMutableArray alloc] init];
            for (PhotoObj *s in self.eventsVideos)
            {
                [bannerImages addObject:s.videoThumbnailURL];
                [videosArray addObject:s];
            }
            if (bannerImages.count > 0)
            {
                self.bannerPageControl.numberOfPages = bannerImages.count;
                [self setupScrollViewImages];
            }
            
            if ([videosArray count] == 0)
            {
                [Common showAlert:@"No videos found"];
                label_no_videos.hidden = NO;
            }else{
                label_no_videos.hidden = YES;
            }
            [collectView reloadData];
        }else{
            [self removeNotifi];
            [self addNotifi];
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            if (self.flag_global_local == 1)
            {
                NSString *str = [USER_DEFAULT objectForKey:@"zip"];
                [ws load_local_videos:APP_TOKEN zip:str userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
            }else
                //---need to fix here for the videos show from profile(should add filterUserid)---//
                [ws load_global_videos:APP_TOKEN userID:self.filtered_userId];
        }
    }
    
        // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    
    self.bannerScrollView.delegate = self;

}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.bannerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bannerScrollView.frame) * bannerImages.count, CGRectGetHeight(self.bannerScrollView.frame));
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
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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


//---collection view---
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return videosArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"VideoCell";
    
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PhotoObj *obj = [videosArray objectAtIndex:indexPath.row];
    UIImage *holder = [UIImage imageNamed:@"drlogo.png"];
    cell.imgCell.image = holder;
    
    
    NSURL *url = [NSURL URLWithString:obj.videoThumbnailURL];
    [cell.imgCell setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                        placeholderImage:holder
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         cell.imgCell.contentMode = UIViewContentModeScaleAspectFill;
         cell.imgCell.clipsToBounds = YES;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         cell.imgCell.image = holder;
     }];

    cell.imgPlay.hidden = NO;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoDetailsVC *vc = [[VideoDetailsVC alloc] init];
    vc.photoObj = [videosArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
}


//---Scroll View---
#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //banner scroll indexing
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    self.bannerPageControl.currentPage = pageIndex;

    NSLog([NSString stringWithFormat:@"%d", pageIndex]);
}
- (void)setupScrollViewImages
{
    UIImage *holder = [UIImage imageNamed:@""];
    
    NSMutableArray* imageData = [[NSMutableArray alloc] init];
    imageData = bannerImages;
    
    for (int idx = 0 ; idx < imageData.count; idx ++)
    {
        NSString *imageURL = imageData[idx]!=[NSNull null]?imageData[idx]:@"";
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bannerScrollView.frame) * idx, 0, CGRectGetWidth(self.bannerScrollView.frame), CGRectGetHeight(self.bannerScrollView.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        NSURL *url = [NSURL URLWithString:imageURL];
        if(url)
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
        }
        
        [self.bannerScrollView addSubview:imageView];
    }
}


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Get_video_success:) name:k_globalvideos_success  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Get_video_fail:) name:k_globalvideos_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalvideos_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalvideos_fail object:nil];
}
-(void) Get_video_success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSArray *arr = [[dic objectForKey:@"data"] objectForKey:@"videos"];
        [videosArray removeAllObjects];
        [collectView reloadData];
        
        bannerImages = [[NSMutableArray alloc] init];
        for (NSDictionary *s in arr)
        {
            //---list---
            PhotoObj *obj = [[PhotoObj alloc] init];
            obj.id = [s objectForKey:@"id"] != [NSNull null]?[[s objectForKey:@"id"] intValue] : 0;
            obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
            obj.URL = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            obj.videoThumbnailURL = [s objectForKey:@"thumbnail"] != [NSNull null] ? [s objectForKey:@"thumbnail"] : @"";
            obj.categoryID = 2;
            
            //---banner---//
            [bannerImages addObject:obj.videoThumbnailURL];
            [videosArray addObject:obj];
        }
        if (bannerImages.count > 0)
        {
            self.bannerPageControl.numberOfPages = bannerImages.count;
            [self setupScrollViewImages];
        }
        
        if ([videosArray count] == 0)
        {
            [Common showAlert:@"No videos found"];
            label_no_videos.hidden = NO;
        }else{
            label_no_videos.hidden = YES;
        }
        [collectView reloadData];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
        label_no_videos.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Get_video_fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
