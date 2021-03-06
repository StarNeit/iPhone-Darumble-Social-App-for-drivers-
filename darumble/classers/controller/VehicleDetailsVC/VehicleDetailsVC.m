//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "VehicleDetailsVC.h"
#import "UIImageView+AFNetworking.h"
#import "PublicProfileVC.h"
#import "CommentCell.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@interface VehicleDetailsVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    IBOutlet UIButton *btn_like;
    IBOutlet UIButton *btn_flag;
    IBOutlet UITextView *tv_type;
    IBOutlet UITextView *tv_make;
    IBOutlet UITextView *tv_model;
    IBOutlet UITextView *tv_year;
    IBOutlet UIButton *btn_organzierName;
    
    
    NSMutableArray *commentArray;
    IBOutlet UITableView *commentListTableView;
}
@property (strong, nonatomic) IBOutlet UIImageView *mainEventPhoto;
@end

@implementation VehicleDetailsVC
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
    
//---WS API Call---//
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0)
    {
    //---WS API Call(get vehicle)---//
        [self removeNotifi];
        [self addNotifi];
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_vehicle_details:APP_TOKEN vehicleID:self.photoObj.id userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
        
    //---WS API Call(load comments)---//
        [self removeNotifi6];
        [self addNotifi6];
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws2 = [[DataCenter alloc] init];
        [ws2 load_comments:APP_TOKEN catID:self.photoObj.categoryID contentID:self.photoObj.id];
    }
    [self restrictRotation:YES];
    
    
    
    
//---Do any additional setup after loading the view from its nib.---//
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,980)];
   
//---Setting Single Tap---//
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    
//---Photo Detail Image---//
    
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
                
                self.mainEventPhoto.image = image;
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
            }
        }];
    }    
    
//---Add Gesture---
    [self._srcMain addGestureRecognizer:singleTap];
    
    commentListTableView.tableFooterView = [[UIView alloc] init];
    commentListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    //[self._srcMain setContentOffset:CGPointMake(0, 0) animated:YES];
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


//---Device Orientation---//
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

-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
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


//---UI Controller---
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
- (IBAction)clickLike:(id)sender
{
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:NSLocalizedString(@"Darumble",nil) message:NSLocalizedString(@"Do you like this content?",nil)
//                               delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
//    errorAlert.tag = c_like_content;
//    [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
//    [errorAlert show];
    
    if (btn_like.tag == 1) //no
    {
        [btn_like setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        
        //---WS API CALL(like content)---
        [self removeNotifi3];
        [self addNotifi3];
        
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws like_content:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id isLike:1 creatorid:self.photoObj.uid];
        btn_like.tag = 0;
    }else if (btn_like.tag == 0) //yes
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
- (IBAction)clickAdderName:(id)sender {
    //---WS API CALL(check blocked status)---
    [self removeNotifi5];
    [self addNotifi5];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws check_blocked_status:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue] userID2:self.photoObj.uid];
}
- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setLikeFlagButtons{
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



//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD)
    {
        if (indexPath.row == [commentArray count] - 1)
            return 445;
        return 310;
    }else{
        if (indexPath.row == [commentArray count] - 1)
            return 200;
        return 158;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---PhotoList---
    NSLog(@"test!");
    
    static NSString *simpleTableIdentifier = @"CommentCell";
    
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    UserObj *comment = [commentArray objectAtIndex:indexPath.row];
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", comment.fname, comment.lname];
    cell.comment.text = comment.c_description;
    if (IS_IPAD)
    {
        UIFont *font = cell.userName.font;
        cell.userName.font = [font fontWithSize:30];
        [cell.comment setFont: [font fontWithSize:30]];
    }
    
    if (indexPath.row != [commentArray count] - 1)
    {
        cell.comment.editable = false;
    }else cell.comment.editable = true;
    
    
    cell.btnPostComment.tag = indexPath.row;
    [cell.btnPostComment addTarget:self action:@selector(clickPostComment:) forControlEvents:UIControlEventTouchUpInside];
    
    //---Photo Image---
    UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
    NSURL *url = [NSURL URLWithString:comment.profile_pic_url];
    
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
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}

- (void) clickPostComment:(id)sender
{
    int row = ((UIButton*)sender).tag;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // in case this row in in your first section
    CommentCell* cell = [commentListTableView cellForRowAtIndexPath:indexPath];
    cell.comment.text = [Common trimString:cell.comment.text];
    
    if (cell.comment.text.length == 0) {
        [Common showAlert:@"Comment is empty"];
        return;
    }
    
    //---WS API Call(add comment)---
    [self removeNotifi2];
    [self addNotifi2];
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws add_comment:APP_TOKEN uid:[[USER_DEFAULT objectForKey:@"userID"] intValue] catid:self.photoObj.categoryID contentid:self.photoObj.id description:cell.comment.text creatorid:self.photoObj.uid];
}


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetVehicleDetail_Success:) name:k_vehicle_details_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetVehicleDetail_Fail:) name:k_vehicle_details_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_vehicle_details_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_vehicle_details_fail object:nil];
}

