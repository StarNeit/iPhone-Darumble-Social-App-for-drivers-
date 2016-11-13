//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDetailsVC : UIViewController{
    
    NSMutableArray *bannerImages;
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
@property (strong, nonatomic) PhotoObj *photoObj;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property int flagOfCommentAdded;
@end
