//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "SearchItemsVC.h"
#import "RumblerSearchResultVC.h"
#import "PhotoSearchResultVC.h"
#import "DatePicker.h"
#import "PickerView.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
#import "VehicleSearchResult.h"
#import "EventSearchResult.h"
#import "VideoSearchResultVC.h"

@interface SearchItemsVC ()<UITextFieldDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    IBOutlet UIButton *btnEvent;
    IBOutlet UIButton *btnVehicle;
    IBOutlet UIButton *btnPhoto;
    IBOutlet UIButton *btnVideo;
    IBOutlet UIButton *btnRumbler;
    
    IBOutlet UIScrollView *eventView;
    IBOutlet UIScrollView *vehicleView;
    IBOutlet UIScrollView *photoView;
    IBOutlet UIScrollView *videoView;
    IBOutlet UIScrollView *rumblerView;
    
    UIScrollView *activeScrollView;
    
    IBOutlet UIButton *toggleLocation;
    IBOutlet UIButton *toggleLocationOnRumbler;
    
    IBOutletCollection(UIScrollView) NSArray *searchViewList;
    
    
    //---Rumbler Search---
    IBOutlet UITextField *tf_username;
    IBOutlet UITextField *tf_firstname;
    IBOutlet UITextField *tf_lastname;
    
    NSString *startDateString;
    NSString *endDateString;
    
    //---Photo Search---
    IBOutlet UITextField *m_photo_startDate;
    IBOutlet UITextField *m_photo_endDate;
    IBOutlet UITextField *m_photo_tag;
    IBOutlet UITextField *m_photo_postby;
    IBOutlet UITextField *m_photo_shop;
    
    //---Video Search---
    IBOutlet UITextField *m_video_tag;//title
    IBOutlet UITextField *m_video_startDate;
    IBOutlet UITextField *m_video_endDate;
    IBOutlet UITextField *m_video_postby;
    IBOutlet UITextField *m_video_description;
    
    //---Vehicle Search---
    IBOutlet UITextField *m_vehicle_make;
    IBOutlet UITextField *m_vehicle_model;
    IBOutlet UITextField *m_vehicle_year;
    IBOutlet UITextField *m_vehicle_to_year;
    IBOutlet UITextField *m_vehicle_type;
    IBOutlet UITextField *m_vehicle_shop;
    
    
    //---Event Search---
    IBOutlet UITextField *m_event_name;
    IBOutlet UITextField *m_event_startDate;
    IBOutlet UITextField *m_event_endDate;
    IBOutlet UITextField *m_event_postby;
    IBOutlet UITextField *m_event_shop;
    IBOutlet UITextField *m_event_city;
    IBOutlet UITextField *m_event_type;
    
    
    IBOutlet UIView *city_zip_view;
    IBOutlet UIView *my_location_view;
    
    NSMutableArray *_arrCountries;
    NSMutableArray *_arrUserlist;
    
    IBOutlet UITextField *m_event_mile_radius;
    IBOutlet UITextField *m_event_zipcode;
    
    
    int flagOfDropbox;
    
}
@property DatePicker *datePicker;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *m_event_country;
@property(nonatomic,retain) PickerView *pickerView;
@end

