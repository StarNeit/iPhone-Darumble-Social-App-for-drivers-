//
//  HomeVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/26/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UIViewController{
    
}

- (IBAction)clickMenu:(id)sender;
- (IBAction)clickGallery:(id)sender;
- (IBAction)clickEvent:(id)sender;
- (IBAction)clickShopClub:(id)sender;
- (IBAction)clickAccount:(id)sender;


@property(nonatomic, weak) IBOutlet UILabel *registeringLabel;
@end
