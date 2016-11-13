//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "PhotoSearchResultVC.h"
#import "RumblerCell.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoSearchResultCell.h"
#import "PhotoDetailsVC.h"
#import "ImageCach.h"


@interface PhotoSearchResultVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UITableView *photoListTableView;
    NSMutableArray *photoArray;
    IBOutlet UITextField *phototag_filter;
    NSMutableArray * cache_imagesArray;
    IBOutlet UILabel *label_no_result;
}
@end

@implementation PhotoSearchResultVC
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
    
    //---WS API Call(search photo)---//
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws search_photo:APP_TOKEN startDate:self.m_startDate endDate:self.m_endDate fname:self.m_fname lname:self.m_lname tags:self.m_tags associated_shop:self.m_shop];
    }
    phototag_filter.hidden = YES;
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"Photos";
    [self addGestureRecognizers];
    
//    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,1100)];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self._srcMain addGestureRecognizer:singleTap];
    
    //---hide separated line uitableview---
    photoListTableView.tableFooterView = [[UIView alloc] init];
    photoListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    return [photoArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 447;
    return 208;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---PhotoList---
    NSLog(@"test!");

    static NSString *simpleTableIdentifier = @"PhotoSearchResultCell";
    
    PhotoSearchResultCell *cell = (PhotoSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoSearchResultCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    UserObj *photo = [photoArray objectAtIndex:indexPath.row];
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", photo.fname, photo.lname];
    
    
    NSURL *url = [NSURL URLWithString:photo.profile_pic_url];
    
    if (photo.profile_pic_url != NULL && ![photo.profile_pic_url isEqualToString:@""])
    {
        //---Photo Image---
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
                PhotoSearchResultCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
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
                    }else{
                        updateCell.label_noimage.hidden = NO;
                    }
                });
            });
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
   
    UserObj *photo = [photoArray objectAtIndex:indexPath.row];
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj.id = photo.id;
    obj.uid = photo.userID;
    obj.URL = photo.profile_pic_url;
    obj.categoryID = 1;
    
    PhotoDetailsVC *vc = [[PhotoDetailsVC alloc] init];
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
    if (textField == phototag_filter)
    {
        [phototag_filter resignFirstResponder];
        
        phototag_filter.text = [Common trimString:phototag_filter.text];
        
        if (phototag_filter.text.length == 0)
        {
            return true;
        }
        
        PhotoSearchResultVC *vc = [[PhotoSearchResultVC alloc] init];
        vc.m_tags = phototag_filter.text;
        vc.m_startDate = self.m_startDate;
        vc.m_endDate = self.m_endDate;
        vc.m_fname = self.m_fname;
        vc.m_lname = self.m_lname;
        vc.m_shop = self.m_shop;
        
        [self.navigationController pushViewController:vc animated:NO];
    }
    return true;
}




//==============WEBSERVICE(Photo Search)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PhotoSearch_Success:) name:k_search_photo_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PhotoSearch_Fail:) name:k_search_photo_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_photo_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_photo_fail object:nil];
}
-(void) PhotoSearch_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"PhotoSearch_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        phototag_filter.hidden = NO;
        photoArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"search_info"] != [NSNull null])
        {
            NSArray *arr = [data objectForKey:@"search_info"];
            for (NSDictionary *s in arr)
            {
                UserObj* obj = [[UserObj alloc] init];
                obj.id = [s objectForKey:@"id"] != [NSNull null] ? [[s objectForKey:@"id"] intValue] : 0;
                obj.userID = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
                obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                obj.profile_pic_url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                [photoArray addObject:obj];
                
                ImageCach *ic = [[ImageCach alloc] init];
                [cache_imagesArray addObject:ic];
            }
            [self removeNotifi];
            [photoListTableView reloadData];
            label_no_result.hidden = YES;
        }else{
            [Common showAlert:@"No photo found"];
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
-(void) PhotoSearch_Fail:(NSNotification*)notif
{
    NSLog(@"PhotoSearch_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

@end
