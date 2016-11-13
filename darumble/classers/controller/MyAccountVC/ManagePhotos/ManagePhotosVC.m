//
//  ManagePhotosVC.m
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ManagePhotosVC.h"
#import "ManagePhotosCell.h"
#import "AddPhotoVC.h"
#import "UploadPhotoVC.h"
#import "VehiclesVC.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoDetailsVC.h"
#import "darumble-Swift.h"
#import "TabController.h"

#import "VIMNetworking.h"
#import "VIMObjectMapper.h"
#import "VIMPictureCollection.h"
#import "VIMPicture.h"

#import "YTVimeoExtractor.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EditVideoVC.h"



@interface ManagePhotosVC ()<UIAlertViewDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UICollectionView *_clView;
    __weak IBOutlet UILabel *_lblNumberPhoto;
    __weak IBOutlet UILabel *_lblTitle;
    __weak IBOutlet UIButton *_btnAdd;
    CGPoint velocityF;
    CGPoint velocityL;
    NSMutableArray *_arrMain;
    int indexDel;
}
@end

@implementation ManagePhotosVC

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"ManagePhotosCell" bundle:nil];
    [_clView registerNib:cellNib forCellWithReuseIdentifier:@"ManagePhotosCell"];
    _arrMain = [[NSMutableArray alloc] init];
    [self addGestureRecognizers];
    self.lblNoItem.hidden = YES;
 
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    [self LoadWS];
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


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GARAGE_GET_success:) name:k_get_garage_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GARAGE_GET_fail:) name:k_get_garage_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GARAGE_REMOVE_success:) name:k_remove_garage_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GARAGE_REMOVE_fail:) name:k_remove_garage_fail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VEHICLE_GET_success:) name:k_get_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VEHICLE_GET_fail:) name:k_get_vehicle_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VEHICLE_REMOVE_success:) name:k_remove_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VEHICLE_REMOVE_fail:) name:k_remove_vehicle_fail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PHOTO_GET_success:) name:k_get_photo_manage_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PHOTO_GET_fail:) name:k_get_photo_manage_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PHOTO_REMOVE_success:) name:k_remove_photo_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PHOTO_REMOVE_fail:) name:k_remove_photo_fail object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VIDEO_GET_success:) name:k_get_video_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VIDEO_GET_fail:) name:k_get_video_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VIDEO_REMOVE_success:) name:k_remove_video_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VIDEO_REMOVE_fail:) name:k_remove_video_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_garage_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_garage_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_garage_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_garage_fail object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_vehicle_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_vehicle_fail object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_photo_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_photo_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_photo_manage_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_photo_manage_fail object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_video_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_video_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_video_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_video_fail object:nil];
}

- (void) LoadWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    switch (_menu_type) {
        case 1:
        {
            _lblTitle.text = @"Manage Photos";
            [ws get_photo:APP_TOKEN isGallery:0];
        }
            break;
        case 2:
        {
            _lblTitle.text = @"Manage Videos";
            [ws get_video:APP_TOKEN];
        }
            break;
        case 4:
        {
            _lblTitle.text = @"Manage Garage";
            [ws get_garage:APP_TOKEN andFillter:@"" andTypeManager:1];
        }
            break;
        case 5:
        {
            _lblTitle.text = @"Manage Vehicles";
            [ws get_vehicle:APP_TOKEN];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark Garage

-(void) GARAGE_GET_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeAllObjects];
        [_clView reloadData];
        _arrMain = [ParseUtil parse_get_garage:dic];
        [_clView reloadData];
        if (_arrMain.count > 0) {
            //_btnAdd.hidden = YES;
        }
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Garages", _arrMain.count];
        
    }else{
        //[Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) GARAGE_GET_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (void) RemoveGarageWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    PhotoObj *obj = [_arrMain objectAtIndex:indexDel];
    [ws remove_garage:APP_TOKEN garageID:[NSString stringWithFormat:@"%d", obj.id]];
}

-(void) GARAGE_REMOVE_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeObjectAtIndex:indexDel];
        [_clView reloadData];
        if (_arrMain.count == 0) {
            _btnAdd.hidden = NO;
        }
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Garages", _arrMain.count];
       
    }else{
        [Common showAlert:@"Remove Error. Please check network status."];
    }
     [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) GARAGE_REMOVE_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

