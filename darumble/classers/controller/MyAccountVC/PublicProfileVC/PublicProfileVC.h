//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicProfileResponse.h"

@interface PublicProfileVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>{
    
    IBOutlet UIScrollView *_srcMain;

}
@property int m_userID;

- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;
@end