#define loadNib(nibName) [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0]
@implementation SearchItemsVC

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
    self.title = @"";
    [self addGestureRecognizers];
    
    activeScrollView = eventView;
    
    //---rumbler search---
    toggleLocationOnRumbler.tag = 3500;
    
    //---event search---
    toggleLocation.tag = 3000;
    
    startDateString = @"";
    endDateString = @"";
    flagOfDropbox = 0;
    
    [self->eventView setContentSize:CGSizeMake(self->eventView.frame.size.width,850)];
    [self->vehicleView setContentSize:CGSizeMake(self->vehicleView.frame.size.width,650)];
    [self->photoView setContentSize:CGSizeMake(self->photoView.frame.size.width,650)];
    [self->videoView setContentSize:CGSizeMake(self->videoView.frame.size.width,650)];
    [self->rumblerView setContentSize:CGSizeMake(self->rumblerView.frame.size.width,650)];
    
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap1:)];
    singleTap1.cancelsTouchesInView = NO;
    singleTap1.delegate = self;
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap2:)];
    singleTap2.cancelsTouchesInView = NO;
    singleTap2.delegate = self;
    
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap3:)];
    singleTap3.cancelsTouchesInView = NO;
    singleTap3.delegate = self;
    
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap4:)];
    singleTap4.cancelsTouchesInView = NO;
    singleTap4.delegate = self;
    
    UITapGestureRecognizer *singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap5:)];
    singleTap5.cancelsTouchesInView = NO;
    singleTap5.delegate = self;
    
    [eventView addGestureRecognizer:singleTap1];
    [vehicleView addGestureRecognizer:singleTap2];
    [photoView addGestureRecognizer:singleTap3];
    [videoView addGestureRecognizer:singleTap4];
    [rumblerView addGestureRecognizer:singleTap5];
    
    
    [self loadAllCountry];
    [self loadAllUsers];
    
    AppDelegate *app = [Common appDelegate];
    if (app.isRumbler == 20)
    {
       [self switchSearchItems:4];
        app.isRumbler = 0;
    }
    
    m_event_type.tag = 2;
}


//---Gesture Recognizer---
- (void)singleTap1:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [eventView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)singleTap2:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [vehicleView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)singleTap3:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [photoView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)singleTap4:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [videoView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void)singleTap5:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [rumblerView setContentOffset:CGPointMake(0, 0) animated:YES];
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
            // [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            // }];
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            }];
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





//---UI Controll---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
-(void)switchSearchViews:(int)index{
    for (int i = 0; i < searchViewList.count; i ++){
        if (i == index){
            ((UIScrollView*)searchViewList[i]).hidden = false;
            activeScrollView = ((UIScrollView*)searchViewList[i]);
        }else{
            ((UIScrollView*)searchViewList[i]).hidden = true;
        }
    }
}
- (IBAction)click_photo_startDate:(id)sender {
    self.datePicker =loadNib(@"DatePicker");
    self.datePicker.idx = 1;
}
- (IBAction)click_photo_endDate:(id)sender {
    self.datePicker =loadNib(@"DatePicker");
    self.datePicker.idx = 2;
}
- (IBAction)click_video_startDate:(id)sender {
    self.datePicker =loadNib(@"DatePicker");
    self.datePicker.idx = 3;
}
- (IBAction)click_video_endDate:(id)sender {
    self.datePicker =loadNib(@"DatePicker");
    self.datePicker.idx = 4;
}
- (IBAction)click_event_startDate:(id)sender {
    self.datePicker =loadNib(@"DatePicker");
    self.datePicker.idx = 5;
}
- (IBAction)click_event_endDate:(id)sender {
    self.datePicker =loadNib(@"DatePicker");
    self.datePicker.idx = 6;
}

- (IBAction)clickSelectType:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"import", @"domestic", @"other", nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101)//vehicle type
    {
        if (buttonIndex == 0) {
            m_vehicle_type.text = @"import";
        }else if (buttonIndex == 1) {
            m_vehicle_type.text = @"domestic";
        }else if (buttonIndex == 2) {
            m_vehicle_type.text = @"other";
        }
    }
    if (actionSheet.tag == 102)//event search type
    {
        if (buttonIndex == 0)//upcoming
        {
            m_event_type.text = @"All Events";
            m_event_type.tag = 1;
        }else if (buttonIndex == 1)//all
        {
            m_event_type.text = @"Upcoming Events";
            m_event_type.tag = 2;
        }
    }
}
- (IBAction)clickDatePicker:(id)sender
{
    [self.datePicker setFrame:self.view.frame];
    self.datePicker.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.delegate = self;
    //[self.datePicker.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker.datePicker setDate:[NSDate date]];
    [self.datePicker.subDatePicker setFrame:CGRectMake(0,[[UIScreen mainScreen] bounds].size.height-self.datePicker.subDatePicker.frame.size.height, [[UIScreen mainScreen] bounds].size.width,
                                                       [[UIScreen mainScreen] bounds].size.height / 2)];
    
    [[Common appDelegate].window addSubview:self.datePicker];
}


