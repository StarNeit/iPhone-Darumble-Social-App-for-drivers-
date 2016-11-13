//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ShopDetailsVC.h"
#import "UIImageView+AFNetworking.h"
#import "PublicProfileVC.h"
#import "ClubMemberCell.h"
#import "LeaveGroupButCell.h"
#import "ShopsContentVC.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@interface ShopDetailsVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UIButton *btn_like;
    IBOutlet UIButton *btn_flag;
    IBOutlet UITextView *tv_name;
    IBOutlet UITextView *tv_location;
    IBOutlet UITextView *tv_description;
    IBOutlet UITextView *tv_creatorName;
    IBOutlet UIButton *btn_organizerName;
    IBOutlet UIButton *btn_request_membership;
    
    NSMutableArray *clubmembersArray;
    IBOutlet UIView *clubmembersView;
    IBOutlet UITableView *clubmemberTableView;
    IBOutlet UILabel *label_no_image;
}
@property (strong, nonatomic) IBOutlet UIImageView *mainEventPhoto;
@end

@implementation ShopDetailsVC
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
    
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
        //---Detail WS API Call---
        [self removeNotifi];
        [self addNotifi];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_shop_details:APP_TOKEN shopID:self.photoObj.id userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
        
        //---Get Membership Status WS API Call---
        [self removeNotifi7];
        [self addNotifi7];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws2 = [[DataCenter alloc] init];
        [ws2 get_membership_status:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] shopID:self.photoObj.id];
    }
    
    
//---Do any additional setup after loading the view from its nib.---//
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    if (IS_IPAD)
    {
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,2000)];
    }else{
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,1250)];
    }
//---Photo Detail Image---
    /*
     NSURL *url = [NSURL URLWithString:self.photoObj.URL];
    [self.indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: url];
        if ( data == nil ){
            self.indicator.hidden = YES;
            label_no_image.hidden = NO;
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            UIImage *img = [UIImage imageWithData:data];
            self.indicator.hidden = YES;
            label_no_image.hidden = YES;
            self.mainEventPhoto.image = img;
            self.mainEventPhoto.contentMode = UIViewContentModeScaleAspectFill;
            self.mainEventPhoto.clipsToBounds = YES;
        });
    });*/
    
    /*
     UIImage *holder = [UIImage imageNamed:@""];
    [self.indicator startAnimating];
    if(url) {
        [self.mainEventPhoto setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                   placeholderImage:holder
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                self.mainEventPhoto.contentMode = UIViewContentModeScaleAspectFill;
                                                self.mainEventPhoto.clipsToBounds = YES;
                                                
                                                self.indicator.hidden = YES;
                                                label_no_image.hidden = YES;
                                                
                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                self.mainEventPhoto.image = holder;
                                                self.indicator.hidden = YES;
                                                label_no_image.hidden = NO;
                                            }];
    }else
    {
        self.mainEventPhoto.image = holder;
        self.indicator.hidden = YES;
        label_no_image.hidden = NO;
    }*/
    
    if (self.photoObj.URL.length > 0)
    {
        [self.indicator startAnimating];
        [Common downloadImageWithURL:[NSURL URLWithString: self.photoObj.URL] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                self.mainEventPhoto.contentMode = UIViewContentModeScaleAspectFill;
                self.mainEventPhoto.clipsToBounds = YES;
                
                self.self.mainEventPhoto.image = image;
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
            }
        }];
    }    
    
    clubmemberTableView.tableFooterView = [[UIView alloc] init];
    
    [self restrictRotation:YES];
}

-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (IBAction)doShowImage:(id)sender
{
    if(self.mainEventPhoto)
    {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = self.mainEventPhoto.image;
        imageInfo.referenceRect = self.mainEventPhoto.frame;
        imageInfo.referenceView = self.mainEventPhoto.superview;
        imageInfo.referenceContentMode = self.mainEventPhoto.contentMode;
        
        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
    
}

//---Gesture Recognizer----
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
    
    
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}




