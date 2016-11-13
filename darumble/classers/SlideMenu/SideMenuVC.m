//
//  SideMenuVC.m
//  Sufi 2.0
//
//  Created by Vidic Phan on 5/20/13.
//  Copyright (c) 2013 KGP. All rights reserved.
//

#import "SideMenuVC.h"
#import "AppDelegate.h"
#import "HomeVC.h"
#import "SettingVC.h"
#import "ManageProfileVC.h"
#import "UIImageView+AFNetworking.h"
#import "SearchItemsVC.h"

@interface SideMenuVC ()
{
    
    __weak IBOutlet UIScrollView *_scrMenu;
    __weak IBOutlet UIButton *_btnAvatar;
    CGPoint velocityF;
    CGPoint velocityL;
}
@end

@implementation SideMenuVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

- (void)viewDidLoad
{
    NSLog(@"Load SideMenu");
    [Common appDelegate].sideMenu = self;
    [super viewDidLoad];
    [_scrMenu setContentSize:CGSizeMake(10, 750)];
    
    [self loadAvatar];
    [self addGestureRecognizers];
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


-(void) loadAvatar
{
    UIImage *holder = [UIImage imageNamed:@"avatar.png"];
    NSLog(@"--->%@",[USER_DEFAULT objectForKey:@"photo_url"]);
    NSURL *url = [NSURL URLWithString:[USER_DEFAULT objectForKey:@"photo_url"]];
    if(url) {
        [self.imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                          placeholderImage:holder
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
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
}

//---Open GlobalFeed VC---
- (IBAction)clickGlobalFeed:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openTabbar:0];
    }];
}

//---Open LocalFeed VC---
- (IBAction)clickLocalFeed:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openTabbar:1];
    }];
}

//---Open Messages VC---
- (IBAction)clickMessages:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openTabbar:3];
    }];
}

//---Open FindRumblers VC---
- (IBAction)clickFindRumblers:(id)sender {
    AppDelegate *app = [Common appDelegate];
    app.isRumbler = 20;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app findRumbler];
    }];
}

//---Open MyAccount VC---
- (IBAction)clickMyAccount:(id)sender {
    AppDelegate *app = [Common appDelegate];
    app.isEditProfielMenu = YES;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openTabbar:4];
    }];
}

//---Open Settings VC---
- (IBAction)clickSettings:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app initSetting];
    }];
}

//---LogOut---
- (IBAction)clickLogOut:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [USER_DEFAULT setValue:@"0" forKey:@"DaRumble_Login"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@""];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [Common logoutUser];
    [app openTabbar:2];
    [app initLogin];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}
@end
