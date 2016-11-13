//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UploadFlyerVC;
@protocol UploadFlyerVCDelegate <NSObject>

- (void)addItemViewController:(UploadFlyerVC *)controller didFinishEnteringItem:(NSString *)image_name flyer_id:(int)flyer_id;

@end



@interface UploadFlyerVC : UIViewController{
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property (nonatomic, weak) id <UploadFlyerVCDelegate> delegate;
@property NSString *flyerURL;
@end
