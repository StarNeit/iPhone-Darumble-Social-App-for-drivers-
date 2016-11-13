//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "MessageHistoryVC.h"
#import "UIImageView+AFNetworking.h"
#import "MessageComposeVC.h"
#import "UserCell.h"
#import "NotificationTableCell.h"
#import "MessengerObj.h"
#import "NotificationObj.h"
#import "LogCell.h"
#import "PrivateLogObj.h"
#import "BottomButtonCell.h"
#import "ShopDetailsVC.h"

@interface MessageHistoryVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UIButton *btn_messages;
    IBOutlet UIButton *btn_notifications;
    
    
    IBOutlet UITableView *notificationListTableView;
    IBOutlet UITableView *messageListTableView;
    IBOutlet UITableView *privatelogTableView;
    
    IBOutlet UILabel *screenTitle;
    
    NSMutableArray *messengerArray;
    NSMutableArray *notificationArray;
    NSMutableArray *privatelogArray;
    
    int currentMessengerForLog;
}
@end

@implementation MessageHistoryVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    btn_messages.tag = 1;
    btn_notifications.tag = 0;
    
    currentMessengerForLog = 0;
    
    notificationListTableView.tag = 2001;
    messageListTableView.tag = 2000;
    privatelogTableView.tag = 2002;
    
    
    [self._srcMessageRoom setContentSize:CGSizeMake(self._srcMessageRoom.frame.size.width,1150)];
 
    messageHistoryListView.hidden = false;
    messageRoomView.hidden = true;
    
    
    privatelogTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    messageListTableView.tableFooterView = [[UIView alloc] init];
    notificationListTableView.tableFooterView = [[UIView alloc] init];
    
    messengerArray = [[NSMutableArray alloc] init];
    notificationArray = [[NSMutableArray alloc] init];
    privatelogArray = [[NSMutableArray alloc] init];
    
    
    
    AppDelegate *app = [Common appDelegate];
    if (app.msg_redir == 2){
        app.msg_redir = 0;
        [self showMessagesPanel];
    }
    
    //************************//
    //*      Clear Badge     *//
    //************************//
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}



//---Gesture Recognizer---
- (void)addGestureRecognizers {
    [[self view] addGestureRecognizer:[self panGestureRecognizer]];
}
- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    return recognizer;
}
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        velocityF = [recognizer velocityInView:self.view];
        velocityL = [recognizer velocityInView:self.view];
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        velocityL = [recognizer velocityInView:self.view];
        
        if(velocityL.x > velocityF.x + 200)
        {
            AppDelegate *app = [Common appDelegate];
            [app initSideMenu];
            
        }
    }
}

//---Device Orientation---
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    [self GetMessageHistory];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    AppDelegate *app = [Common appDelegate];
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}


- (void) showMessagesPanel
{
    [btn_messages setImage:[UIImage imageNamed:@"btn_messages_on.png"] forState:UIControlStateNormal];
    [btn_notifications setImage:[UIImage imageNamed:@"btn_notification.png"] forState:UIControlStateNormal];
    
    screenTitle.text = @"Messages";
    [self GetMessageHistory];
    
    messageHistoryListView.hidden = false;
    messageRoomView.hidden = true;
    notificationView.hidden = true;
}

- (void) showNotificationPanel
{
    [btn_messages setImage:[UIImage imageNamed:@"btn_messages.png"] forState:UIControlStateNormal];
    [btn_notifications setImage:[UIImage imageNamed:@"btn_notification_on.png"] forState:UIControlStateNormal];
    
    screenTitle.text = @"Notifications";
    [self GetNotification];
    
    messageHistoryListView.hidden = true;
    messageRoomView.hidden = true;
    notificationView.hidden = false;
}


