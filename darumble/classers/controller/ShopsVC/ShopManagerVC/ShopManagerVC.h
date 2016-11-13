//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopObj.h"

@interface ShopManagerVC : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    

}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
@property int m_shopid;
@property ShopObj *m_shop_detail_info;
@property int flagOfSwitchView;//0: MemberList, 1: RequestList, 2: Invite

- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;
@end
