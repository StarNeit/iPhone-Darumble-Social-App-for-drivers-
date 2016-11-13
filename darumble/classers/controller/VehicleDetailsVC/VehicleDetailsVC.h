//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleDetailsVC : UIViewController{
    
    NSMutableArray *bannerImages;
    IBOutlet UILabel *label_no_image;
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
@property (nonatomic, retain) PhotoObj* photoObj;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property int flagOfCommentAdded;
@end