//---UI Controller---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
- (IBAction)clickMessages:(id)sender {
    [self showMessagesPanel];
}
- (IBAction)clickNotifications:(id)sender {
    [self showNotificationPanel];
}
- (IBAction)clickSearch:(id)sender {
    if (messageHistoryListView.hidden == true && notificationView.hidden == true)
    {
        messageHistoryListView.hidden = false;
        messageRoomView.hidden = true;
    }else{
        AppDelegate *app = [Common appDelegate];
       [app initSideMenu];
    }
}
- (IBAction)clickNewMessage:(id)sender {
    MessageComposeVC *vc = [[MessageComposeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}




//---UI TableView---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 2000)
         return [messengerArray count];
    else if (tableView.tag == 2001)
        return [notificationArray count];
    else //2002
        return [privatelogArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD)
    {
        if (tableView.tag == 2000)
            return 146;
        else if (tableView.tag == 2001)
            return 146;
        else
            return 228;
    }else{
        if (tableView.tag == 2000)
            return 78;
        else if (tableView.tag == 2001)
            return 78;
        else
            return 96;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2000)//---MessageHistoryList---
    {
        NSLog(@"test!");
        static NSString *simpleTableIdentifier = @"UserCell";
        
        UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
       
        MessengerObj *mObj = [messengerArray objectAtIndex:indexPath.row];
        
        cell.userName.text = [NSString stringWithFormat:@"%@ %@", mObj.fname, mObj.lname];
        cell.lastMessage.text = mObj.text_message;
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
        [formatter2 setDateFormat:@"hh:mm a"];
        NSDate *date2 = [Common convertStringToDate:mObj.date_sent];
        NSString *dateString2 = [formatter2 stringFromDate:date2];
        
        cell.lastTime.text = dateString2;
        
    //---Delete message button---//
        cell.btn_delete_message.tag = indexPath.row;
        [cell.btn_delete_message addTarget:self action:@selector(clickDelete:) forControlEvents:UIControlEventTouchUpInside];
        
    //---Image---
        UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
        NSURL *url = [NSURL URLWithString:mObj.profile_pic_url];
        
        [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                               placeholderImage:holder
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             cell.thumbnails.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
             cell.thumbnails.layer.masksToBounds = YES;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             cell.thumbnails.image = holder;
         }];
        
        NSInteger timeInSeconds = mObj.timespan;
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInSeconds];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"hh:mm a"];
        NSString *dateString = [formatter stringFromDate:date];
        
        cell.whileTime.text = dateString;
        
        return cell;
    }else if (tableView.tag == 2001)//---notifications---
    {
        //---NotificationHistoryList---
             static NSString *simpleTableIdentifier = @"NotificationTableCell";
             
             NotificationTableCell *cell = (NotificationTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
             if (cell == nil)
             {
             NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationTableCell" owner:self options:nil];
             cell = [nib objectAtIndex:0];
             }
             [cell setBackgroundColor:[UIColor clearColor]];
             
             NotificationObj *obj = [notificationArray objectAtIndex:indexPath.row];
        
            NSRange range = [obj.notification rangeOfString:@":"];
            if (range.location == NSNotFound) {
                NSLog(@"string was not found");
            } else {
                NSLog(@"position %lu", (unsigned long)range.location);
            }
        
            cell.txtNotification.text = [[obj.notification componentsSeparatedByString:@":"] objectAtIndex:1];
            cell.txtTitle.text = [[obj.notification componentsSeparatedByString:@":"] objectAtIndex:0];
            @try {
               cell.txtCommenter.text = [[obj.notification componentsSeparatedByString:@":"] objectAtIndex:2];
            }
            @catch (NSException *exception) {
                cell.txtCommenter.text = @"";
            }
            cell.arrivedTime.text = obj.date;
        
            if ([obj.notification componentsSeparatedByString:@":"].count == 4)
            {
                cell.shop_id = [[[obj.notification componentsSeparatedByString:@":"] objectAtIndex:3] intValue];
            }else{
                cell.shop_id = -1;
            }
            return cell;
    }else //2003: privateLog
    {
        MessengerObj *mObj = [messengerArray objectAtIndex:currentMessengerForLog];
        PrivateLogObj *pLogObj = [privatelogArray objectAtIndex:indexPath.row];
        
        
        int switchflag;//1:my message, 0: other message
        
        if (pLogObj.from_user == self.plog_from_id && pLogObj.to_user == self.plog_to_id)
            switchflag = 1;
        else switchflag = 0;
    
        if (pLogObj.from_user == -1 && pLogObj.to_user == -1)
        {
            static NSString *simpleTableIdentifier = @"BottomButtonCell";
            BottomButtonCell *cell = (BottomButtonCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BottomButtonCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.parent = self;
            return cell;
        }else
        {
            LogCell *cell;
            NSString *photo_url;
            if (switchflag == 0)
            {
                static NSString *simpleTableIdentifier = @"LogCell";
                cell = (LogCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LogCell" owner:self options:nil];
                    cell = [nib objectAtIndex:0];
                }
                photo_url = mObj.profile_pic_url;
                
                cell.username.text = [NSString stringWithFormat:@"%@ %@", mObj.fname, mObj.lname];
            }else if (switchflag == 1)
            {
                static NSString *simpleTableIdentifier = @"LogCell2";
                cell = (LogCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LogCell2" owner:self options:nil];
                    cell = [nib objectAtIndex:0];
                }
                photo_url = [USER_DEFAULT objectForKey:@"photo_url"];
                
                cell.username.text = [NSString stringWithFormat:@"%@ %@", [USER_DEFAULT objectForKey:@"fname"], [USER_DEFAULT objectForKey:@"lname"]];
            }
            
            
            [cell setBackgroundColor:[UIColor clearColor]];
            //---Image---
            UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
            NSURL *url = [NSURL URLWithString:photo_url];
            [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                   placeholderImage:holder
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 cell.thumbnails.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
                 cell.thumbnails.layer.masksToBounds = YES;
             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 cell.thumbnails.image = holder;
             }];
            
            
            NSDate *date = [Common convertStringToDate:pLogObj.date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
            NSString *dateDisplay = [dateFormat stringFromDate:date];
            cell.date.text = dateDisplay;
            
            cell.message.text = pLogObj.text_message;
            
            return cell;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Checked the selected row
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (tableView.tag == 2000)
    {
        NSLog(@"didSelectRowAtIndexPath");
        /*UIAlertView *messageAlert = [[UIAlertView alloc]
         initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];*/
//        UIAlertView *messageAlert = [[UIAlertView alloc]
//                                     initWithTitle:@"Row Selected" message:[userNameData objectAtIndex:indexPath.row] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        //[messageAlert show];
        
        MessengerObj *mObj = [messengerArray objectAtIndex:indexPath.row];
        [self GetPrivateLog:mObj.followerID index:indexPath.row];
        
    }else if (tableView.tag == 2001)
    {
        NotificationTableCell* _cell = (NotificationTableCell*)cell;
        if (_cell.shop_id > 0)
        {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Accept invitation and join group?",nil)
                                       delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
            errorAlert.tag = _cell.shop_id * -1;
            [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
            [errorAlert show];
        }
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    if (indexPath.row == 0) {
        //return nil;
    }
    return indexPath;
}
- (void) clickDelete:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    int index = btn.tag;
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Delete this conversation?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = index;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag < 0)//accept invitation
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
//            [Common showAlert:[NSString stringWithFormat:@"%d,%d", alertView.tag * -1, [[USER_DEFAULT objectForKey:@"userID"] intValue]]];
            
            //---WS API Call(accept invitation)---
            [self removeNotifi5];
            [self addNotifi5];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws accept_invitation:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] shopID:(alertView.tag * -1)];
        }
    }else //delete message
    {
        int index = alertView.tag;
        
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            MessengerObj *mObj = [messengerArray objectAtIndex:index];
            //---WS API Call(photo detail)---
            [self removeNotifi4];
            [self addNotifi4];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws remove_message:APP_TOKEN from_userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] to_userID:mObj.followerID];
        }

    }
}