-(void) removeDateTimePicker
{
    [self.datePicker removeFromSuperview];
    switch (self.datePicker.idx) {
        case 1:
            m_photo_startDate.text = @"";
            break;
        case 2:
            m_photo_endDate.text = @"";
            break;
        case 3:
            m_video_startDate.text = @"";
            break;
        case 4:
            m_video_endDate.text = @"";
            break;
        case 5:
            m_event_startDate.text = @"";
            break;
        case 6:
            m_event_endDate.text = @"";
            break;
        default:
            break;
    }
}

-(void) showDateTimePicker:(NSDate *)date
{
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
     if (self.datePicker.idx == 1){
         m_photo_startDate.text = [formatter stringFromDate:date];
         
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
         startDateString = [formatter stringFromDate:date];
     }
     else if (self.datePicker.idx == 2){
         m_photo_endDate.text = [formatter stringFromDate:date];
         
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
         endDateString = [formatter stringFromDate:date];
     } else if (self.datePicker.idx == 3){
         m_video_startDate.text = [formatter stringFromDate:date];
         
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
         startDateString = [formatter stringFromDate:date];
     }
     else if (self.datePicker.idx == 4){
         m_video_endDate.text = [formatter stringFromDate:date];
         
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
         endDateString = [formatter stringFromDate:date];
     } else if (self.datePicker.idx == 5){
         m_event_startDate.text = [formatter stringFromDate:date];
         
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
         startDateString = [formatter stringFromDate:date];
     }
     else if (self.datePicker.idx == 6){
         m_event_endDate.text = [formatter stringFromDate:date];
         
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
         endDateString = [formatter stringFromDate:date];
     }
    [self.datePicker removeFromSuperview];
}


- (IBAction)doCountry:(id)sender {
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrCountries mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
    flagOfDropbox = 1;
}

- (IBAction)doEventPostBy:(id)sender {
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrUserlist mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
    flagOfDropbox = 2;
}

- (IBAction)doPhotoPostBy:(id)sender {
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrUserlist mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
    flagOfDropbox = 3;
}
- (IBAction)doVideoPostBy:(id)sender {
    self.pickerView =[[[NSBundle mainBundle] loadNibNamed:@"PickerView" owner:self options:nil] objectAtIndex:0];
    [self.pickerView setFrame:self.view.frame];
    self.pickerView.delegate = self;
    self.pickerView.arrPicker = [_arrUserlist mutableCopy];
    [[Common appDelegate].window addSubview:self.pickerView];
    flagOfDropbox = 4;
}

