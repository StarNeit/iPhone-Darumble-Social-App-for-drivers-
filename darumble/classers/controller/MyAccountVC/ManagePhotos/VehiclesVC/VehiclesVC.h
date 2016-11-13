//
//  VehiclesVC.h
//  DaRumble
//
//  Created by Vidic Phan on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoObj.h"

@interface VehiclesVC : UIViewController

@property (nonatomic, retain) PhotoObj *photoObj;
@property (strong, nonatomic) IBOutlet UIImageView *_imgPhoto;

@property (weak, nonatomic) UIImage *imageChoosePicker;
@property int is_set_image;
@end