-(void)GetMessageHistory{
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_message_history:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
}


-(void)GetNotification{
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi2];
        [self addNotifi2];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_notifications:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
}


-(void)GetPrivateLog : (int)from_id index:(int)index{
    if (from_id == 0)
    {
        [Common showAlert:@"Couldn't load current user's log."];
        return;
    }
    currentMessengerForLog = index;
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //---WS API Call(photo detail)---
        [self removeNotifi3];
        [self addNotifi3];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_private_log:APP_TOKEN from_userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] to_userID:from_id];
    }
}
//==============WEBSERVICE(get message history)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMessageHistory_Success:) name:k_message_history_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMessageHistory_Fail:) name:k_message_history_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_message_history_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_message_history_fail object:nil];
}
-(void) GetMessageHistory_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetMessageHistory_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [messengerArray removeAllObjects];
        
        NSDictionary *rumbler0 = [[dic objectForKey:@"data"] objectForKey:@"rumbler0"];
        if (rumbler0 == nil)
        {
            [self removeNotifi];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [Common showAlert:@"No message history found"];
            return;
        }
        NSDictionary *data = [dic objectForKey:@"data"];
        int cnt = data.count - 1;
        
        for (int i = 0 ; i < cnt; i ++)
        {
            MessengerObj *messengerObj = [[MessengerObj alloc] init];
            NSDictionary *rumbler = [data objectForKey:[NSString stringWithFormat:@"rumbler%d",i]];
            if (rumbler == [NSNull null])
                continue;
            messengerObj.followerID = [rumbler objectForKey:@"id"] != [NSNull null] ? [[rumbler objectForKey:@"id"] intValue] : 0;
            messengerObj.fname = [rumbler objectForKey:@"fname"] != [NSNull null] ? [rumbler objectForKey:@"fname"] : @"";
            messengerObj.lname = [rumbler objectForKey:@"lname"] != [NSNull null] ? [rumbler objectForKey:@"lname"] : @"";
            messengerObj.profile_pic_url = [rumbler objectForKey:@"url"] != [NSNull null] ? [rumbler objectForKey:@"url"] : @"";
            messengerObj.date_sent = [rumbler objectForKey:@"date_sent"] != [NSNull null] ? [rumbler objectForKey:@"date_sent"] : @"";
            messengerObj.text_message = [rumbler objectForKey:@"text_message"] != [NSNull null] ? [rumbler objectForKey:@"text_message"] : @"";
            messengerObj.timespan = [rumbler objectForKey:@"timespan"] != [NSNull null] ? [[rumbler objectForKey:@"timespan"] intValue] : 0;
            [messengerArray addObject:messengerObj];
            
        }
        
        for (int i = 0; i < cnt - 1; i ++)
        {
            for (int j = i + 1; j < cnt; j ++)
            {
                NSDate *date1 = [Common convertStringToDate:((MessengerObj*)messengerArray[i]).date_sent];
                NSDate *date2 = [Common convertStringToDate:((MessengerObj*)messengerArray[j]).date_sent];
                
                if ([Common CompareDateWithDate:date1 :date2] == NO)
                {
                    MessengerObj *temp = [[MessengerObj alloc] init];
                    temp = messengerArray[i];
                    messengerArray[i] = messengerArray[j];
                    messengerArray[j] = temp;
                }
                
            }
        }
        
        [self removeNotifi];
        [messageListTableView reloadData];
        
        if (IS_IPAD)
        {
            [messageHistoryListView setContentSize:CGSizeMake(messageHistoryListView.frame.size.width,[messengerArray count] * 146 + 44 + 500)];
        }else{
            [messageHistoryListView setContentSize:CGSizeMake(messageHistoryListView.frame.size.width,[messengerArray count] * 78 + 44 + 200)];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) GetMessageHistory_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