//---UI Controller---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == c_like_content)
    {
        if (buttonIndex == 0) //no
        {
            if (btn_like.tag == 0) return;
            [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi3];
            [self addNotifi3];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:1 creatorid:self.photoObj.uid];
            btn_like.tag = 0;
        }else if (buttonIndex == 1) //yes
        {
            if (btn_like.tag == 1) return;
            [btn_like setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi3];
            [self addNotifi3];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:2 creatorid:self.photoObj.uid];
            btn_like.tag = 1;
        }
    }
    if (alertView.tag == c_flag_content)
    {
        if (buttonIndex == 0) //no
        {
            if (btn_flag.tag == 0) return;
            [btn_flag setImage:[UIImage imageNamed:@"flag.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi4];
            [self addNotifi4];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws flag_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isFlag:1];
            
            btn_flag.tag = 0;
        }else if (buttonIndex == 1) //yes
        {
            if (btn_flag.tag == 1) return;
            [btn_flag setImage:[UIImage imageNamed:@"flag_on.png"] forState:UIControlStateNormal];
            
            //---WS API CALL(like content)---
            [self removeNotifi4];
            [self addNotifi4];
            
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
            DataCenter *ws = [[DataCenter alloc] init];
            [ws flag_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isFlag:2];
            
            btn_flag.tag = 1;
        }
    }
}
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
- (IBAction)clickAdderName:(id)sender {
    if (self.photoObj.uid == 0) {
        [Common showAlert:@"Couldn't access this user"];
        return;
    }
    //---WS API CALL(check blocked status)---
    [self removeNotifi5];
    [self addNotifi5];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws check_blocked_status:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] userID2:self.photoObj.uid];
}
- (IBAction)clickLike:(id)sender
{
    /*
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Do you like this content?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_like_content;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];*/
    
    if (btn_like.tag == 1)
    {
         [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
         
         //---WS API CALL(like content)---
         [self removeNotifi3];
         [self addNotifi3];
         
         [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
         DataCenter *ws = [[DataCenter alloc] init];
         [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:1 creatorid:self.photoObj.uid];
         btn_like.tag = 0;
    }else if (btn_like.tag == 0)
    {
        [btn_like setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
        
        //---WS API CALL(like content)---
        [self removeNotifi3];
        [self addNotifi3];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:2 creatorid:self.photoObj.uid];
        btn_like.tag = 1;
    }
}
- (IBAction)clickFlag:(id)sender
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Are you sure to flag this content?",nil)
                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
    errorAlert.tag = c_flag_content;
    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [errorAlert show];
}
- (IBAction)clickSearch:(id)sender {
    [self restrictRotation:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setLikeFlagButton{
    if (btn_like.tag == 0){
        [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    }else if (btn_like.tag == 1){
        [btn_like setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
    }
    if (btn_flag.tag == 0){
        [btn_flag setImage:[UIImage imageNamed:@"flag.png"] forState:UIControlStateNormal];
    }else if (btn_flag.tag == 1){
        [btn_flag setImage:[UIImage imageNamed:@"flag_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)clickRequestMembership:(id)sender {
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        //1
        if([self.m_joinStatus isEqualToString:@"Requested"])
        {
            [Common showAlert:@"You've already requested to this group"];
            return;
        }else if([self.m_joinStatus isEqualToString:@"Blocked"])
        {
            [Common showAlert:@"You've been blocked from this group"];
            return;
        }
        
        //messaging
        if([self.m_joinStatus isEqualToString:@"Declined"])
        {
            
        }else if([self.m_joinStatus isEqualToString:@"Removed"])
        {
            
        }
        
        //---WS API Call(photo detail)---
        [self removeNotifi6];
        [self addNotifi6];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        int l_userID = [[USER_DEFAULT objectForKey:@"userID"] intValue];
        [ws request_membership:APP_TOKEN userID:l_userID shopID:self.photoObj.id creatorid:self.photoObj.uid];
    }
}


//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [clubmembersArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserObj *member = [clubmembersArray objectAtIndex:indexPath.row];
    
    if (IS_IPAD)
    {
        if (member.userID != -1) return 146;
        else return 180;
    }else{
        if (member.userID != -1) return 78;
        else return 96;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---MessageHistoryList---
    NSLog(@"test!");
    UserObj *member = [clubmembersArray objectAtIndex:indexPath.row];
    
    if (member.userID != -1)
    {
        static NSString *simpleTableIdentifier = @"ClubMemberCell";
        
        ClubMemberCell *cell = (ClubMemberCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ClubMemberCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        
        
        cell.username.text = [NSString stringWithFormat:@"%@ %@", member.fname, member.lname];
        
        //---Member Image---
        UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
        NSURL *url = [NSURL URLWithString:member.profile_pic_url];
        
        [cell.thumbnails setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                               placeholderImage:holder
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             //cell.thumbnails.contentMode = UIViewContentModeScaleAspectFill;
             //cell.thumbnails.clipsToBounds = YES;
             cell.thumbnails.layer.cornerRadius = cell.btnAvatar.frame.size.width/2;
             cell.thumbnails.layer.masksToBounds = YES;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             cell.thumbnails.image = holder;
         }];
        return cell;
    }else{
        static NSString *simpleTableIdentifier = @"LeaveGroupButCell";
        
        LeaveGroupButCell *cell = (LeaveGroupButCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LeaveGroupButCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.parent = self;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserObj *member = [clubmembersArray objectAtIndex:indexPath.row];
    if (member.userID != -1){
        PublicProfileVC *vc = [[PublicProfileVC alloc] init];
        vc.m_userID = member.userID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}



//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetShopDetail_Success:) name:k_shop_details_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetShopDetail_Fail:) name:k_shop_details_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_shop_details_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_shop_details_fail object:nil];
}
-(void) GetShopDetail_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetVehicleDetail_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        
        NSDictionary *shop_details = [data objectForKey:@"shop_details"];
        
        int uid = [shop_details objectForKey:@"uid"] != [NSNull null] ? [[shop_details objectForKey:@"uid"] intValue] : 0;
        self.photoObj.uid = uid;
        
        NSString *shop_name = [shop_details objectForKey:@"shop_name"] != [NSNull null] ? [shop_details objectForKey:@"shop_name"] : @"";
        [tv_name setTextColor:[UIColor whiteColor]];
        tv_name.text = shop_name;
        
        NSString *location = [shop_details objectForKey:@"location"] != [NSNull null] ? [shop_details objectForKey:@"location"] : @"";
        [tv_location setTextColor:[UIColor whiteColor]];
        tv_location.text = location;
        
        
        NSString *fname = [shop_details objectForKey:@"fname"] != [NSNull null] ? [shop_details objectForKey:@"fname"] : @"";
        NSString *lname = [shop_details objectForKey:@"lname"] != [NSNull null] ? [shop_details objectForKey:@"lname"] : @"";
        [btn_organizerName setTitle:[NSString stringWithFormat:@"%@ %@", fname, lname] forState:UIControlStateNormal];
        
        tv_creatorName.text = [NSString stringWithFormat:@"%@ %@", fname, lname];
        
    
        NSString *description = [shop_details objectForKey:@"description"] != [NSNull null] ? [shop_details objectForKey:@"description"] : @"";
        [tv_description setTextColor:[UIColor whiteColor]];
        tv_description.text = description;
        
        
        NSString *shop_status = [shop_details objectForKey:@"shop_status"] != [NSNull null] ? [shop_details objectForKey:@"shop_status"] : @"";
        
        
        int is_flagged = [shop_details objectForKey:@"is_flagged"] != [NSNull null] ? [[shop_details objectForKey:@"is_flagged"] intValue] : 0;
        int is_like = [shop_details objectForKey:@"is_like"] != [NSNull null] ? [[shop_details objectForKey:@"is_like"] intValue] : 0;
        
        btn_like.tag = is_like;
        btn_flag.tag = is_flagged;
        [self setLikeFlagButton];
        
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) GetShopDetail_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}



//==============WEBSERVICE(Like Content)============
- (void)addNotifi3
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LikeContent_Success:) name:k_like_content_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LikeContent_Fail:) name:k_like_content_fail object:nil];
}
- (void)removeNotifi3
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_like_content_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_like_content_fail object:nil];
}
-(void) LikeContent_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        int isLike = [data objectForKey:@"isLike"] != [NSNull null] ? [[data objectForKey:@"isLike"] intValue] : 1;
//        if (isLike == 1)
//        {
//            [Common showAlert:@"Staff will be notified. Thank you"];
//        }else if (isLike == 2)
//        {
//            [Common showAlert:@"Staff will be notified. Thank you"];
//        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}
-(void) LikeContent_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi3];
}


