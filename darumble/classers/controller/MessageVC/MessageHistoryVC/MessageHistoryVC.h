//
//  GalleryVC.h
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageHistoryVC : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    
    IBOutlet UIScrollView *messageHistoryListView;
    IBOutlet UIScrollView *messageRoomView;
    IBOutlet UIScrollView *notificationView;
}
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMain;
@property (strong, nonatomic) IBOutlet UIScrollView *_srcMessageRoom;
@property int plog_from_id;
@property int plog_to_id;
- (IBAction)clickMenu:(id)sender;
- (IBAction)clickSearch:(id)sender;
@end
