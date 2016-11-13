//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "PhotosContentVC.h"
#import "PhotoDetailsVC.h"
#import "UIImageView+AFNetworking.h"
// Views
#import "TAExampleDotView.h"
#import "TAPageControl.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>

@interface PhotosContentVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    IBOutlet UILabel *label_no_photos;
    UIRefreshControl *refreshControl;
    
    int persize;
}
@property (strong, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (strong, nonatomic) IBOutlet TAPageControl *bannerPageControl;
@end

@implementation PhotosContentVC
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
    persize = 0;
    
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        if (self.flag_from_event == 2)
        {
            //--- For Events Photos from EventDetails Page ---//
            self.flag_from_event = 0;
            bannerImages = [[NSMutableArray alloc] init];
            
            photosArray = self.event_photosArray;
            
            for (PhotoObj *s in self.event_photosArray)
            {
                if (bannerImages.count < 3)
                {
                    //---banner---//
                    [bannerImages addObject:s.URL];
                }
            }
            
            if ([self.event_photosArray count] == 0)
            {
                [Common showAlert:@"No photos found"];
                label_no_photos.hidden = NO;
            }else{
                label_no_photos.hidden = YES;
            }
            
            persize = photosArray.count;
            if (persize > 20)
                persize = 20;
            
            [collectView reloadData];
            self.bannerPageControl.numberOfPages = bannerImages.count;
            [self setupScrollViewImages];
        }else
        {
            [self removeNotifi];
            [self addNotifi];
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            if (self.flag_global_local == 1)
            {
                NSString *str = [USER_DEFAULT objectForKey:@"zip"];
                [ws load_local_photos:APP_TOKEN zip:str userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
            }else
                [ws load_global_photos:APP_TOKEN userID:self.filtered_userId];
            
            photosArray = [[NSMutableArray alloc] init];
        }
    }

    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    
    self.bannerScrollView.delegate = self;
    
    //collectionView
    UINib *cellNib = [UINib nibWithNibName:@"PhotoCell" bundle:nil];
    [collectView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoCell"];
    
    
//    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(startRefresh:)
//             forControlEvents:UIControlEventValueChanged];
//    [collectView addSubview:refreshControl];
//    
//    collectView.alwaysBounceVertical = YES;
    
    refreshControl = [UIRefreshControl new];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    collectView.bottomRefreshControl = refreshControl;
}
/*
- (void)startRefresh:(id)sender
{
    persize *= 2;
    
    if (photosArray.count < persize)
        persize = photosArray.count;
    
    [collectView reloadData];
    [refreshControl endRefreshing];
}*/

- (void)refresh {
    // Do refresh stuff here
    persize *= 2;
    
    if (photosArray.count < persize)
        persize = photosArray.count;
    
    [collectView reloadData];
    [refreshControl endRefreshing];
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
//            AppDelegate *app = [Common appDelegate];
//            [app initSideMenu];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


//---Device Orientation---
-(void)viewWillAppear:(BOOL)animated
{
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
//    return photosArray.count;
    return persize;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.imgCell.image = [UIImage imageNamed:@"drlogo.png"];
    
    PhotoObj *obj = [photosArray objectAtIndex:indexPath.row];
    [Common downloadImageWithURL:[NSURL URLWithString: obj.URL] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            PhotoCell *updateCell = (PhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
            // change the image in the cell
            updateCell.imgCell.contentMode = UIViewContentModeScaleAspectFill;
            updateCell.imgCell.clipsToBounds = YES;
            updateCell.imgCell.image = image;
        }
    }];
    cell.imgPlay.hidden = YES;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoDetailsVC *vc = [[PhotoDetailsVC alloc] init];
    vc.photoObj = [photosArray objectAtIndex:indexPath.row];
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
}

- (void)TAPageControl:(TAPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index
{
    NSLog(@"Bullet index %ld", (long)index);
    [self.bannerScrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.bannerScrollView.frame) * index, 0, CGRectGetWidth(self.bannerScrollView.frame), CGRectGetHeight(self.bannerScrollView.frame)) animated:YES];
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


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Get_photo_success:) name:k_globalphotos_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Get_photo_fail:) name:k_globalphotos_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalphotos_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalphotos_fail object:nil];
}

-(void) Get_photo_success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        NSArray *arr = [[dic objectForKey:@"data"] objectForKey:@"photos"];
        [photosArray removeAllObjects];
        
        bannerImages = [[NSMutableArray alloc] init];
        for (NSDictionary *s in arr)
        {
            //---list---
            PhotoObj *obj = [[PhotoObj alloc] init];
            obj.id = [s objectForKey:@"id"] != [NSNull null]?[[s objectForKey:@"id"] intValue] : 0;
            obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
            obj.URL = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            obj.categoryID = 1;
            
            if (self.filtered_userId > 0)
            {
                if (obj.uid != self.filtered_userId) continue;
            }
            
            [photosArray addObject:obj];
            
            if (bannerImages.count < 3){
                //---banner---
                [bannerImages addObject:obj.URL];
            }
        }
        
        if ([photosArray count] == 0)
        {
            [Common showAlert:@"No photos found"];
            label_no_photos.hidden = NO;
        }else{
            label_no_photos.hidden = YES;
        }
        
        persize = 20;
        if (photosArray.count < persize)
            persize = photosArray.count;
        
        [collectView reloadData];
        self.bannerPageControl.numberOfPages = bannerImages.count;
        [self setupScrollViewImages];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
        label_no_photos.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) Get_photo_fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
