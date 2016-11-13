//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "MessageComposeVC.h"
#import "UIImageView+AFNetworking.h"
#import "MessageHistoryVC.h"

@interface MessageComposeVC ()<UIActionSheetDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UIButton *btn_messages;
    IBOutlet UIButton *btn_notifications;
    IBOutlet UITextView *tv_textmessage;
    __weak IBOutlet UILabel *tv_user_name;
    __weak IBOutlet UIImageView *profile_image;
    __weak IBOutlet UIButton *btnAvatar;
    
    IBOutlet UITextField *txf_reason;
    IBOutlet UIView *view_reason_box;
    IBOutlet UIView *view_message_box;
    
    int reason_id;
    
}
@end

@implementation MessageComposeVC
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
    
    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,650)];
    
    btn_messages.tag = 1;
    btn_notifications.tag = 0;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    
    [self._srcMain addGestureRecognizer:singleTap];
    
    
//---Image---
    UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
    NSURL *url = [NSURL URLWithString:[USER_DEFAULT objectForKey:@"photo_url"]];
    
    [profile_image setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                           placeholderImage:holder
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         profile_image.layer.cornerRadius = btnAvatar.frame.size.width/2;
         profile_image.layer.masksToBounds = YES;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         profile_image.image = holder;
     }];
    
    
    tv_user_name.text = [NSString stringWithFormat:@"%@ %@", [USER_DEFAULT objectForKey:@"fname"], [USER_DEFAULT objectForKey:@"lname"]];
    
    if (self.is_report == 2)
    {
        self.view_title.text = @"Report Room";
        view_reason_box.hidden = NO;
    }else{
        self.view_title.text = @"Compose Message";
        view_reason_box.hidden = YES;
    }
}


//---Gesture Recognizer---
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [self._srcMain setContentOffset:CGPointMake(0, 0) animated:YES];
}

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
//            AppDelegate *app = [Common appDelegate];
//            [app initSideMenu];
            [self.navigationController popViewControllerAnimated:YES];
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


//---UI Control---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickComposeMessage:(id)sender
{
    if ([tv_textmessage.text isEqualToString:@""])
    {
        [Common showAlert:@"Message is empty"];
        return;
    }
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        if (self.is_report == 2) //Report User
        {
            txf_reason.text = [Common trimString:txf_reason.text];
            if ([txf_reason.text isEqualToString:@""])
            {
                [Common showAlert:@"Reason is empty"];
                return;
            }
            //---WS API CALL(report user)---
            [self removeNotifi3];
            [self addNotifi3];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws report_user:APP_TOKEN from_userID:self.from_user about_userID:self.to_user report_text:tv_textmessage.text reason_id:reason_id];
        }else //Send message
        {
            //---WS API Call(photo detail)---
            [self removeNotifi];
            [self addNotifi];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws send_message:APP_TOKEN from_userID:self.from_user to_userID:self.to_user text_message:tv_textmessage.text];
        }
    }
}

- (IBAction)clickReasonButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Spam",@"Scammer",@"Nudity/Pornography",@"Unwanted Contact",@"Hate Speech / Racism",@"Threats of Violence",@"Child Explotation",@"Identity theft or stolen personal information",
                                  @"Copyright infringement",@"Other", nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101)
    {
        if (buttonIndex == 0) {
            txf_reason.text = @"Spam";
        }else if (buttonIndex == 1) {
            txf_reason.text = @"Scammer";
        }else if (buttonIndex == 2) {
            txf_reason.text = @"Nudity/Pornography";
        }else if (buttonIndex == 3) {
            txf_reason.text = @"Unwanted Contact";
        }else if (buttonIndex == 4) {
            txf_reason.text = @"Hate Speech / Racism";
        }else if (buttonIndex == 5) {
            txf_reason.text = @"Threats of Violence";
        }else if (buttonIndex == 6) {
            txf_reason.text = @"Child Explotation";
        }else if (buttonIndex == 7) {
            txf_reason.text = @"Identity theft or stolen personal information";
        }else if (buttonIndex == 8) {
            txf_reason.text = @"Copyright infringement";
        }else if (buttonIndex == 9) {
            txf_reason.text = @"Other";
        }
        reason_id = buttonIndex + 1;
    }
}




//==============WEBSERVICE(check blocked status)============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SendMessage_Success:) name:k_send_message_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SendMessage_Fail:) name:k_send_message_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_send_message_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_send_message_fail object:nil];
}
-(void) SendMessage_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        MessageHistoryVC *vc = [[MessageHistoryVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) SendMessage_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}



//==============WEBSERVICE(Report user)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReportUser_Success:) name:k_report_user_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReportUser_Fail:) name:k_report_user_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_report_user_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_report_user_fail object:nil];
}
-(void) ReportUser_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"ReportUser_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully Reported"];
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}
-(void) ReportUser_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}

@end