//==============WEBSERVICE(Flag Content)============
- (void)addNotifi4
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FlagContent_Success:) name:k_flag_content_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FlagContent_Fail:) name:k_flag_content_fail object:nil];
}
- (void)removeNotifi4
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_flag_content_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_flag_content_fail object:nil];
}
-(void) FlagContent_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        int isFlag = [data objectForKey:@"isFlag"] != [NSNull null] ? [[data objectForKey:@"isFlag"] intValue] : 1;
        if (isFlag == 1)
        {
            [Common showAlert:@"Staff will be notified. Thank you"];
        }else if (isFlag == 2)
        {
            [Common showAlert:@"Staff will be notified. Thank you"];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}
-(void) FlagContent_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi4];
}


//==============WEBSERVICE(check blocked status)============
- (void)addNotifi5
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckBlockedStatus_Success:) name:k_check_blocked_status_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CheckBlockedStatus_Fail:) name:k_check_blocked_status_fail object:nil];
}
- (void)removeNotifi5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_check_blocked_status_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_check_blocked_status_fail object:nil];
}
-(void) CheckBlockedStatus_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        PublicProfileVC *vc = [[PublicProfileVC alloc] init];
        vc.m_userID = self.photoObj.uid;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}
-(void) CheckBlockedStatus_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi5];
}




