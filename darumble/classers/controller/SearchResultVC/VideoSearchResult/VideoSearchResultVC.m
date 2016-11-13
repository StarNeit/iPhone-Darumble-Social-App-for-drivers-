//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "VideoSearchResultVC.h"
#import "RumblerCell.h"
#import "UIImageView+AFNetworking.h"
#import "VideoSearchResultCell.h"
#import "VideoDetailsVC.h"
#import "ImageCach.h"


@interface VideoSearchResultVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UITableView *videoListTableView;
    NSMutableArray *videoArray;
    IBOutlet UITextField *videoTitle_filter;
    NSMutableArray * cache_imagesArray;
    IBOutlet UILabel *label_no_result;
}
@end

@implementation VideoSearchResultVC
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
    videoListTableView.tableFooterView = [[UIView alloc] init];
    videoListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
            //---WS API Call(photo detail)---
            [self removeNotifi];
            [self addNotifi];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws search_video:APP_TOKEN startDate:self.m_startDate endDate:self.m_endDate fname:self.m_fname lname:self.m_lname title:self.m_title description:self.m_description];
        }
    videoTitle_filter.hidden = YES;
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
    return [videoArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 447;
    return 208;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---VideoList---
    NSLog(@"test!");

    static NSString *simpleTableIdentifier = @"VideoSearchResultCell";
    
    VideoSearchResultCell *cell = (VideoSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoSearchResultCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    UserObj *video = [videoArray objectAtIndex:indexPath.row];
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", video.fname, video.lname];
    cell.video_title.text = video.clubName;//this is video title.
    
    
    NSURL *url = [NSURL URLWithString:video.thumbnail];
    
    if (video.thumbnail != NULL && ![video.thumbnail isEqualToString:@""])
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
                VideoSearchResultCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
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
   
    UserObj *video = [videoArray objectAtIndex:indexPath.row];
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj.id = video.id;
    obj.uid = video.userID;
    obj.URL = video.url;
    obj.videoThumbnailURL = video.thumbnail;
    obj.categoryID = 1;
    
    VideoDetailsVC *vc = [[VideoDetailsVC alloc] init];
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
    if (textField == videoTitle_filter)
    {
        [videoTitle_filter resignFirstResponder];
        
        videoTitle_filter.text = [Common trimString:videoTitle_filter.text];
        
        if (videoTitle_filter.text.length == 0)
        {
            return true;
        }
        
        VideoSearchResultVC *vc = [[VideoSearchResultVC alloc] init];
        vc.m_title = videoTitle_filter.text;
        vc.m_startDate = self.m_startDate;
        vc.m_endDate = self.m_endDate;
        vc.m_fname = self.m_fname;
        vc.m_lname = self.m_lname;
        vc.m_description = self.m_description;
        
        [self.navigationController pushViewController:vc animated:NO];
    }
    return true;
}




//==============WEBSERVICE(Photo Search)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoSearch_Success:) name:k_search_video_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoSearch_Fail:) name:k_search_video_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_video_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_video_fail object:nil];
}
-(void) VideoSearch_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"VideoSearch_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        videoTitle_filter.hidden = NO;
        videoArray = [[NSMutableArray alloc] init];
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
                obj.clubName = [s objectForKey:@"video_title"] != [NSNull null] ? [s objectForKey:@"title"] : @"";//title
                obj.url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";//video url
                obj.thumbnail = [s objectForKey:@"thumbnail"] != [NSNull null] ? [s objectForKey:@"thumbnail"] : @"";//thumbnail
                
                [videoArray addObject:obj];
                
                ImageCach *ic = [[ImageCach alloc] init];
                [cache_imagesArray addObject:ic];
            }
            [self removeNotifi];
            [videoListTableView reloadData];
            label_no_result.hidden = YES;
        }else{
            [Common showAlert:@"No video found"];
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
-(void) VideoSearch_Fail:(NSNotification*)notif
{
    NSLog(@"VideoSearch_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

@end
