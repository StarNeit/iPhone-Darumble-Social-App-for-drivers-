//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "EventSearchResult.h"
#import "UIImageView+AFNetworking.h"
#import "EventSearchResultCell.h"
#import "EventObj.h"
#import "EventDetailsVC.h"
#import "MyAccountVC.h"
#import "ManagePhotosVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "ImageCach.h"

@interface EventSearchResult ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UITableView *eventListTableView;
    NSMutableArray *eventArray;
    NSMutableArray * cache_imagesArray;
    IBOutlet UILabel *label_no_result;
    
    IBOutlet UITextField *eventname_filter;
    int selected_eventID;
    int selected_eventCreator;
}
@end

@implementation EventSearchResult
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
        //---WS API Call(event search result)---
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        
        if (self.is_use_mylocation == 1)
        {
            [ws search_event:APP_TOKEN eventName:self.m_event_name isMyLocation:1 startDate:self.m_event_startDate endDate:self.m_event_endDate fName:self.m_event_fname lName:self.m_event_lname country:self.m_event_country city:@"" zip:self.m_event_zipcode miles:self.m_event_miles type:self.m_event_type];
        }else {
            
            if ([self.m_event_country isEqualToString:@"United States"])
            {
                [ws search_event:APP_TOKEN eventName:self.m_event_name isMyLocation:0 startDate:self.m_event_startDate endDate:self.m_event_endDate fName:self.m_event_fname lName:self.m_event_lname country:self.m_event_country city:@"" zip:self.m_event_city miles:@"" type:self.m_event_type];
            }else{
                [ws search_event:APP_TOKEN eventName:self.m_event_name isMyLocation:0 startDate:self.m_event_startDate endDate:self.m_event_endDate fName:self.m_event_fname lName:self.m_event_lname country:self.m_event_country city:self.m_event_city zip:@"" miles:@"" type:self.m_event_type];
            }
        }
    }
    if (self.is_add_image != 1 && self.is_add_image != 2)
        self.is_add_image = 0;
    
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"Events";
    [self addGestureRecognizers];
    
