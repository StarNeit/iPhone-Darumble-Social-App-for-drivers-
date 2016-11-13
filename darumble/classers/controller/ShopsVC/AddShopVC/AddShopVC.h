//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopObj.h"

@interface AddShopVC : UIViewController{
    
}
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;

@property NSString *title_name;
@property int flagOfShop;

@property ShopObj *m_shop_detail_info;
@end
