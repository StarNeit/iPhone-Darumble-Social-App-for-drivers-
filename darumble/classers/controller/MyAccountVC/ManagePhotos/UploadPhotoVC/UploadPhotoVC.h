//
//  AddPhotoVC.h
//  DaRumble
//
//  Created by Vidic Phan on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoObj.h"
#import "ELCImagePickerHeader.h"

@interface UploadPhotoVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ELCImagePickerControllerDelegate>{
    NSString *imgData;
    __weak IBOutlet UIButton *btAdd;
}

@property (nonatomic, retain) PhotoObj *photoObj;
@property (nonatomic, copy) NSArray *chosenImages;
- (IBAction)clickAdd:(id)sender;
@end
