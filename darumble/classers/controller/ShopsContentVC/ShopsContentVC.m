//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ShopsContentVC.h"
#import "UIImageView+AFNetworking.h"
// Views
#import "TAExampleDotView.h"
#import "TAPageControl.h"
#import "ShopDetailsVC.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>

@interface ShopsContentVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    int persize;
    UIRefreshControl *refreshControl;
    
    IBOutlet UILabel *label_no_shops;
}
@property (strong, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (strong, nonatomic) IBOutlet TAPageControl *bannerPageControl;
@end

@implementation ShopsContentVC
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
    
    //---WS API Call---//
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        [self removeNotifi];
        [self addNotifi];
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        if (self.flag_global_local == 1)
        {
            NSString *str = [USER_DEFAULT objectForKey:@"zip"];
            [ws load_local_shops:APP_TOKEN zip:str userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
        }else
            [ws load_global_shops:APP_TOKEN];
    }
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
       
    shopsArray = [[NSMutableArray alloc] init];
    self.bannerScrollView.delegate = self;
    
//---collectionView---
    UINib *cellNib = [UINib nibWithNibName:@"ShopsCell" bundle:nil];
    [collectView registerNib:cellNib forCellWithReuseIdentifier:@"ShopsCell"];
    
    refreshControl = [UIRefreshControl new];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    collectView.bottomRefreshControl = refreshControl;
    
    collectView.alwaysBounceVertical = YES;
}


- (void)refresh
{
    persize *= 2;
    
    if (persize > shopsArray.count)
        persize = shopsArray.count;
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
    return persize;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ShopsCell";
    ShopsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    PhotoObj *obj = [shopsArray objectAtIndex:indexPath.row];
    
    cell.imgCell.image = [UIImage imageNamed:@"drlogo.png"];
    
    [Common downloadImageWithURL:[NSURL URLWithString: obj.URL] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            ShopsCell *updateCell = (ShopsCell*)[collectionView cellForItemAtIndexPath:indexPath];
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
    ShopDetailsVC *vc = [[ShopDetailsVC alloc] init];
    vc.photoObj = [shopsArray objectAtIndex:indexPath.row];
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
        
        [self.bannerScrollView addSubview:imageView];
    }
}


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Get_shop_success:) name:k_globalshops_success  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Get_shop_fail:) name:k_globalshops_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalshops_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_globalshops_fail object:nil];
}
-(void) Get_shop_success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        NSArray *arr = [[dic objectForKey:@"data"] objectForKey:@"shops"];
        [shopsArray removeAllObjects];
        [collectView reloadData];
        
        bannerImages = [[NSMutableArray alloc] init];
        for (NSDictionary *s in arr)
        {
            //---list---
            PhotoObj *obj = [[PhotoObj alloc] init];
            obj.id = [s objectForKey:@"id"] != [NSNull null]?[[s objectForKey:@"id"] intValue] : 0;
            obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
            obj.URL = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            obj.categoryID = 16;
            
            [shopsArray addObject:obj];
            
            if (bannerImages.count < 3){
                //---banner---
                [bannerImages addObject:obj.URL];
            }
        }
        
        if ([shopsArray count] == 0)
        {
            [Common showAlert:@"No shops found"];
            label_no_shops.hidden = NO;
        }else{
            label_no_shops.hidden = YES;
        }

        persize = 20;
        if (persize > shopsArray.count)
            persize = shopsArray.count;
        [collectView reloadData];
        
        self.bannerPageControl.numberOfPages = bannerImages.count;
        [self setupScrollViewImages];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
        label_no_shops.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) Get_shop_fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
