//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalFeedVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>{
    
    IBOutlet UIScrollView *_srcMain;

}
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property (nonatomic, copy) NSArray *chosenImages;
@end
