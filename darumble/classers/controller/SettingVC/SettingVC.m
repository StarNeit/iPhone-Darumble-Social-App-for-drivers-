//
//  SettingVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/31/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "SettingVC.h"
#import "Common.h"
#import "ChangePasswordVC.h"
#import "AboutVC.h"
#import "PoliceVC.h"
#import "ContactUsVC.h"
@interface SettingVC ()
{
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIImageView *_bgTopBar;
    BOOL PORTRAIT_ORIENTATION;
    CGPoint velocityF;
    CGPoint velocityL;
    __unsafe_unretained IBOutlet UIScrollView *_scrMain;
}

@end

@implementation SettingVC
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
    [self addGestureRecognizers];
    [_scrMain setContentSize:CGSizeMake(_scrMain.frame.size.width,650)];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
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
           // [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
           // }];
            [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PORTRAIT_ORIENTATION = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (IS_IPAD) {
        _bgTopBar.image = [UIImage imageNamed:@"bg_topbar_ipad.png"];
        _bgMain.image = [UIImage imageNamed:PORTRAIT_ORIENTATION?@"background_ipad.png":@"background_landscape_ipad.png"];
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}
	
- (IBAction)clickChangePassword:(id)sender {
    ChangePasswordVC *vc = [[ChangePasswordVC alloc] initWithNibName:[NSString stringWithFormat:@"ChangePasswordVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickAbout:(id)sender {
    AboutVC *vc = [[AboutVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)doPolice:(id)sender {
    PoliceVC *vc = [[PoliceVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)doContactUs:(id)sender {
    ContactUsVC *vc = [[ContactUsVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)doLogoIpad:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.vndx.com/"]];
}


- (IBAction)clickSearch:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [app initSideMenu];
}
- (IBAction)doLogo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.vndx.com/"]];
}
@end