//==============WEBSERVICE(get notifications)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetNotifications_Success:) name:k_get_notifications_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetNotifications_Fail:) name:k_get_notifications_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_notifications_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_notifications_fail object:nil];
}
-(void) GetNotifications_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetNotifications_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [notificationArray removeAllObjects];
        
        NSDictionary *data = [dic objectForKey:@"data"];
        
        if ([data objectForKey:@"notifications"] == [NSNull null])
        {
            [self removeNotifi2];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [Common showAlert:@"No notifications found"];
            return;
        }
        
        NSArray *arr = [data objectForKey:@"notifications"];
        
        for (NSDictionary *s in arr)
        {
            NotificationObj *obj = [[NotificationObj alloc] init];
            obj.id = [s objectForKey:@"id"] != [NSNull null] ? [[s objectForKey:@"id"] intValue] : 0;
            obj.notification = [s objectForKey:@"notification"] != [NSNull null] ? [s objectForKey:@"notification"] : @"";
            obj.date = [s objectForKey:@"date"] != [NSNull null] ? [s objectForKey:@"date"] : @"";
            [notificationArray addObject:obj];
        }
        [self removeNotifi2];
        [notificationListTableView reloadData];
        
        if (IS_IPAD)
        {
            [notificationView setContentSize:CGSizeMake(notificationView.frame.size.width,[notificationArray count] * 146 + 44 + 500)];
        }else{
            [notificationView setContentSize:CGSizeMake(notificationView.frame.size.width,[notificationArray count] * 78 + 44 + 200)];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) GetNotifications_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}