#pragma mark Vehicle

-(void) VEHICLE_GET_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeAllObjects];
        [_clView reloadData];
        _arrMain = [ParseUtil parse_get_vehicle:dic];
        if (_arrMain.count>=4) {
            //_btnAdd.hidden = YES;
        }
        else
        {
            _btnAdd.hidden = NO;
        }
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Vehicles", _arrMain.count];
        
    }else{
        
    }
     [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) VEHICLE_GET_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (void) RemoveVehicleWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    PhotoObj *obj = [_arrMain objectAtIndex:indexDel];
    [ws remove_vehicle:APP_TOKEN vehicleID:[NSString stringWithFormat:@"%d", obj.id]];
}

-(void) VEHICLE_REMOVE_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeObjectAtIndex:indexDel];
        [_clView reloadData];
        if (_arrMain.count>=4) {
            //_btnAdd.hidden = YES;
        }
        else
        {
            _btnAdd.hidden = NO;
        }
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Vehicles", _arrMain.count];
        
    }else{
        
    }
     [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) VEHICLE_REMOVE_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

#pragma mark Photo

-(void) PHOTO_GET_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeAllObjects];
        [_clView reloadData];
        _arrMain = [ParseUtil parse_get_photo:dic];
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Photos", _arrMain.count];
       
    }else{
        
    }
     [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) PHOTO_GET_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (void) RemovePhotoWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    PhotoObj *obj = [_arrMain objectAtIndex:indexDel];
    [ws remove_photo:APP_TOKEN photoID:[NSString stringWithFormat:@"%d", obj.id]];
}

-(void) PHOTO_REMOVE_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeObjectAtIndex:indexDel];
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Photos", _arrMain.count];
    }else{
        [Common showAlert:[dic objectForKey:@"messages"][1]];
    }
    [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) PHOTO_REMOVE_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

#pragma mark Video

-(void) VIDEO_GET_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeAllObjects];
        [_clView reloadData];
        _arrMain = [ParseUtil parse_get_video:dic];
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Videos", _arrMain.count];
        
    }else{
        
    }
    [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) VIDEO_GET_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (void) RemoveVideoWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    PhotoObj *obj = [_arrMain objectAtIndex:indexDel];
    [ws remove_video:APP_TOKEN videoID:[NSString stringWithFormat:@"%d", obj.id]];
}