//==============WEBSERVICE(Request Membership)============
- (void)addNotifi6
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RequestMembership_Success:) name:k_request_membership_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RequestMembership_Fail:) name:k_request_membership_fail object:nil];
}
- (void)removeNotifi6
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_request_membership_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_request_membership_fail object:nil];
}
-(void) RequestMembership_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"RequestMembership_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Successfully Requested"];
        ShopsContentVC *vc = [[ShopsContentVC alloc] init];
        [self.navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi6];
}
-(void) RequestMembership_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi6];
}





//==============WEBSERVICE(Get Membership Status)============
- (void)addNotifi7
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMembershipStatus_Success:) name:k_get_membership_status_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMembershipStatus_Fail:) name:k_get_membership_status_fail object:nil];
}
- (void)removeNotifi7
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_membership_status_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_membership_status_fail object:nil];
}
-(void) GetMembershipStatus_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        self.m_joinStatus = [data objectForKey:@"joinStatus"] != [NSNull null] ? [data objectForKey:@"joinStatus"] : @"";
        int shop_status = [data objectForKey:@"shop_status"] != [NSNull null] ? [[data objectForKey:@"shop_status"] intValue] : 0;
        //[Common showAlert:self.m_joinStatus];
        
        if (shop_status != 0) //Disabled
        {
            btn_request_membership.hidden = true;
        }else btn_request_membership.hidden = false;

        if([self.m_joinStatus isEqualToString:@"Approved"])
        {
            btn_request_membership.hidden = true;
            clubmembersView.hidden = false;
            
            //---Show Group Members---
            if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
                [self removeNotifi8];
                [self addNotifi8];
                
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
                DataCenter *ws = [[DataCenter alloc] init];
                [ws get_clubmembers:APP_TOKEN shopID:self.photoObj.id];
                
            }
        }
        
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi7];
}
-(void) GetMembershipStatus_Fail:(NSNotification*)notif
{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi7];
}





//==============WEBSERVICE(Get Club Members)============
- (void)addNotifi8
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetClubMembers_Success:) name:k_get_clubmembers_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetClubMembers_Fail:) name:k_get_clubmembers_fail object:nil];
}
- (void)removeNotifi8
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_clubmembers_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_clubmembers_fail object:nil];
}
-(void) GetClubMembers_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GetClubMembers_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary* data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"members"] == [NSNull null])
        {
            [Common showAlert:@"No members on this group"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeNotifi8];
            return;
        }
        clubmembersArray = [[NSMutableArray alloc] init];
        [clubmembersArray removeAllObjects];
        
        NSArray *arr = [data objectForKey:@"members"];
        for (NSDictionary *s in arr)
        {
            UserObj *obj = [[UserObj alloc] init];
            obj.userID = [s objectForKey:@"uid"] != [NSNull null] ? [[s objectForKey:@"uid"] intValue] : 0;
            obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
            obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
            obj.profile_pic_url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            
            [clubmembersArray addObject:obj];
        }
        
        UserObj *obj = [[UserObj alloc] init];
        obj.userID = -1;
        [clubmembersArray addObject:obj];
        
        [clubmemberTableView reloadData];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi8];
}
-(void) GetClubMembers_Fail:(NSNotification*)notif
{
    NSLog(@"GetClubMembers_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi8];
}
@end
