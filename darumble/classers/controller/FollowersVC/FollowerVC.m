//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "FollowerVC.h"
#import "SearchItemsVC.h"
#import "FollowerCell.h"
#import "UIImageView+AFNetworking.h"
#import "PublicProfileVC.h"

@interface FollowerVC ()
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    NSMutableArray *followerArray;
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *label_no_found;
}
@end

@implementation FollowerVC
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
    //---WS api call---//
    if ([[USER_DEFAULT objectForKey:@"DaRumble_Login"] intValue] != 0) {
        [self removeNotifi];
        [self addNotifi];
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
        DataCenter *ws = [[DataCenter alloc] init];
        [ws get_followers:APP_TOKEN userID:[[USER_DEFAULT objectForKey:@"userID"] intValue]];
    }
    
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.title = @"";
    [self addGestureRecognizers];
    
    tableView.tableFooterView = [[UIView alloc] init];
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




//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [followerArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD)
        return 185;
    return 78;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //---MessageHistoryList---
    NSLog(@"test!");
    static NSString *simpleTableIdentifier = @"FollowerCell";
    
    FollowerCell *cell = (FollowerCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FollowerCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    UserObj *follower = [followerArray objectAtIndex:indexPath.row];
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", follower.fname, follower.lname];
    cell.m_followerID = follower.userID;
    cell.parent = self;
    
    //---Follower Image---
    UIImage *holder = [UIImage imageNamed:@"avatar_l.png"];
    NSURL *url = [NSURL URLWithString:follower.profile_pic_url];
    
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
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UserObj *follower = [followerArray objectAtIndex:indexPath.row];
    PublicProfileVC *vc = [[PublicProfileVC alloc] init];
    vc.m_userID = follower.userID;
    [self.navigationController pushViewController:vc animated:YES];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    
    return indexPath;
}


//==============WEBSERVICE============
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetFollowers_Success:) name:k_get_followers_success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetFollowers_Fail:) name:k_get_followers_fail object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_followers_success object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_get_followers_fail object:nil];
}
-(void) GetFollowers_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
    if ([[dic objectForKey:@"code"] intValue] == 200) {
        NSArray *arr = [[dic objectForKey:@"data"] objectForKey:@"followers"];
        [followerArray removeAllObjects];
        followerArray = [[NSMutableArray alloc] init];
        for (NSDictionary *s in arr)
        {
            UserObj *obj = [[UserObj alloc] init];
            obj.userID = [s objectForKey:@"followerID"]!=[NSNull null] ? [[s objectForKey:@"followerID"] intValue] : 0;
            obj.fname = [s objectForKey:@"fname"] != [NSNull null] ? [s objectForKey:@"fname"] : @"";
            obj.lname = [s objectForKey:@"lname"] != [NSNull null] ? [s objectForKey:@"lname"] : @"";
            obj.profile_pic_url = [s objectForKey:@"url"] != [NSNull null] ? [s objectForKey:@"url"] : @"";
            
            [followerArray addObject:obj];
        }
        [self removeNotifi];
        [tableView reloadData];
        
        if ([followerArray count] == 0)
        {
            label_no_found.hidden = NO;
        }else{
            label_no_found.hidden = YES;
        }
    }else{
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"][0]];
        label_no_found.hidden = NO;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) GetFollowers_Fail:(NSNotification*)notif
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