-(void) GetVehicleDetail_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        NSDictionary *data = [dic objectForKey:@"data"];
        NSDictionary *vehicle_details = [data objectForKey:@"vehicle_details"];
        
        NSString *type = [vehicle_details objectForKey:@"type"] != [NSNull null] ? [vehicle_details objectForKey:@"type"] : @"";
        
        
        NSString *make = [vehicle_details objectForKey:@"make"] != [NSNull null] ? [vehicle_details objectForKey:@"make"] : @"";
        
        
        NSString *model = [vehicle_details objectForKey:@"model"] != [NSNull null] ? [vehicle_details objectForKey:@"model"] : @"";
        
        
        NSString *year = [vehicle_details objectForKey:@"year"] != [NSNull null] ? [vehicle_details objectForKey:@"year"] : @"";
        
        
        NSString *description = [vehicle_details objectForKey:@"description"] != [NSNull null] ? [vehicle_details objectForKey:@"description"] : @"";
        
        
        NSString *fname = [vehicle_details objectForKey:@"fname"] != [NSNull null] ? [vehicle_details objectForKey:@"fname"] : @"";
        NSString *lname = [vehicle_details objectForKey:@"lname"] != [NSNull null] ? [vehicle_details objectForKey:@"lname"] : @"";
        
        int is_flagged = [vehicle_details objectForKey:@"is_flagged"] != [NSNull null] ? [[vehicle_details objectForKey:@"is_flagged"] intValue] : 0;
        
        int is_like = [vehicle_details objectForKey:@"is_like"] != [NSNull null] ? [[vehicle_details objectForKey:@"is_like"] intValue] : 0;
        
        [tv_type setTextColor:[UIColor whiteColor]];
        tv_type.text = type;
        
        [tv_model setTextColor:[UIColor whiteColor]];
        tv_model.text = model;
        
        [tv_year setTextColor:[UIColor whiteColor]];
        tv_year.text = year;
        
        [tv_make setTextColor:[UIColor whiteColor]];
        tv_make.text = make;
        
        [btn_organzierName setTitle:[NSString stringWithFormat:@"%@ %@",fname, lname] forState:UIControlStateNormal];
        
        btn_flag.tag = is_flagged;
        btn_like.tag = is_like;
        [self setLikeFlagButtons];
        
        
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}

-(void) GetVehicleDetail_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}


//==============WEBSERVICE(Add Comment)============
- (void)addNotifi2
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddComment_Success:) name:k_add_comment_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddComment_Fail:) name:k_add_comment_fail object:nil];
}
- (void)removeNotifi2
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_comment_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_add_comment_fail object:nil];
}
-(void) AddComment_Success:(NSNotification*)notif{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"GlobalFeed SUCCESS %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        [Common showAlert:@"Your comment was posted!"];
        
        //--redirecting me---
        VehicleDetailsVC *vc = [[VehicleDetailsVC alloc] init];
        vc.photoObj = self.photoObj;
        vc.flagOfCommentAdded = 1;
        UINavigationController *navigationController = self.navigationController;
        NSMutableArray *activeViewControllers=[[NSMutableArray alloc] initWithArray: navigationController.viewControllers] ;
        [activeViewControllers removeLastObject];
        
        // Reset the navigation stack
        [navigationController setViewControllers:activeViewControllers];
        [navigationController pushViewController:vc animated:NO];
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
}
-(void) AddComment_Fail:(NSNotification*)notif{
    NSLog(@"NOTIFICATIOn %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi2];
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
//            [Common showAlert:@"You have disliked this vehicle"];
//        }else if (isLike == 2)
//        {
//            [Common showAlert:@"You have liked this vehicle"];
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
        /*if (isFlag == 1)
        {
            [Common showAlert:@"Staff will be notified. Thank you"];
        }else if (isFlag == 2)
        {
            [Common showAlert:@"Staff will be notified. Thank you"];
        }*/
        [Common showAlert:@"Staff will be notified. Thank you"];
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
        self.flagOfCommentAdded = 0;
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


//==============WEBSERVICE(load comments)============
- (void)addNotifi6
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoadComments_Success:) name:k_load_comments_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoadComments_Fail:) name:k_load_comments_fail object:nil];
}
- (void)removeNotifi6
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_load_comments_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_load_comments_fail object:nil];
}
-(void) LoadComments_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"LoadComments_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        commentArray = [[NSMutableArray alloc] init];
        NSDictionary *data = [dic objectForKey:@"data"];
        if ([data objectForKey:@"comments"] != [NSNull null])
        {
            NSArray *arr = [data objectForKey:@"comments"];
            for (NSDictionary *s in arr)
            {
                UserObj* obj = [[UserObj alloc] init];
                obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
                obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
                obj.profile_pic_url = [s objectForKey:@"profile_pic"] != [NSNull null] ? [s objectForKey:@"profile_pic"] : @"";
                obj.c_description = [s objectForKey:@"description"] != [NSNull null] ? [s objectForKey:@"description"] : @"";
                [commentArray addObject:obj];
            }
        }else{
            //[Common showAlert:@"No Comment exist"];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi6];
    
    
//---new api---
    UserObj *me = [[UserObj alloc] init];
    me.fname = [USER_DEFAULT objectForKey:@"fname"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"fname"] : @"";
    me.lname = [USER_DEFAULT objectForKey:@"lname"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"lname"] : @"";
    me.c_description = @"";
    me.profile_pic_url = [USER_DEFAULT objectForKey:@"photo_url"] != [NSNull null] ? [USER_DEFAULT objectForKey:@"photo_url"] : @"";
    [commentArray addObject:me];
    
    if (IS_IPAD)
    {
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,(310 *([commentArray count] - 1) + 445) + 900)];
    }else{
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,(158 *([commentArray count] - 1) + 200) + 550)];
    }
    if (self.flagOfCommentAdded == 1)
    {
        [self._srcMain setContentOffset:CGPointMake(0.0,  370.0) animated:true];
    }
    
    [commentListTableView reloadData];
}
-(void) LoadComments_Fail:(NSNotification*)notif
{
    NSLog(@"LoadComments_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi6];
}
@end
