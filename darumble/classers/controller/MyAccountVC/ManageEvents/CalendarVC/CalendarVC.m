//
//  AddEventVC.m
//  DaRumble
//
//  Created by Colin on 4/22/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "CalendarVC.h"
#import "IQActionSheetPickerView.h"
#import "DatePicker.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"
#import "UploadFlyerVC.h"
#import "AddMyEventVC.h"

#define loadNib(nibName) [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0]
@interface CalendarVC ()<UIGestureRecognizerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate,IQActionSheetPickerViewDelegate,DatePickerDelegate>
{
    
    __weak IBOutlet UIScrollView *scrollPage;
    //__weak IBOutlet UITextField *txfEventType;
    
    NSMutableArray *arrType;
    UIImage *imageChoosePicker;
    NSString *photoID;
    CGPoint velocityF;
    CGPoint velocityL;
    BOOL PORTRAIT_ORIENTATION;
    NSTimer *timer;
    __weak IBOutlet UIView *_calendarView;
    
    __weak IBOutlet FSCalendar *calendar_view;
    __weak IBOutlet UIButton *toggleButton;
    __weak IBOutlet UIView *recurringView;
    __weak IBOutlet UIView *unrecurringView;
    __weak IBOutlet UIImageView *boxbackground;
    
    
    
    __weak IBOutlet UITextField *text_every_value;
    __weak IBOutlet UITextField *text_end_period;
    __weak IBOutlet UITextField *text_start_time;
    
    __weak IBOutlet UITextField *text_every_value_type;
    __weak IBOutlet UITextField *text_end_period_type;
    __weak IBOutlet UITextField *text_start_time_type;
    __weak IBOutlet UITextField *text_event_type;
    
    NSMutableArray *arrDay;
}
@property(nonatomic,retain) DatePicker *datePicker;
- (IBAction)doEventType:(id)sender;
- (IBAction)doAdd:(id)sender;
@end

@implementation CalendarVC
- (void)viewDidLoad {
    if (!IS_IPAD) {
         _calendarView.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 800);
        [scrollPage setContentSize:CGSizeMake(scrollPage.frame.size.width,800)];
    }else{
        [scrollPage setContentSize:CGSizeMake(scrollPage.frame.size.width,1600)];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [scrollPage addGestureRecognizer:singleTap];
    [super viewDidLoad];
    
     [self addGestureRecognizers];
    
    
    toggleButton.tag = 3000;
    
    arrType = [[NSMutableArray alloc] initWithObjects:@"car show", @"bike show", @"race",@"off road",@"swap meet",@"rally",@"seminar",@"class",@"workshop",@"ride",@"course", nil];
    
    arrDay = [[NSMutableArray alloc] initWithObjects:@"Sun", @"Mon", @"Tue",@"Wed",@"Thu",@"Fri",@"Sat", nil];
    
    
    if (self.is_reucrring == 1)
    {
        [toggleButton setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleButton.tag = 3001;
        recurringView.hidden = NO;
        unrecurringView.hidden = YES;
        if (!IS_IPAD){
            [boxbackground setFrame:CGRectMake(boxbackground.frame.origin.x,
                                               boxbackground.frame.origin.y,boxbackground.frame.size.width,585)];
        }
    }
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    //[scrollPage setContentOffset:CGPointMake(0, 0) animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}
- (IBAction)doMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
- (IBAction)doSearch:(id)sender {
    //---sending recurring info-----
    AddMyEventVC *vc = [[AddMyEventVC alloc] init];
    vc.strName = self.strName;
    vc.image = self.image;
    vc.strAddress = self.strAddress;
    vc.strState = self.strState;
    vc.strCountry = self.strCountry;
    vc.strCityZip = self.strCityZip;
    vc.strContactInfo = self.strContactInfo;
    vc.flyerID = self.flyerID;
    vc.flyerName = self.flyerName;
    vc.photoObj = self.photoObj;
    vc.flagOfEvent = self.flagOfEvent;
    vc.is_redirecting_calendar = 1;
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}

- (IBAction)clickToggleButton:(id)sender {
    if(toggleButton.tag == 3000){
        [toggleButton setImage:[UIImage imageNamed:@"btn_toggle_on.png"] forState:UIControlStateNormal];
        toggleButton.tag = 3001;
        recurringView.hidden = NO;
        unrecurringView.hidden = YES;
        if (!IS_IPAD){
            [boxbackground setFrame:CGRectMake(boxbackground.frame.origin.x,
                                         boxbackground.frame.origin.y,boxbackground.frame.size.width,585)];
        }
    }else if (toggleButton.tag == 3001){
        [toggleButton setImage:[UIImage imageNamed:@"btn_toggle.png"] forState:UIControlStateNormal];
        toggleButton.tag = 3000;
        recurringView.hidden = YES;
        unrecurringView.hidden = NO;
        if (!IS_IPAD){
            [boxbackground setFrame:CGRectMake(boxbackground.frame.origin.x,
                                               boxbackground.frame.origin.y,boxbackground.frame.size.width,390)];
        }
    }
}

- (IBAction)addEveryValue:(id)sender {
    text_every_value.text = [NSString stringWithFormat:@"%d", ([text_every_value.text intValue] % 5) + 1];
}
- (IBAction)subEveryValue:(id)sender {
    if (([text_every_value.text intValue] % 5) > 1)
        text_every_value.text = [NSString stringWithFormat:@"%d", [text_every_value.text intValue] % 5 - 1];
}

- (IBAction)addEndPeriod:(id)sender {
    text_end_period.text = [NSString stringWithFormat:@"%d", [text_end_period.text intValue] + 1];
}
- (IBAction)subEndPeriod:(id)sender {
    if ([text_end_period.text intValue] > 1)
        text_end_period.text = [NSString stringWithFormat:@"%d", [text_end_period.text intValue] - 1];
}

- (IBAction)addStartTime:(id)sender {
    text_start_time.text = [NSString stringWithFormat:@"%d", ([text_start_time.text intValue] % 12) + 1];
}
- (IBAction)subStartTime:(id)sender {
    if (([text_start_time.text intValue] % 12) > 1)
        text_start_time.text = [NSString stringWithFormat:@"%d", [text_start_time.text intValue] % 12 - 1];
}

- (IBAction)clickEveryValueType:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Day"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Satday", nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
}
- (IBAction)clickEndPeriodType:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Recurring Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Year", @"Month", nil];
    actionSheet.tag = 102;
    [actionSheet showInView:self.view];
}
- (IBAction)clickNoon:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Noon"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"AM", @"PM", nil];
    actionSheet.tag = 103;
    [actionSheet showInView:self.view];
}
- (IBAction)clickEventType:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"car show", @"bike show", @"race",@"off road",@"swap meet",@"rally",@"seminar",@"class",@"workshop",@"ride",@"course", nil];
    actionSheet.tag = 104;
    [actionSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101)
    {
        text_every_value_type.text = [arrDay objectAtIndex:buttonIndex];
    }else if (actionSheet.tag == 102)
    {
        switch (buttonIndex) {
            case 0:
                text_end_period_type.text = @"Year";
                break;
            case 1:
                text_end_period_type.text = @"Month";
                break;
            default:
                break;
        }
    }else if (actionSheet.tag == 103)
    {
        switch (buttonIndex) {
            case 0:
                text_start_time_type.text = @"AM";
                break;
            case 1:
                text_start_time_type.text = @"PM";
                break;
            default:
                break;
        }
    }else if (actionSheet.tag == 104)
    {
        if (buttonIndex<11) {
            text_event_type.text = [arrType objectAtIndex:buttonIndex];
        }
    }
}


