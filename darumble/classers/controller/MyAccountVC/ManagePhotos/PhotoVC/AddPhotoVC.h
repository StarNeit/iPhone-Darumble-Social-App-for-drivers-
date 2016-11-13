//
//  AddPhotoVC.h
//  DaRumble
//
//  Created by Vidic Phan on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoObj.h"

@interface AddPhotoVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>{
    NSString *imgData;
    __weak IBOutlet UIButton *btAdd;
}

@property (nonatomic, retain) PhotoObj *photoObj;
- (IBAction)clickAdd:(id)sender;
@end