-(void) VIDEO_REMOVE_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeObjectAtIndex:indexDel];
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Videos", _arrMain.count];
        
        /*************************************/
        /******* Delete Video From Vimeo *****/
        /*************************************/
        dispatch_async(dispatch_get_main_queue(),^{
            [[VIMSession sharedSession].client deleteVideoWithURI:[NSString stringWithFormat:@"/videos/%@", [d_videoURL substringFromIndex:18]] completionBlock:^(VIMServerResponse * _Nullable response, NSError * _Nullable error) {
                //            [Common showAlert:@"Successfully deleted"];
            }];
        });
    }else{
        [Common showAlert:@"Delete Video Error, Please check network status"];
    }
    [self setEmptyLable];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) VIDEO_REMOVE_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrMain.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ManagePhotosCell";
    
    ManagePhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    PhotoObj *obj = [_arrMain objectAtIndex:indexPath.row];

    cell.btnEdit.tag = indexPath.row;
    [cell.btnEdit addTarget:self action:@selector(clickEdit:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(clickDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *holder = [UIImage imageNamed:@""];
    NSURL *url;
    if (_menu_type==2)
    {
        if([NSURL URLWithString:obj.videoThumbnailURL]) {
            [cell.imgManage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:obj.videoThumbnailURL]]
                                  placeholderImage:holder
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               
                                               cell.imgManage.contentMode = UIViewContentModeScaleAspectFill;
                                               cell.imgManage.clipsToBounds = YES;
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               cell.imgManage.image = holder;
                                           }];
        }else
        {
            cell.imgManage.image = holder;
        }
        
        cell.btnPlayVideo.hidden = NO;
        cell.btnPlayVideo.tag = indexPath.row;
        [cell.btnPlayVideo addTarget:self action:@selector(clickPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        url  = [NSURL URLWithString:obj.URL];
        cell.btnPlayVideo.hidden = YES;
        
        if(url) {
            [cell.imgManage setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                  placeholderImage:holder
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               
                                               cell.imgManage.contentMode = UIViewContentModeScaleAspectFill;
                                               cell.imgManage.clipsToBounds = YES;
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               cell.imgManage.image = holder;
                                           }];
        }else
        {
            cell.imgManage.image = holder;
        }
    }
    
    NSLog(@"URL %@",url);
        
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_menu_type==1)
    {
        PhotoDetailsVC *vc = [[PhotoDetailsVC alloc] init];
        vc.photoObj = [_arrMain objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickAddPhoto:(id)sender {
    switch (_menu_type) {
        case 1:
        {
            UploadPhotoVC *vc = [[UploadPhotoVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            [USER_DEFAULT setValue:@"0" forKey:@"video_eventID"];
            
            SwiftInterface *inter = [[SwiftInterface alloc] init];
            UIViewController* controller = [inter test];
            [self.navigationController pushViewController:controller animated:NO];
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            VehiclesVC *vc = [[VehiclesVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

-(void) setEmptyLable
{
    switch (_menu_type) {
        case 1:
        {
            self.lblNoItem.text =@"You do not currently have any photos";
        }
            break;
        case 2:
        {
            self.lblNoItem.text =@"You do not currently have any videos or some of your videos are being finalized now...";
        }
            break;
        case 4:
        {
            self.lblNoItem.text =@"You do not currently have any garanes";
        }
            break;
      
        case 5:
        {
            self.lblNoItem.text =@"You do not currently have any vehicles";
        }
            break;
        default:
            break;
    }
    
    if (_arrMain.count>0) {
        _clView.hidden = NO;
        self.lblNoItem.hidden = YES;
    }
    else
    {
        _clView.hidden = YES;
        self.lblNoItem.hidden = NO;
    }

}

- (void) clickPlayVideo:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    PhotoObj *obj = [_arrMain objectAtIndex:btn.tag];
    [[YTVimeoExtractor sharedExtractor]fetchVideoWithVimeoURL:obj.URL withReferer:nil completionHandler:^(YTVimeoVideo * _Nullable video, NSError * _Nullable error) {
        
        if (video) {
            //self.titleLabel.text = [NSString stringWithFormat:@"Video Title: %@",video.title];
            //Will get the lowest available quality.
            //NSURL *lowQualityURL = [video lowestQualityStreamURL];
            
            //Will get the highest available quality.
            NSURL *highQualityURL = [video lowestQualityStreamURL];
            MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:highQualityURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
        }else{
            [Common showAlert:@"Video is finalizing"];
        }
    }];
}

- (void) clickEdit:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    PhotoObj *obj = [_arrMain objectAtIndex:btn.tag];
    
    switch (_menu_type) {
        case 1:
        {
            AddPhotoVC *vc = [[AddPhotoVC alloc] init];
            vc.photoObj = obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            EditVideoVC *vc = [[EditVideoVC alloc] init];
            vc.photoObj = obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            VehiclesVC *vc = [[VehiclesVC alloc] init];
            vc.photoObj = [_arrMain objectAtIndex:btn.tag];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}
NSString *d_videoURL;
- (void) clickDelete:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    PhotoObj *obj = [_arrMain objectAtIndex:btn.tag];
    indexDel = btn.tag;
    UIAlertView *alert;
    if (_menu_type==2) {
        d_videoURL = obj.URL;
        alert  = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Are you sure you want to delete your video?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    else if (_menu_type==4) {
        alert  = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Are you sure you want to delete your garage?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    else if(_menu_type==5)
    {
        alert  = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Are you sure you want to delete this vehicle?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }

    alert.tag = 1;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            switch (_menu_type) {
                case 1:
                {
                    [self RemovePhotoWS];
                }
                    break;
                case 2:
                {
                    [self RemoveVideoWS];
                }
                    break;
                case 4:
                {
                    [self RemoveGarageWS];
                }
                    break;
                case 5:
                {
                    [self RemoveVehicleWS];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

- (UIImage*)loadImage:(NSURL *) vidURL{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    
    return [[UIImage alloc] initWithCGImage:imgRef];
}

@end