//==============WEBSERVICE(get privatelog)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetPrivateLogs_Success:) name:k_private_log_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetPrivateLogs_Fail:) name:k_private_log_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_private_log_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_private_log_fail object:nil];
}
-(void) GetPrivateLogs_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetPrivateLogs_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [privatelogArray removeAllObjects];
        
        NSDictionary *data = [dic objectForKey:@"data"];
        NSArray *arr = [data objectForKey:@"messagelog"];
        
        self.plog_from_id = [data objectForKey:@"from_userID"] != [NSNull null] ? [[data objectForKey:@"from_userID"] intValue] : 0;
        self.plog_to_id = [data objectForKey:@"to_userID"] != [NSNull null] ? [[data objectForKey:@"to_userID"] intValue] : 0;
        
        for (NSDictionary *s in arr)
        {
            PrivateLogObj *obj = [[PrivateLogObj alloc] init];
            obj.from_user = [s objectForKey:@"from_user"] != [NSNull null] ? [[s objectForKey:@"from_user"] intValue] : 0;
            obj.to_user = [s objectForKey:@"to_user"] != [NSNull null] ? [[s objectForKey:@"to_user"] intValue] : 0;
            obj.text_message = [s objectForKey:@"text_message"] != [NSNull null] ? [s objectForKey:@"text_message"] : @"";
            obj.date = [s objectForKey:@"date"] != [NSNull null] ? [s objectForKey:@"date"] : @"";
            
            [privatelogArray addObject:obj];
        }
        //---for the bottom button , add one more param to array----
        PrivateLogObj *obj = [[PrivateLogObj alloc] init];
        obj.from_user = -1; obj.to_user = -1;
        [privatelogArray addObject:obj];
        
        if (IS_IPAD){
            [messageRoomView setContentSize:CGSizeMake(messageRoomView.frame.size.width,[privatelogArray count] * 228 + 44 + 500)];
            [messageRoomView setContentOffset:CGPointMake(0.0, ([privatelogArray count] - 2) * 228 ) animated:true];
        }else{
            [messageRoomView setContentSize:CGSizeMake(messageRoomView.frame.size.width,[privatelogArray count] * 96 + 44 + 200)];
            [messageRoomView setContentOffset:CGPointMake(0.0, ([privatelogArray count] - 2) * 96 ) animated:true];
        }
        
        [self removeNotifi3];
        [privatelogTableView reloadData];
        
        messageHistoryListView.hidden = true;
        messageRoomView.hidden = false;
        
        
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}
-(void) GetPrivateLogs_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}



//---Remove Message---//
- (void)addNotifi4
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveMessage_Success:) name:k_remove_message_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveMessage_Fail:) name:k_remove_message_fail object:nil];
}
- (void)removeNotifi4
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_message_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_remove_message_fail object:nil];
}
-(void) RemoveMessage_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"RemoveMessage_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        MessageHistoryVC *vc = [[MessageHistoryVC alloc] init];
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}
-(void) RemoveMessage_Fail:(NSNotification*)notif
{
    NSLog(@"RemoveMessage_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}




//---Accept invitation---
- (void)addNotifi5
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AcceptInvitationSuccess:) name:k_accept_invitation_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AcceptInvitationFail:) name:k_accept_invitation_fail object:nil];
}
- (void)removeNotifi5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_accept_invitation_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_accept_invitation_fail object:nil];
}
-(void) AcceptInvitationSuccess:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"AcceptInvitationSuccess %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        //[Common showAlert:@"You accepted club invitation successfully"];
        
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj.id = [[dic objectForKey:@"data"] objectForKey:@"shopID"] != [NSNull null]?[[[dic objectForKey:@"data"] objectForKey:@"shopID"] intValue] : 0;
        obj.uid = [[dic objectForKey:@"data"] objectForKey:@"userID"] != [NSNull null] ? [[[dic objectForKey:@"data"] objectForKey:@"userID"] intValue] : 0;
        obj.URL = [[dic objectForKey:@"data"] objectForKey:@"url"] != [NSNull null] ? [[dic objectForKey:@"data"] objectForKey:@"url"] : @"";
        obj.categoryID = 16;
        
        ShopDetailsVC *vc = [[ShopDetailsVC alloc] init];
        vc.photoObj = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}
-(void) AcceptInvitationFail:(NSNotification*)notif
{
    NSLog(@"AcceptInvitationFail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}
@end
