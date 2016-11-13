//
//  PoliceVC.h
//  DaRumble
//
//  Created by Colin on 5/11/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoliceVC : UIViewController
- (IBAction)doSearch:(id)sender;
- (IBAction)doMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *tvContent;

@end
