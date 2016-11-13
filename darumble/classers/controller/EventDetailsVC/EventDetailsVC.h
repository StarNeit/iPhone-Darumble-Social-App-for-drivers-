//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsVC : UIViewController{
    
    NSMutableArray *bannerImages;
    NSMutableArray *eventsArray;
    
    NSMutableArray *bannerVideos;
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
@property (strong, nonatomic) PhotoObj *photoObj;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, copy) NSArray *chosenImages;

@property int flagOfAddedComment;

- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;
@end
