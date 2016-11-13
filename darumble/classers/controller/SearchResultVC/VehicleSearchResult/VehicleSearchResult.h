//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleSearchResult : UIViewController{
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property NSString* m_make;
@property NSString* m_model;
@property NSString* m_year;
@property NSString* m_toyear;
@property NSString* m_type;
@property NSString* m_shop;

@end
