//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoSearchResultVC : UIViewController{
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property NSString* m_title;
@property NSString* m_startDate;
@property NSString* m_endDate;
@property NSString* m_fname;
@property NSString* m_lname;
@property NSString* m_description;
@end
