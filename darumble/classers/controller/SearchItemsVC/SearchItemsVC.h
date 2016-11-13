//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchItemsVC : UIViewController{
    
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property NSString* is_rumbler;

@end