- (IBAction)clickRecurringDone:(id)sender
{
//---Event Start Time---
    NSDate *selected_date_temp = calendar_view.selectedDate;
    if (selected_date_temp == nil)
    {
        selected_date_temp = [NSDate date];
    }
    
    NSString *eventType = @"";
    int event_recurring_value = 0, event_end_recurring_value = 0;
    NSString *event_recurring_value_type = @"", *event_end_recurring_value_type = @"";
    int hour = 0;
    
    if (toggleButton.tag == 3001)
    {
        eventType = text_event_type.text;
        event_recurring_value = [text_every_value.text intValue];
        event_recurring_value_type = text_every_value_type.text;
        
        //----
        if ([text_every_value_type.text isEqualToString:@"Sun"])
        {
            event_recurring_value_type = @"Sunday";
        }else if ([text_every_value_type.text isEqualToString:@"Mon"])
        {
            event_recurring_value_type = @"Monday";
                
        }else if ([text_every_value_type.text isEqualToString:@"Tue"])
        {
            event_recurring_value_type = @"Tuesday";
        }else if ([text_every_value_type.text isEqualToString:@"Wed"])
        {
            event_recurring_value_type = @"Wednesday";
        }else if ([text_every_value_type.text isEqualToString:@"Thu"])
        {
            event_recurring_value_type = @"Thursday";
        }else if ([text_every_value_type.text isEqualToString:@"Fri"])
        {
            event_recurring_value_type = @"Friday";
        }else if ([text_every_value_type.text isEqualToString:@"Sat"])
        {
            event_recurring_value_type = @"Saturday";
        }
        
        event_end_recurring_value = [text_end_period.text intValue];
        event_end_recurring_value_type = text_end_period_type.text;
    }
    
    hour = [text_start_time.text intValue];
    if ([text_start_time_type.text isEqualToString:@"PM"])
    {
        hour += 12;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: selected_date_temp];
    [components setHour: hour];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *selected_date = [gregorian dateFromComponents: components];
    
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startDateString = [formatter stringFromDate:selected_date];
    
//---sending recurring info-----
    AddMyEventVC *vc = [[AddMyEventVC alloc] init];
    vc.strName = self.strName;
    vc.image = self.image;
    vc.strAddress = self.strAddress;
    vc.strState = self.strState;
    vc.strCountry = self.strCountry;
    vc.strCityZip = self.strCityZip;
    vc.strContactInfo = self.strContactInfo;
    vc.flyerID = self.flyerID;
    vc.flyerName = self.flyerName;
    vc.photoObj = self.photoObj;
    vc.flagOfEvent = self.flagOfEvent;
    
    vc.is_reucrring = toggleButton.tag == 3000 ? 0 : 1;
    vc.is_redirecting_calendar = 1;
    
    vc.eventType = eventType;
    vc.event_recurring_value = event_recurring_value;
    vc.event_recurring_value_type = event_recurring_value_type;
    vc.event_recurring_end_period = event_end_recurring_value;
    vc.event_recurring_end_period_type = event_end_recurring_value_type;
    vc.event_startDate = startDateString;
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
    [activeViewControllers removeLastObject];
    
    // Reset the navigation stack
    [navigationController setViewControllers:activeViewControllers];
    [navigationController pushViewController:vc animated:NO];
}
@end
