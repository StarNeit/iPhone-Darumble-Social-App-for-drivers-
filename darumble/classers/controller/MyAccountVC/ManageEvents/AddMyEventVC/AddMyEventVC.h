//
//  AddEventVC.h
//  DaRumble
//
//  Created by Colin on 4/22/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoObj.h"
#import "UploadFlyerVC.h"

@interface AddMyEventVC : UIViewController <UploadFlyerVCDelegate>
- (IBAction)doPhoto:(id)sender;
- (IBAction)doMenu:(id)sender;
- (IBAction)doSearch:(id)sender;
- (IBAction)doSelectDate:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectDate;
@property(nonatomic,retain) PhotoObj *photoObj;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnEventType;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectPhoto;
@property(nonatomic,assign) BOOL isDetailEvent;

@property NSString *strName;
@property UIImage *image;
@property NSString *strAddress;
@property NSString *strState;
@property NSString *strCountry;
@property NSString *strCityZip;
@property NSString *strContactInfo;
@property int flyerID;
@property NSString *flyerName;
@property int is_reucrring;

@property int is_redirecting_calendar;

@property NSString *event_startDate;
@property NSString *eventType;
@property int event_recurring_value;
@property int event_recurring_end_period;
@property NSString *event_recurring_value_type;
@property NSString *event_recurring_end_period_type;

@property int flagOfEvent;

@end
