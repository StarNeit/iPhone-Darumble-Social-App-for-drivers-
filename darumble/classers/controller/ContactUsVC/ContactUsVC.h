//
//  ContactUsVC.h
//  DaRumble
//
//  Created by Colin on 5/12/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUsVC : UIViewController
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *tvMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblHideMessage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollPage;
- (IBAction)doSend:(id)sender;

@end
