//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCell.h"

@interface PhotosContentVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>{
    
    __weak IBOutlet UICollectionView *collectView;
    NSMutableArray *photosArray;
    NSMutableArray *bannerImages;
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;
@property int flag_global_local;
@property int filtered_userId;

@property int flag_from_event;
@property NSMutableArray *event_photosArray;
@end
