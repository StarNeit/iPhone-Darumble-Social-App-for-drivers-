//
//  ManageEventsVC.h
//  DaRumble
//
//  Created by Vidic Phan on 4/1/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageEventsVC : UIViewController
- (IBAction)doAdd:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblNoItem;

@property int is_add_image;
@property int addedImageID;
@property NSArray *chosenImages;
@end
