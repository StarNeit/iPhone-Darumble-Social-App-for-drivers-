//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventSearchResult : UIViewController{
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property NSString* m_event_name;
@property NSString* m_event_startDate;
@property NSString* m_event_endDate;
@property NSString* m_event_fname;
@property NSString* m_event_lname;
@property NSString* m_event_shop;
@property NSString* m_event_city;
@property NSString* m_event_country;
@property NSString* m_event_zipcode;
@property NSString* m_event_miles;
@property int m_event_type;
@property int is_use_mylocation;

@property int is_add_image;
@property int addedImageID;

@property NSArray *chosenImages;
@end
