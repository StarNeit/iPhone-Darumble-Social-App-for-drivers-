//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "VehicleSearchResult.h"
#import "UIImageView+AFNetworking.h"
#import "VehicleSearchResultCell.h"
#import "VehicleObj.h"
#import "VehicleDetailsVC.h"
#import "ImageCach.h"

@interface VehicleSearchResult ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UITableView *vehicleListTableView;
    NSMutableArray *vehicleArray;
    IBOutlet UITextField *vehiclemake_filter;
    NSMutableArray * cache_imagesArray;
    IBOutlet UILabel *label_no_result;
}
@end

@implementation VehicleSearchResult
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
    
    //---WS API Call(search vehicle)---
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws search_vehicle:APP_TOKEN make:self.m_make model:self.m_model year:self.m_year type:self.m_type garage:self.m_shop to_year:self.m_toyear];
    }
    vehiclemake_filter.hidden = YES;
    
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"Vehicles";
    [self addGestureRecognizers];
    
//    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,1100)];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self._srcMain addGestureRecognizer:singleTap];
    
    
    vehicleListTableView.tableFooterView = [[UIView alloc] init];
    
    cache_imagesArray = [[NSMutableArray alloc] init];
}

//---Gesture Recognizer----
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [self._srcMain setContentOffset:CGPointMake(0, 0) animated:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
}


//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [vehicleArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 479;
    return 207;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---VehicleList---
    NSLog(@"test!");

    static NSString *simpleTableIdentifier = @"VehicleSearchResultCell";
    
    VehicleSearchResultCell *cell = (VehicleSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VehicleSearchResultCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    VehicleObj *vehicle = [vehicleArray objectAtIndex:indexPath.row];
    
    cell.m_import.text = vehicle.type;
    cell.m_model.text = vehicle.model;
    cell.m_make.text = vehicle.make;
    cell.m_year.text = vehicle.year;
    
    NSURL *url = [NSURL URLWithString: vehicle.url];
    
    if (vehicle.url != NULL && ![vehicle.url isEqualToString:@""])
    {
        //---Vehicle Image---
        if (((ImageCach*)[cache_imagesArray objectAtIndex:indexPath.row]).image)
        {
            cell.thumbnails.image = (UIImage*)((ImageCach*)[cache_imagesArray objectAtIndex:indexPath.row]).image;
            cell.label_noimage.hidden = YES;
        }else
        {
            cell.thumbnails.image = nil;
            //---loading indicator---
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.center=cell.thumbnails.center;
            [activityIndicator startAnimating];
            [cell.thumbnails addSubview:activityIndicator];
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData * data = [[NSData alloc] initWithContentsOfURL: url];
                VehicleSearchResultCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                if ( data == nil )
                {
                    [activityIndicator removeFromSuperview];
                    updateCell.label_noimage.hidden = NO;
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *img = [UIImage imageWithData:data];
                    [activityIndicator removeFromSuperview];
                    
                    if (img != NULL)
                    {
                        if (updateCell)
                        {
                            updateCell.thumbnails.image = img;
                            ((ImageCach*)cache_imagesArray[indexPath.row]).image = img;
                        }
                        updateCell.label_noimage.hidden = YES;
                    }else
                    {
                        updateCell.label_noimage.hidden = NO;
                    }
                });
            });
            
            /*
            UIImage *holder = [UIImage imageNamed:@""];
            if(url) {
                [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                       placeholderImage:holder
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                 {
                     cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
                     cell.thumbnails.clipsToBounds = YES;
                     
                     [activityIndicator removeFromSuperview];
                     cell.label_noimage.hidden = YES;
                     ((ImageCach*)cache_imagesArray[indexPath.row]).image = image;
                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                 {
                     cell.thumbnails.image = holder;
                     
                     [activityIndicator removeFromSuperview];
                     cell.label_noimage.hidden = YES;
                 }];
            }else
            {
                cell.thumbnails.image = holder;
                
                [activityIndicator removeFromSuperview];
                cell.label_noimage.hidden = YES;
            }*/
            
            cell.label_noimage.hidden = YES;
        }
    }else{
        cell.thumbnails.image = nil;
        cell.label_noimage.hidden = NO;
    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    VehicleObj *vehicle = [vehicleArray objectAtIndex:indexPath.row];
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj.id = vehicle.id;
    obj.uid = vehicle.uid;
    obj.URL = vehicle.url;
    obj.categoryID = 3;
    
    VehicleDetailsVC *vc = [[VehicleDetailsVC alloc] init];
    vc.photoObj = obj;
    [self.navigationController pushViewController:vc animated:NO];
    
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == vehiclemake_filter)
    {
        [vehiclemake_filter resignFirstResponder];
        
        vehiclemake_filter.text = [Common trimString:vehiclemake_filter.text];
        
        if (vehiclemake_filter.text.length == 0)
        {
            return true;
        }
        
        VehicleSearchResult *vc = [[VehicleSearchResult alloc] init];
        vc.m_make = vehiclemake_filter.text;
        vc.m_model = self.m_model;
        vc.m_year = self.m_year;
        vc.m_toyear = self.m_toyear;
        vc.m_type = self.m_type;
        vc.m_shop = self.m_shop;
        
        [self.navigationController pushViewController:vc animated:NO];
    }
    return true;
}




//==============WEBSERVICE(Vehicle Search)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VehcileSearch_Success:) name:k_search_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VehcileSearch_Fail:) name:k_search_vehicle_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_vehicle_fail object:nil];
}
-(void) VehcileSearch_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"VehcileSearch_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        vehiclemake_filter.hidden = NO;
        vehicleArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
       
        if ([data objectForKey:@"search_info"] != [NSNull null])
        {
            NSArray *arr = [data objectForKey:@"search_info"];
            for (NSDictionary *s in arr)
            {
                VehicleObj* obj = [[VehicleObj alloc] init];
                obj.id = [s objectForKey:@"id"] != [NSNull null] ? [[s objectForKey:@"id"] intValue] : 0;
                obj.uid = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
                obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                obj.url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                obj.make = [s objectForKey:@"make"] != [NSNull null] ? [s objectForKey:@"make"] : @"";
                obj.model = [s objectForKey:@"model"] != [NSNull null] ? [s objectForKey:@"model"] : @"";
                obj.year = [s objectForKey:@"year"] != [NSNull null] ? [s objectForKey:@"year"] : @"";
                obj.type = [s objectForKey:@"type"] != [NSNull null] ? [s objectForKey:@"type"] : @"";
                obj.garage = [s objectForKey:@"garage"] != [NSNull null] ? [s objectForKey:@"garage"] : @"";
                
                [vehicleArray addObject:obj];
                
                ImageCach *ic = [[ImageCach alloc] init];
                [cache_imagesArray addObject:ic];
            }
            [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,[vehicleArray count] * 207 + 60 + 200)];
            [self removeNotifi];
            [vehicleListTableView reloadData];
            label_no_result.hidden = YES;
        }else{
            [Common showAlert:@"No vehicles found"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeNotifi];
            label_no_result.hidden = NO;
            return;
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
        label_no_result.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) VehcileSearch_Fail:(NSNotification*)notif
{
    NSLog(@"VehcileSearch_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

@end
