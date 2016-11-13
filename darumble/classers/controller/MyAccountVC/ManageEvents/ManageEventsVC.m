//
//  ManageEventsVC.m
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ManageEventsVC.h"
#import "ManageEventsCell.h"
#import "UIImageView+AFNetworking.h"
#import "AddMyEventVC.h"
#import "EventDetailsVC.h"
#import "MyAccountVC.h"
#import "ManagePhotosVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface ManageEventsVC ()
{
    __weak IBOutlet UICollectionView *_clView;
    __weak IBOutlet UILabel *_lblNumberPhoto;
    __weak IBOutlet UILabel *_lblTitle;
    CGPoint velocityF;
    CGPoint velocityL;
    NSMutableArray *_arrMain;
    int indexDel;
    BOOL PORTRAIT_ORIENTATION;
    
    int selected_eventID;
    IBOutlet UIButton *btn_add_event;
}
@end

@implementation ManageEventsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"ManageEventsCell" bundle:nil];
    [_clView registerNib:cellNib forCellWithReuseIdentifier:@"ManageEventsCell"];
    [self addGestureRecognizers];
    self.lblNoItem.hidden = YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
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

- (void) viewWillAppear:(BOOL)animated
{
    [self LoadWS];
    if (self.is_add_image != 1 && self.is_add_image != 2)
        self.is_add_image = 0;
    
    if (self.is_add_image == 1)
    {
        _lblTitle.text = @"Add Image To Event";
    }else if (self.is_add_image == 2)
    {
        _lblTitle.text = @"Add Images To Event";
    }
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
    NSLog(@"COUNT %d",_arrMain.count);
    return _arrMain.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ManageEventsCell";
    
    ManageEventsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.btnEdit.tag = indexPath.row;
    [cell.btnEdit addTarget:self action:@selector(clickEdit:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(clickDelete:) forControlEvents:UIControlEventTouchUpInside];
    PhotoObj *obj = [_arrMain objectAtIndex:indexPath.row];
    
    cell.lblWeek.text = obj.dayName;
    cell.lbllocation.text = obj.location;
    cell.lblMonth.text = [NSString stringWithFormat:@"%@ %@", obj.monthNameShort, obj.day];
    cell.lblName.text = obj.event_type;
    cell.lblNameEvent.text = obj.eventName;
    UIImage *holder = [UIImage imageNamed:@"box_video.png"];
    NSURL *url = [NSURL URLWithString:obj.URL];
    
    
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=cell.imgEvent.center;
    [activityView startAnimating];
    [cell.imgEvent addSubview:activityView];
    
    if(url) {
        [cell.imgEvent setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                              placeholderImage:holder
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           cell.imgEvent.contentMode = UIViewContentModeScaleAspectFill;
                                           cell.imgEvent.clipsToBounds = YES;
                                           [activityView setHidden:TRUE];
                                           [activityView removeFromSuperview];
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           cell.imgEvent.image = holder;
                                           [activityView setHidden:TRUE];
                                           [activityView removeFromSuperview];
                                       }];
    }else
    {
        cell.imgEvent.image = holder;
        [activityView setHidden:TRUE];
        [activityView removeFromSuperview];
    }
    
//---For Adding Image to Existing Events---
    if (self.is_add_image == 1 || self.is_add_image == 2)
    {
        cell.btnEdit.hidden = YES;
        cell.btnDelete.hidden = YES;
        btn_add_event.hidden = YES;
    }else
    {
        cell.btnEdit.hidden = NO;
        cell.btnDelete.hidden = NO;
        btn_add_event.hidden = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.is_add_image == 1) //add single image to my event
    {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj = [_arrMain objectAtIndex:indexPath.row];
        selected_eventID = obj.id;
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to add an image to this event?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
        errorAlert.tag = 7000;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
    }else if (self.is_add_image == 2) //add multiple images to my event
    {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj = [_arrMain objectAtIndex:indexPath.row];
        selected_eventID = obj.id;
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to add selected multiple images to this event?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
        errorAlert.tag = 7001;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
    }else
    {        
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.id = ((PhotoObj *)[_arrMain objectAtIndex:indexPath.row]).id;
        obj.uid = ((PhotoObj *)[_arrMain objectAtIndex:indexPath.row]).event_uid;
        obj.URL = ((PhotoObj *)[_arrMain objectAtIndex:indexPath.row]).URL;
        obj.categoryID = ((PhotoObj *)[_arrMain objectAtIndex:indexPath.row]).event_catid;
        
        EventDetailsVC *vc = [[EventDetailsVC alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) clickEdit:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    AddMyEventVC *addVC =[[AddMyEventVC alloc] init];
    addVC.flagOfEvent = 2;
    addVC.photoObj = [_arrMain objectAtIndex:btn.tag];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void) clickDelete:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    indexDel = btn.tag;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Are you sure delete?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    [alert show];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self RemoveEventWS];
        }
    }
}


- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EVENT_GET_success:) name:k_get_event_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EVENT_GET_fail:) name:k_get_event_fail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EVENT_REMOVE_success:) name:k_remove_event_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EVENT_REMOVE_fail:) name:k_remove_event_fail object:nil];
    
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_event_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_event_fail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_event_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_event_fail object:nil];
}

- (void) LoadWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws get_event:APP_TOKEN];
    
}

#pragma mark Garage

-(void) EVENT_GET_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeAllObjects];
        [_clView reloadData];
        _arrMain = [ParseUtil parse_get_event:dic];
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Events", _arrMain.count];
    }else{
       // [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [self setLabelEmpty];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}


-(void) setLabelEmpty
{
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
-(void) EVENT_GET_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (void) RemoveEventWS
{
    [self removeNotifi];
    [self addNotifi];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    PhotoObj *obj = [_arrMain objectAtIndex:indexDel];
    [ws remove_event:APP_TOKEN eventID:[NSString stringWithFormat:@"%d", obj.id]];
}

-(void) EVENT_REMOVE_success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        [_arrMain removeObjectAtIndex:indexDel];
        [_clView reloadData];
        _lblNumberPhoto.text = [NSString stringWithFormat:@"%d Events", _arrMain.count];
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [self setLabelEmpty];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) EVENT_REMOVE_fail:(NSNotification*)notif{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

- (IBAction)doAdd:(id)sender
{
    AddMyEventVC *addVC =[[AddMyEventVC alloc] init];
    addVC.flagOfEvent = 1;
    addVC.photoObj = [PhotoObj alloc];
    addVC.photoObj.id = 0;
    [self.navigationController pushViewController:addVC animated:YES];
}




//---Add Image To Event Asking---
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7000) //add single image to event
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            //self.addedImageID : photoID
            //userID  : userID
            //eventID : selected_eventID
            if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
            {
                //---WS API Call(photo detail)---
                [self removeNotifi2];
                [self addNotifi2];
                
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
                DataCenter *ws = [[DataCenter alloc] init];
                [ws add_eventimage_fromother:APP_TOKEN eventID:selected_eventID photoID:self.addedImageID adderID:[[USER_DEFAULT objectForKey:@"userID"] intValue] creatorid:0];
                
            }
        }
    }else if (alertView.tag == 7001) //add multiple images to event
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            [self uploadMultiImage:selected_eventID];
        }
    }
}


//==============WEBSERVICE(Add Images to Existing Event)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventImageFromOther_Success:) name:k_add_eventimage_fromother_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventImageFromOther_Fail:) name:k_add_eventimage_fromother_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_eventimage_fromother_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_eventimage_fromother_fail object:nil];
}
-(void) addEventImageFromOther_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"addEventImageFromOther_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully Add Image to this Event"];
        
        //---redirecting---
        MyAccountVC *vc = [[MyAccountVC alloc] init];
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) addEventImageFromOther_Fail:(NSNotification*)notif
{
    NSLog(@"addEventImageFromOther_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
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
-(void) uploadMultiImage:(int)eventID
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    if (self.chosenImages.count > 0)
    {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:APP_TOKEN, @"token",
                                    [USER_DEFAULT objectForKey:@"userID"], @"userID",
                                    [NSString stringWithFormat:@"%d", self.chosenImages.count], @"image_cnt",
                                    [NSString stringWithFormat:@"%d", eventID], @"eventID",
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
                 
                 //---redirecting---
                 ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
                 vc.menu_type = 1;
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
    }
}

@end
