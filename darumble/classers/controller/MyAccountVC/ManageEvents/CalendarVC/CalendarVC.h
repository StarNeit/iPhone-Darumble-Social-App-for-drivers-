//
//  AddEventVC.h
//  DaRumble
//
//  Created by Colin on 4/22/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoObj.h"
#import "FSCalendar.h"

@interface CalendarVC : UIViewController
- (IBAction)doMenu:(id)sender;
- (IBAction)doSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleEvent;

@property (weak , nonatomic) FSCalendar *calendar;


@property NSString *strName;
@property UIImage *image;
@property NSString *strAddress;
@property NSString *strState;
@property NSString *strCountry;
@property NSString *strCityZip;
@property NSString *strContactInfo;
@property int is_reucrring;
@property int flyerID;
@property NSString *flyerName;

@property PhotoObj *photoObj;
@property int flagOfEvent;
@end
