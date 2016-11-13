//
//  MyAccountVC.m
//  DaRumble
//
//  Created by Vidic Phan on 3/29/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "MyAccountVC.h"
#import "MyAccountCell.h"
#import "ManageProfileVC.h"
#import "ManageEventsVC.h"
#import "ManagePhotosVC.h"
#import "UIImageView+AFNetworking.h"
#import "MessageHistoryVC.h"
#import "PublicProfileVC.h"
#import "MyShopsVC.h"
#import "darumble-Swift.h"

#import "FollowerVC.h"

@interface MyAccountVC ()
{
    
    __weak IBOutlet UICollectionView *_clView;
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIButton *_btnAvatar;
    CGPoint velocityF;
    CGPoint velocityL;
    
    IBOutlet UILabel *txf_user_name;
    IBOutlet UILabel *txf_city;
    IBOutlet UILabel *txf_club_name;
    IBOutlet UILabel *txf_country;
}
@end

@implementation MyAccountVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    UINib *cellNib;
    /*if (IS_IPAD) {
        cellNib = [UINib nibWithNibName:@"MyAccountCell_iPad" bundle:nil];
    }
    else*/
    {
        cellNib = [UINib nibWithNibName:@"MyAccountCell" bundle:nil];
    }
    [_clView registerNib:cellNib forCellWithReuseIdentifier:@"MyAccountCell"];
    [self addGestureRecognizers];
    
    [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,750)];
    
    [self loadAvatar];
    
    txf_user_name.text = [NSString stringWithFormat:@"%@ %@", [USER_DEFAULT objectForKey:@"fname"], [USER_DEFAULT objectForKey:@"lname"]];
    NSLog([USER_DEFAULT objectForKey:@"fname"]);
    txf_user_name.text = [txf_user_name.text isEqualToString:@" "] ? @"Name" : txf_user_name.text;
    
    
    txf_city.text = [[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"United States"] ? [USER_DEFAULT objectForKey:@"zip"] : [USER_DEFAULT objectForKey:@"city"];
    txf_city.text = [txf_city.text isEqualToString:@"(null)"] ? @"N/A" : txf_city.text;
    txf_city.text = [Common trimString:txf_city.text];
    txf_city.text = [txf_city.text isEqualToString:@""] ? @"N/A" : txf_city.text;
    txf_city.text = (txf_city.text != nil) ? txf_city.text : @"N/A";
    
    
    txf_country.text = [[USER_DEFAULT objectForKey:@"country"] isEqualToString:@"(null)"] ? @"N/A" : [USER_DEFAULT objectForKey:@"country"];
    txf_country.text = [Common trimString:txf_country.text];
    txf_country.text = [txf_country.text isEqualToString:@""] ? @"N/A" : txf_country.text;
    txf_country.text = (txf_country.text != nil) ? txf_country.text : @"N/A";
    
    
    txf_club_name.text = [[USER_DEFAULT objectForKey:@"clubName"] isEqualToString:@"(null)"] ? @"N/A" : [USER_DEFAULT objectForKey:@"clubName"];
    txf_club_name.text = [Common trimString:txf_club_name.text];
    txf_club_name.text = [txf_club_name.text isEqualToString:@""] ? @"N/A" : txf_club_name.text;
    
}

- (void)addGestureRecognizers {
    [[self view] addGestureRecognizer:[self panGestureRecognizer]];
}

-(void) loadAvatar
{
    
    UIImage *holder = [UIImage imageNamed:@"avatar.png"];
    NSLog(@"--->%@",[USER_DEFAULT objectForKey:@"photo_url"]);
    NSURL *url = [NSURL URLWithString:[USER_DEFAULT objectForKey:@"photo_url"]];
    if(url) {
        [self.imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:holder
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           self.imgAvatar.layer.cornerRadius =_btnAvatar.frame.size.width/2;
                                           self.imgAvatar.layer.masksToBounds = YES;
                                           
                                           
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           
                                       }];
    }else
    {
        self.imgAvatar.image= holder;
    }
    
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



- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.tabBarController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    AppDelegate *app = [Common appDelegate];
   
    self.tabBarController.tabBar.hidden = NO;
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    
    [app setBackgroundTarbar:PORTRAIT_ORIENTATION];
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
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return CGSizeMake(330,254);
    }
    return CGSizeMake(141,123);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MyAccountCell";
    
    MyAccountCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.btnCatAccount.tag = indexPath.row;
    [cell.btnCatAccount addTarget:self action:@selector(clickSelectCat:) forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPAD) {
        switch (indexPath.row) {
            case 0:
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_shops.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_shops_on.png"] forState:UIControlStateHighlighted];
                
                break;
            case 1:
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_photo.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_photo_on.png"] forState:UIControlStateHighlighted];
                break;
            case 2:
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_videos.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_videos_on.png"] forState:UIControlStateHighlighted];
                break;
            case 3:
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_events.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_events_on.png"] forState:UIControlStateHighlighted];
                break;
            case 4:
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_followers.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_followers_on.png"] forState:UIControlStateHighlighted];
                
                break;
            case 5:
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_garage.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setBackgroundImage:[UIImage imageNamed:@"ic_manage_garage_on.png"] forState:UIControlStateHighlighted];
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_shops.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_shops_on.png"] forState:UIControlStateHighlighted];
                
                break;
            case 1:
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_photo.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_photo_on.png"] forState:UIControlStateHighlighted];
                break;
            case 2:
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_videos.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_videos_on.png"] forState:UIControlStateHighlighted];
                break;
            case 3:
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_events.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_events_on.png"] forState:UIControlStateHighlighted];
                break;
            case 4:
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_followers.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_followers_on.png"] forState:UIControlStateHighlighted];
                break;
            case 5:
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_garage.png"] forState:UIControlStateNormal];
                [cell.btnCatAccount setImage:[UIImage imageNamed:@"ic_manage_garage_on.png"] forState:UIControlStateHighlighted];
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)clickSelectCat:(id)sender {
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 0:
        {
            MyShopsVC *vc = [[MyShopsVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
            vc.menu_type = btn.tag;
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 2:
        {
            ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
            vc.menu_type = btn.tag;
            [self.navigationController pushViewController:vc animated:YES];
            
//            SwiftInterface *inter = [[SwiftInterface alloc] init];
//            UIViewController* controller = [inter test];
//            [self.navigationController pushViewController:controller animated:NO];
        }
            break;
        case 3:
        {
            ManageEventsVC *vc = [[ManageEventsVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            /*ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
            vc.menu_type = btn.tag;
            [self.navigationController pushViewController:vc animated:YES];*/
            FollowerVC *vc = [[FollowerVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            ManagePhotosVC *vc = [[ManagePhotosVC alloc] init];
            vc.menu_type = btn.tag;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)clickSearch:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [app initSideMenu];

}
- (IBAction)clickMessages:(id)sender {
    MessageHistoryVC *vc = [[MessageHistoryVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickProfileEdit:(id)sender {
    ManageProfileVC *vc = [[ManageProfileVC alloc] initWithNibName:[NSString stringWithFormat:@"ManageProfileVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickPublicProfile:(id)sender {
    PublicProfileVC *vc = [[PublicProfileVC alloc] init];
    vc.m_userID = [[USER_DEFAULT objectForKey:@"userID"] intValue];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