//---Select Country---
-(void) loadAllCountry
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"/get/countries/"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"/get/countries/"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        if ([[response objectForKey:@"code"] integerValue]==200) {
            _arrCountries = [[NSMutableArray alloc] init];
            NSArray *arrs = [[response objectForKey:@"data"] objectForKey:@"countries"];
            [_arrCountries addObject:@"United States"];
            for (NSString *str in arrs) {
                if (![str isEqualToString:@"United States"]) {
                    [_arrCountries addObject:str];
                }
                
            }
            
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_garage: %@", error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}
//---Select PostBy---
-(void) loadAllUsers
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"/get/userlist/"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"/get/userlist/"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        if ([[response objectForKey:@"code"] integerValue]==200) {
            _arrUserlist = [[NSMutableArray alloc] init];
            NSArray *arrs = [[response objectForKey:@"data"] objectForKey:@"userlist"];
            for (NSString *str in arrs) {
                [_arrUserlist addObject:str];
            }
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_garage: %@", error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}
- (void)cancelPicker
{
    [_pickerView removeFromSuperview];
}
- (void)donePickerWithIndex:(int)index
{
    if (flagOfDropbox == 1)
    {
        if (_arrCountries.count>0) {
            self.m_event_country.text = [_arrCountries objectAtIndex:index];
            if ([self.m_event_country.text isEqualToString:@"United States"]) {
                m_event_city.placeholder = @"Zipcode";
                m_event_city.text = nil;
                [m_event_city setKeyboardType:UIKeyboardTypeNumberPad];
            }
            else
            {
                m_event_city.placeholder = @"City";
                m_event_city.text = nil;
                [m_event_city setKeyboardType:UIKeyboardTypeDefault];
            }
        }
    }else if (flagOfDropbox == 2)
    {
        if (_arrUserlist.count>0)
        {
            m_event_postby.text = [_arrUserlist objectAtIndex:index];
        }
    }else if (flagOfDropbox == 3)
    {
        if (_arrUserlist.count>0)
        {
            m_photo_postby.text = [_arrUserlist objectAtIndex:index];
        }
    }else if (flagOfDropbox == 4)
    {
        if (_arrUserlist.count>0)
        {
            m_video_postby.text = [_arrUserlist objectAtIndex:index];
        }
    }
    [_pickerView removeFromSuperview];
}

-(void)switchSearchItems:(int)index{
    [self switchSearchViews:index];
    switch (index) {
        case 0:
            {
                [btnEvent setImage:[UIImage imageNamed:@"icon_search_event_on.png"] forState:UIControlStateNormal];
                [btnVehicle setImage:[UIImage imageNamed:@"icon_search_vehicle.png"] forState:UIControlStateNormal];
                [btnPhoto setImage:[UIImage imageNamed:@"icon_search_photo.png"] forState:UIControlStateNormal];
                [btnVideo setImage:[UIImage imageNamed:@"icon_search_video.png"] forState:UIControlStateNormal];
                [btnRumbler setImage:[UIImage imageNamed:@"icon_search_people.png"] forState:UIControlStateNormal];
            }
            break;
        case 1:
            {
                [btnEvent setImage:[UIImage imageNamed:@"icon_search_event.png"] forState:UIControlStateNormal];
                [btnVehicle setImage:[UIImage imageNamed:@"icon_search_vehicle_on.png"] forState:UIControlStateNormal];
                [btnPhoto setImage:[UIImage imageNamed:@"icon_search_photo.png"] forState:UIControlStateNormal];
                [btnVideo setImage:[UIImage imageNamed:@"icon_search_video.png"] forState:UIControlStateNormal];
                [btnRumbler setImage:[UIImage imageNamed:@"icon_search_people.png"] forState:UIControlStateNormal];
            }
            break;
        case 2:
            {
                [btnEvent setImage:[UIImage imageNamed:@"icon_search_event.png"] forState:UIControlStateNormal];
                [btnVehicle setImage:[UIImage imageNamed:@"icon_search_vehicle.png"] forState:UIControlStateNormal];
                [btnPhoto setImage:[UIImage imageNamed:@"icon_search_photo_on.png"] forState:UIControlStateNormal];
                [btnVideo setImage:[UIImage imageNamed:@"icon_search_video.png"] forState:UIControlStateNormal];
                [btnRumbler setImage:[UIImage imageNamed:@"icon_search_people.png"] forState:UIControlStateNormal];
            }
            break;
        case 3:
            {
                [btnEvent setImage:[UIImage imageNamed:@"icon_search_event.png"] forState:UIControlStateNormal];
                [btnVehicle setImage:[UIImage imageNamed:@"icon_search_vehicle.png"] forState:UIControlStateNormal];
                [btnPhoto setImage:[UIImage imageNamed:@"icon_search_photo.png"] forState:UIControlStateNormal];
                [btnVideo setImage:[UIImage imageNamed:@"icon_search_video_on.png"] forState:UIControlStateNormal];
                [btnRumbler setImage:[UIImage imageNamed:@"icon_search_people.png"] forState:UIControlStateNormal];
            }
            break;
        case 4:
            {
                [btnEvent setImage:[UIImage imageNamed:@"icon_search_event.png"] forState:UIControlStateNormal];
                [btnVehicle setImage:[UIImage imageNamed:@"icon_search_vehicle.png"] forState:UIControlStateNormal];
                [btnPhoto setImage:[UIImage imageNamed:@"icon_search_photo.png"] forState:UIControlStateNormal];
                [btnVideo setImage:[UIImage imageNamed:@"icon_search_video.png"] forState:UIControlStateNormal];
                [btnRumbler setImage:[UIImage imageNamed:@"icon_search_people_on.png"] forState:UIControlStateNormal];
            }
            break;
        default:
            
            break;
    }
}
- (IBAction)clickSearch:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [app initSideMenu];
}
- (IBAction)clickToggleButton:(id)sender {
    if(toggleLocation.tag == 3000){
        [toggleLocation setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleLocation.tag = 3001;
        
        my_location_view.hidden = false;
        city_zip_view.hidden = true;
    }else if (toggleLocation.tag == 3001){
        [toggleLocation setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        toggleLocation.tag = 3000;
        
        my_location_view.hidden = true;
        city_zip_view.hidden = false;
    }
}
- (IBAction)clickToggleButtonOnRumbler:(id)sender {
    if(toggleLocationOnRumbler.tag == 3500){
        [toggleLocationOnRumbler setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleLocationOnRumbler.tag = 3501;
    }else if (toggleLocationOnRumbler.tag == 3501){
        [toggleLocationOnRumbler setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        toggleLocationOnRumbler.tag = 3500;
    }
}

- (IBAction)clickEvnetSearch:(id)sender {
    [self switchSearchItems:0];
}

- (IBAction)clickVehicleSearch:(id)sender {
    [self switchSearchItems:1];
}

- (IBAction)clickPhotoSearch:(id)sender {
    [self switchSearchItems:2];
}

- (IBAction)clickVideoSearch:(id)sender {
    [self switchSearchItems:3];
}

- (IBAction)clickRumblerSearch:(id)sender {
    [self switchSearchItems:4];
}

- (IBAction)goEventSearchResult:(id)sender {
    m_event_name.text = [Common trimString:m_event_name.text];
    m_event_startDate.text = [Common trimString:m_event_startDate.text];
    m_event_endDate.text = [Common trimString:m_event_endDate.text];
    m_event_postby.text = [Common trimString:m_event_postby.text];
    m_event_shop.text = [Common trimString:m_event_shop.text];
    m_event_type.text = [Common trimString:m_event_type.text];
    self.m_event_country.text = [Common trimString:self.m_event_country.text];
    
    if (toggleLocation.tag == 3001) // my location state 'on'
    {
        m_event_zipcode.text = [Common trimString:m_event_zipcode.text];
        m_event_mile_radius.text = [Common trimString:m_event_mile_radius.text];
        
        if (m_event_zipcode.text.length == 0 || m_event_mile_radius.text.length == 0)
        {
            [Common showAlert:@"Zipcode and miles are required"];
            return;
        }        
    }else if (toggleLocation.tag == 3000) // my location state 'off'
    {
        m_event_city.text = [Common trimString:m_event_city.text];
        if (m_event_name.text.length == 0 && m_event_startDate.text.length == 0 && m_event_endDate.text.length == 0 && m_event_postby.text.length == 0 && m_event_shop.text.length == 0 && self.m_event_country.text.length == 0 && m_event_city.text.length == 0 && m_event_type.text.length == 0)
        {
            [Common showAlert:@"Please enter some fields"];
            return;
        }
    }
    
    EventSearchResult *vc = [[EventSearchResult alloc] init];
    vc.m_event_name = m_event_name.text;
    vc.m_event_startDate = m_event_startDate.text;
    vc.m_event_endDate = m_event_endDate.text;
    
    NSString *space = @" " ;
    NSRange range = [m_event_postby.text rangeOfString: space options: NSCaseInsensitiveSearch];
    NSLog(@"found: %@", (range.location != NSNotFound) ? @"Yes" : @"No");
    if (range.location != NSNotFound) {
        NSRange rng = [m_event_postby.text rangeOfString:@" "];
        vc.m_event_fname = [m_event_postby.text substringToIndex:rng.location];
        vc.m_event_lname = [m_event_postby.text substringFromIndex:rng.location + 1];
    }else{
        vc.m_event_fname = m_event_postby.text;
        vc.m_event_lname = @"";
    }
    
    vc.m_event_shop = m_event_shop.text;
    vc.m_event_country = self.m_event_country.text;
    
    vc.m_event_zipcode = m_event_zipcode.text;
    vc.m_event_miles = m_event_mile_radius.text;
    vc.m_event_city = m_event_city.text;
    
    vc.m_event_type = m_event_type.tag;
    
    vc.is_use_mylocation = toggleLocation.tag == 3001 ? 1 : 0;
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)goVehicleSearchResult:(id)sender {
    m_vehicle_make.text = [Common trimString:m_vehicle_make.text];
    m_vehicle_model.text = [Common trimString:m_vehicle_model.text];
    m_vehicle_year.text = [Common trimString:m_vehicle_year.text];
    m_vehicle_to_year.text = [Common trimString:m_vehicle_to_year.text];
    m_vehicle_type.text = [Common trimString:m_vehicle_type.text];
    m_vehicle_shop.text = [Common trimString:m_vehicle_shop.text];
    
    if (m_vehicle_make.text.length == 0 && m_vehicle_model.text.length == 0 &&
        m_vehicle_type.text.length == 0 && m_vehicle_year.text.length == 0 &&
        m_vehicle_to_year.text.length == 0 && m_vehicle_shop.text.length == 0)
    {
        [Common showAlert:@"Please enter some fields"];
        return;
    }
   
    VehicleSearchResult *vc = [[VehicleSearchResult alloc] init];
    vc.m_type = m_vehicle_type.text;
    vc.m_make = m_vehicle_make.text;
    vc.m_year = m_vehicle_year.text;
    vc.m_toyear = m_vehicle_to_year.text;
    vc.m_model = m_vehicle_model.text;
    vc.m_shop = m_vehicle_shop.text;
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)goPhotoSearchResult:(id)sender {
    m_photo_tag.text = [Common trimString:m_photo_tag.text];
    m_photo_postby.text = [Common trimString:m_photo_postby.text];
    m_photo_shop.text = [Common trimString:m_photo_shop.text];
    
    if (m_photo_tag.text.length == 0 && m_photo_startDate.text.length == 0 && m_photo_endDate.text.length == 0
        && m_photo_postby.text.length == 0 && m_photo_shop.text.length == 0)
    {
        [Common showAlert:@"Please enter some fields"];
        return;
    }
    
    PhotoSearchResultVC *vc = [[PhotoSearchResultVC alloc] init];
    vc.m_tags = m_photo_tag.text;
    vc.m_startDate = ![m_photo_startDate.text isEqualToString:@""] ? startDateString : @"";
    vc.m_endDate = ![m_photo_endDate.text isEqualToString:@""] ? endDateString : @"";
    vc.m_shop = m_photo_shop.text;
    
    NSString *space = @" " ;
    NSRange range = [m_photo_postby.text rangeOfString: space options: NSCaseInsensitiveSearch];
    NSLog(@"found: %@", (range.location != NSNotFound) ? @"Yes" : @"No");
    if (range.location != NSNotFound) {
        NSRange rng = [m_photo_postby.text rangeOfString:@" "];
        vc.m_fname = [m_photo_postby.text substringToIndex:rng.location];
        vc.m_lname = [m_photo_postby.text substringFromIndex:rng.location + 1];
    }else{
        vc.m_fname = m_photo_postby.text;
        vc.m_lname = @"";
    }
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)goVideoSearchResult:(id)sender {
    m_video_tag.text = [Common trimString:m_video_tag.text];//title
    m_video_postby.text = [Common trimString:m_video_postby.text];
    m_video_description.text = [Common trimString:m_video_description.text];
    
    if (m_video_tag.text.length == 0 && m_video_startDate.text.length == 0 && m_video_endDate.text.length == 0 && m_video_postby.text.length == 0 && m_video_description.text.length == 0)
    {
        [Common showAlert:@"Please enter some fields"];
        return;
    }
    
    
    VideoSearchResultVC *vc = [[VideoSearchResultVC alloc] init];
    vc.m_title = m_video_tag.text;
    vc.m_startDate = ![m_video_startDate.text isEqualToString:@""] ? startDateString : @"";
    vc.m_endDate = ![m_video_endDate.text isEqualToString:@""] ? endDateString : @"";
    vc.m_description = m_video_description.text;
    
    NSString *space = @" " ;
    NSRange range = [m_video_postby.text rangeOfString: space options: NSCaseInsensitiveSearch];
    NSLog(@"found: %@", (range.location != NSNotFound) ? @"Yes" : @"No");
    if (range.location != NSNotFound) {
        NSRange rng = [m_video_postby.text rangeOfString:@" "];
        vc.m_fname = [m_video_postby.text substringToIndex:rng.location];
        vc.m_lname = [m_video_postby.text substringFromIndex:rng.location + 1];
    }else{
        vc.m_fname = m_video_postby.text;
        vc.m_lname = @"";
    }
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)goRumblerSearchResult:(id)sender {
    tf_firstname.text = [Common trimString:tf_firstname.text];
    tf_lastname.text = [Common trimString:tf_lastname.text];
    tf_username.text = [Common trimString:tf_username.text];
    
    if (tf_username.text.length == 0
        && tf_firstname.text.length == 0 && tf_lastname.text.length == 0)
    {
        [Common showAlert:@"Please enter some fields"];
        return;
    }
    
    RumblerSearchResultVC *vc = [[RumblerSearchResultVC alloc] init];
    vc.username = tf_username.text;
    vc.firstname = tf_firstname.text;
    vc.lastname = tf_lastname.text;
    [self.navigationController pushViewController:vc animated:NO];
}



#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    //---events---
    if (textField== m_event_shop) {
        [activeScrollView setContentOffset:CGPointMake(0,50) animated:YES];
    }else if (textField == m_event_city || textField == m_event_mile_radius){
        [activeScrollView setContentOffset:CGPointMake(0,150) animated:YES];
    }else if (textField == m_event_zipcode){
        [activeScrollView setContentOffset:CGPointMake(0,250) animated:YES];
    }
    
    //---vehicle---
    else if (textField == m_vehicle_year || textField == m_vehicle_to_year){
        [activeScrollView setContentOffset:CGPointMake(0,50) animated:YES];
    }else if (textField == m_vehicle_shop)
    {
        [activeScrollView setContentOffset:CGPointMake(0,100) animated:YES];
    }
    
    //---video---
    else if (textField == m_video_description)
    {
        [activeScrollView setContentOffset:CGPointMake(0,100) animated:YES];
    }
    
    //---photo---
    else if (textField == m_photo_shop)
    {
        [activeScrollView setContentOffset:CGPointMake(0,100) animated:YES];
    }
    
    //---video---
    else if (textField == m_video_description)
    {
        [activeScrollView setContentOffset:CGPointMake(0,100) animated:YES];
    }
    
    //---Rumbler---
    else if (textField == tf_username)
    {
        [activeScrollView setContentOffset:CGPointMake(0,50) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //---events---
    if (textField == m_event_name)
    {
        [m_event_shop becomeFirstResponder];
    }else if (textField == m_event_shop)
    {
        [m_event_city becomeFirstResponder];
    }else if (textField == m_event_city)
    {
        [m_event_city resignFirstResponder];
        [activeScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    //---vehicle---
    else if (textField == m_vehicle_make)
    {
        [m_vehicle_model becomeFirstResponder];
    }else if (textField == m_vehicle_model)
    {
        [m_vehicle_year becomeFirstResponder];
    }else if (textField == m_vehicle_year)
    {
        [m_vehicle_to_year becomeFirstResponder];
    }else if (textField == m_vehicle_to_year){
        [m_vehicle_shop becomeFirstResponder];
    }else if (textField == m_vehicle_shop){
        [m_vehicle_shop resignFirstResponder];
        [activeScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    //---photo---
    else if (textField == m_photo_tag){
        [m_photo_shop becomeFirstResponder];
    }else if (textField == m_photo_shop){
        [m_photo_shop resignFirstResponder];
        [activeScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    //---video---
    else if (textField == m_video_tag){
        [m_video_description becomeFirstResponder];
    }else if (textField == m_video_description){
        [m_video_description resignFirstResponder];
        [activeScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    //---Rumbler---
    else if (textField == tf_firstname){
        [tf_lastname becomeFirstResponder];
    }else if (textField == tf_lastname){
        [tf_username becomeFirstResponder];
    }else if (textField == tf_username){
        [tf_username resignFirstResponder];
        [activeScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    return YES;
}

- (IBAction)clickSearchType:(id)sender {
    
    //---upcoming/all events---
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Search Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"All Events",@"Upcoming Events",  nil];
    actionSheet.tag = 102;
    [actionSheet showInView:self.view];
}


@end