//    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,1100)];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self._srcMain addGestureRecognizer:singleTap];
    
    
    eventListTableView.tableFooterView = [[UIView alloc] init];
    
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
    eventname_filter.hidden = YES;
    
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
    return [eventArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 524;
    return 258;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//---EventList---

    static NSString *simpleTableIdentifier = @"EventSearchResultCell";
    
    EventSearchResultCell *cell = (EventSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EventSearchResultCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    

    EventObj *event = [eventArray objectAtIndex:indexPath.row];
    
    cell.eventname.text = event.eventName;
    cell.eventlocation.text = event.eventLocation;
    cell.eventdate.text = event.start_date;
    
    NSDate *date = [Common convertStringToDate:event.start_date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"MMMM dd, yyyy hh:mm a"];
    NSString *dateDisplay = [dateFormat stringFromDate:date];
    cell.eventdate.text = dateDisplay;
    
    
    
    cell.eventadder.text = [NSString stringWithFormat:@"%@ %@", event.fname, event.lname];
    
    NSURL *url = [NSURL URLWithString: event.url];
    
    if (event.url != NULL && ![event.url isEqualToString:@""])
    {
        //---Event Image---
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
                EventSearchResultCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
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
    
    EventObj *event = [eventArray objectAtIndex:indexPath.row];
    
    if (self.is_add_image == 1) //add single image to other event
    {
        selected_eventID = event.eventID;
        selected_eventCreator = event.eventCreator;
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to add an image to this event?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
        errorAlert.tag = 7001;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
    }else if (self.is_add_image == 2) //add multiple images to other event
    {
        selected_eventID = event.eventID;
        selected_eventCreator = event.eventCreator;
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to add multiple images to this event?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
        errorAlert.tag = 7002;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
    }else
    {
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.id = event.eventID;
        obj.uid = event.eventCreator;
        obj.URL = event.url;
        obj.categoryID = 5;
        
        EventDetailsVC *vc = [[EventDetailsVC alloc] init];
        vc.photoObj = [[PhotoObj alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:NO];
    }
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == eventname_filter)
    {
        [eventname_filter resignFirstResponder];

        eventname_filter.text = [Common trimString:eventname_filter.text];
        
        if (eventname_filter.text.length == 0)
        {
            return true;
        }
        
        EventSearchResult *vc = [[EventSearchResult alloc] init];
        vc.m_event_name = eventname_filter.text;
        vc.m_event_startDate = self.m_event_startDate;
        vc.m_event_endDate = self.m_event_endDate;
        vc.m_event_fname = self.m_event_fname;
        vc.m_event_lname = self.m_event_lname;
        vc.m_event_shop = self.m_event_shop;
        vc.m_event_city = self.m_event_city;
        vc.m_event_country = self.m_event_country;
        vc.m_event_zipcode = self.m_event_zipcode;
        vc.m_event_miles = self.m_event_miles;
        vc.m_event_type = self.m_event_type;
        vc.is_use_mylocation = self.is_use_mylocation;
        
        vc.is_add_image = self.is_add_image;
        vc.addedImageID = self.addedImageID;
        
        vc.chosenImages = self.chosenImages;
        
        [self.navigationController pushViewController:vc animated:NO];
    }
    return true;
}


//==============WEBSERVICE(Event Search)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EventSearch_Success:) name:k_search_event_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EventSearch_Fail:) name:k_search_vehicle_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_vehicle_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_search_vehicle_fail object:nil];
}
-(void) EventSearch_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"EventSearch_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        eventname_filter.hidden = NO;
        eventArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
        int isMyLocation = [data objectForKey:@"isMyLocation"] != [NSNull null] ? [[data objectForKey:@"isMyLocation"] intValue] : 0;
        if (isMyLocation == 1)
        {
            if ([data objectForKey:@"search_info"] != [NSNull null])
            {
                NSArray *arr = [data objectForKey:@"search_info"];
                for (NSDictionary *s in arr)
                {
                    EventObj* obj = [[EventObj alloc] init];
                    
                    obj.eventID = [s objectForKey:@"eventID"] != [NSNull null] ? [[s objectForKey:@"eventID"] intValue] : 0;
                    obj.eventName = [s objectForKey:@"eventName"] != [NSNull null] ? [s objectForKey:@"eventName"] : @"";
                    obj.eventLocation = [s objectForKey:@"eventLocation"] != [NSNull null] ? [s objectForKey:@"eventLocation"] : @"";
                    obj.start_date = [s objectForKey:@"start_date"] != [NSNull null] ? [s objectForKey:@"start_date"] : @"";
                    obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                    obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                    obj.url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                    obj.eventCreator = [s objectForKey:@"eventCreator"] != [NSNull null] ? [[s objectForKey:@"eventCreator"] intValue] : 0;
                    
                    [eventArray addObject:obj];
                }
                [self removeNotifi];
                [eventListTableView reloadData];
                label_no_result.hidden = YES;
            }else{
                [Common showAlert:@"No event found"];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self removeNotifi];
                
                label_no_result.hidden = NO;
                return;
            }
        }else if (isMyLocation == 2)
        {
            if ([data objectForKey:@"search_info"] != [NSNull null])
            {
                NSArray *arr = [data objectForKey:@"search_info"];
                for (NSString *key in arr)
                {
                        NSDictionary *s = [[data objectForKey:@"search_info"] objectForKey:key];
                        EventObj* obj = [[EventObj alloc] init];
                        
                        obj.eventID = [s objectForKey:@"eventID"] != [NSNull null] ? [[s objectForKey:@"eventID"] intValue] : 0;
                        obj.eventName = [s objectForKey:@"eventName"] != [NSNull null] ? [s objectForKey:@"eventName"] : @"";
                        obj.eventLocation = [s objectForKey:@"eventLocation"] != [NSNull null] ? [s objectForKey:@"eventLocation"] : @"";
                        obj.start_date = [s objectForKey:@"start_date"] != [NSNull null] ? [s objectForKey:@"start_date"] : @"";
                        obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                        obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                        obj.url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
                        obj.eventCreator = [s objectForKey:@"eventCreator"] != [NSNull null] ? [[s objectForKey:@"eventCreator"] intValue] : 0;
                    
                        [eventArray addObject:obj];
                }
                [self removeNotifi];
                [eventListTableView reloadData];
                label_no_result.hidden = YES;
            }else{
                [Common showAlert:@"No event found"];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self removeNotifi];
                
                label_no_result.hidden = NO;
                return;
            }
        }
        
        //---sort event search result---
        for (int i = 0; i < [eventArray count] - 1; i ++)
        {
            /*
            for (int j = i + 1; j < [eventArray count]; j ++)
            {
                NSDate *date1 = [Common convertStringToDate:((EventObj*)eventArray[i]).start_date];
                NSDate *date2 = [Common convertStringToDate:((EventObj*)eventArray[j]).start_date];
                
                if ([Common CompareDateWithDate:date1 :date2] == YES)
                {
                    EventObj *temp = [[EventObj alloc] init];
                    temp = eventArray[i];
                    eventArray[i] = eventArray[j];
                    eventArray[j] = temp;
                }
                
            }*/
            ImageCach *ic = [[ImageCach alloc] init];
            [cache_imagesArray addObject:ic];
        }
        ImageCach *ic = [[ImageCach alloc] init];
        [cache_imagesArray addObject:ic];
        
        
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
        label_no_result.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
    
    //[self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,[eventArray count] * 258 + 60)];
}
-(void) EventSearch_Fail:(NSNotification*)notif
{
    NSLog(@"VehcileSearch_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}







//---Add Image To Event Asking---
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7001)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            //self.addedImageID : photoID
            //userID  : userID
            //eventID : selected_eventID
            if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
                //---WS API Call(photo detail)---
                [self removeNotifi2];
                [self addNotifi2];
                
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
                DataCenter *ws = [[DataCenter alloc] init];
                [ws add_eventimage_fromother:APP_TOKEN eventID:selected_eventID photoID:self.addedImageID adderID:[[USER_DEFAULT objectForKey:@"userID"] intValue] creatorid:selected_eventCreator];
                
            }
        }
    }else if (alertView.tag == 7002)
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
        [Common showAlert:@"Successfully Added Image to this Event"];
        
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
                                    [NSString stringWithFormat:@"%d", selected_eventCreator], @"creatorid",
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
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}

@end
