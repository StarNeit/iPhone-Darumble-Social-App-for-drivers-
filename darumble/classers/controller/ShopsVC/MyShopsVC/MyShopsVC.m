//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "MyShopsVC.h"
#import "UIImageView+AFNetworking.h"
#import "ShopListTableCell.h"
#import "AddShopVC.h"
#import "ShopManagerVC.h"
#import "ShopObj.h"
#import "ShopDetailsVC.h"

@interface MyShopsVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    NSMutableArray *shopArray;
    IBOutlet UITableView *myshopsListTableView;
    int m_has_shop;
    IBOutlet UIButton *btn_create_group;
    IBOutlet UIView *shop_list_view;
    IBOutlet UILabel *label_no_found;
}
@end

@implementation MyShopsVC
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
    
    //---WS API Call(Get My Shops & Clubs)---//
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_myshops_clubs:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    m_has_shop = 0;
    myshopsListTableView.tableFooterView = [[UIView alloc] init];
}



//---Gesture Recognizer---
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




//---UI Control---
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
- (IBAction)clickCreateGroup:(id)sender {
    AddShopVC *vc = [[AddShopVC alloc] init];
    vc.title_name = @"Add Shops/Clubs";
    vc.flagOfShop = 1;
    [self.navigationController pushViewController:vc animated:YES];
}





//---UITableView---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [shopArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 180;
    return 78;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---MessageHistoryList---
    NSLog(@"test!");
    static NSString *simpleTableIdentifier = @"ShopListTableCell";
        
    ShopListTableCell *cell = (ShopListTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShopListTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    ShopObj *obj = [[ShopObj alloc] init];
    obj = [shopArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = obj.shop_name;
    
    //---Image---
    UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
    NSURL *url = [NSURL URLWithString:obj.url];
    [cell.imageShop setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                           placeholderImage:holder
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         //cell.imageShop.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
         cell.imageShop.layer.masksToBounds = YES;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         cell.imageShop.image = holder;
     }];
    
    if (indexPath.row == 0)
    {
        if (m_has_shop == 1)
        {
            cell.imageCrown.image = [UIImage imageNamed:@"ic_crown_on.png"];
            btn_create_group.hidden = true;
            shop_list_view.frame = CGRectMake( 0, 0, shop_list_view.frame.size.width, shop_list_view.frame.size.height );
        }else{
            cell.imageCrown.hidden = true;
            btn_create_group.hidden = false;
            shop_list_view.frame = CGRectMake( 0, 45, shop_list_view.frame.size.width, shop_list_view.frame.size.height );
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ShopObj *obj = [[ShopObj alloc] init];
    obj = [shopArray objectAtIndex:indexPath.row];
    if (obj.shop_id == 0){
        
    }else{
        if (obj.is_mycreated_shop == 1)
        {
            ShopManagerVC *vc = [[ShopManagerVC alloc] init];
            vc.m_shopid = obj.shop_id;
            vc.m_shop_detail_info = obj;
            vc.flagOfSwitchView = 0;
            
            UINavigationController *navigationController = self.navigationController;
            NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
            [activeViewControllers removeLastObject];
            // Reset the navigation stack
            [navigationController setViewControllers:activeViewControllers];
            [navigationController pushViewController:vc animated:NO];
        }else{
//            PhotoObj *obj = [[PhotoObj alloc] init];
//            obj.id = [s objectForKey:@"id"] != [NSNull null]?[[s objectForKey:@"id"] intValue] : 0;
//            obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
//            obj.URL = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
//            obj.categoryID = 16;
            
            ShopDetailsVC *vc = [[ShopDetailsVC alloc] init];
            vc.photoObj = [[PhotoObj alloc] init];
            vc.photoObj.id = obj.shop_id;
            vc.photoObj.URL = obj.url;
            
            UINavigationController *navigationController = self.navigationController;
            NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
            [activeViewControllers removeLastObject];
            // Reset the navigation stack
            [navigationController setViewControllers:activeViewControllers];
            [navigationController pushViewController:vc animated:NO];
        }
    }
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    if (indexPath.row == 0) {
        //return nil;
    }
    
    return indexPath;
}



//==============WEBSERVICE(GetMyShopsClubs_Success)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMyShopsClubs_Success:) name:k_get_myshops_clubs_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMyShopsClubs_Fail:) name:k_get_myshops_clubs_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_myshops_clubs_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_myshops_clubs_fail object:nil];
}
-(void) GetMyShopsClubs_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [shopArray removeAllObjects];
        shopArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
        int has_shop = [data objectForKey:@"has_shop"] != [NSNull null] ? [[data objectForKey:@"has_shop"] intValue] : 0;
        m_has_shop = has_shop;
        if (m_has_shop == 0){
            btn_create_group.hidden = false;
        }else
            btn_create_group.hidden = true;
        if (has_shop == 1 && [data objectForKey:@"myshop"] != [NSNull null])
        {
            ShopObj *obj = [[ShopObj alloc] init];
            obj.shop_id = [[data objectForKey:@"myshop"] objectForKey:@"shop_id"] != [NSNull null] ? [[[data objectForKey:@"myshop"] objectForKey:@"shop_id"] intValue] : 0;
            obj.shop_name = [[data objectForKey:@"myshop"] objectForKey:@"shop_name"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"shop_name"] : @"";
            obj.url = [[data objectForKey:@"myshop"] objectForKey:@"url"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"url"] : @"";
            obj.is_mycreated_shop = 1;
            obj.shop_photo_id = [[data objectForKey:@"myshop"] objectForKey:@"photo_id"] != [NSNull null] ? [[[data objectForKey:@"myshop"] objectForKey:@"photo_id"] intValue] : 0;
            
            obj.contact_info = [[data objectForKey:@"myshop"] objectForKey:@"contact_info"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"contact_info"] : @"";
            obj.country = [[data objectForKey:@"myshop"] objectForKey:@"country"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"country"] : @"";
            obj.city = [[data objectForKey:@"myshop"] objectForKey:@"city"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"city"] : @"";
            obj.zip = [[data objectForKey:@"myshop"] objectForKey:@"zip"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"zip"] : @"";
            obj.is_private = [[data objectForKey:@"myshop"] objectForKey:@"private"] != [NSNull null] ? [[[data objectForKey:@"myshop"] objectForKey:@"private"] intValue] : 0;
            obj.desc = [[data objectForKey:@"myshop"] objectForKey:@"description"] != [NSNull null] ? [[data objectForKey:@"myshop"] objectForKey:@"description"] : @"";
            
            [shopArray addObject:obj];
        }
        
        if ([data objectForKey:@"myclub"] != [NSNull null])
        {
            NSArray *arr = [data objectForKey:@"myclub"];
            for (NSDictionary *s in arr)
            {
                ShopObj *obj = [[ShopObj alloc] init];
                obj.shop_id = [s objectForKey:@"shop_id"] != [NSNull null] ? [[s objectForKey:@"shop_id"] intValue] : 0;
                obj.shop_name = [s objectForKey:@"shop_name"] != [NSNull null] ? [s objectForKey:@"shop_name"] : @"";
                obj.url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                obj.is_mycreated_shop = 0;
                
                [shopArray addObject:obj];
            }
        }
        
        if ([shopArray count] == 0)
        {
            [Common showAlert:@"No clubs found"];
            label_no_found.hidden = NO;
        }else{
            label_no_found.hidden = YES;
        }
        
        [myshopsListTableView reloadData];
        [self removeNotifi];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
        label_no_found.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) GetMyShopsClubs_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
