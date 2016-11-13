//
//  AboutVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 4/2/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "AboutVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
@interface AboutVC ()
{
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIImageView *_bgTopBar;
    BOOL PORTRAIT_ORIENTATION;
    CGPoint velocityF;
    CGPoint velocityL;
}
@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //---add gesture recognizers---
    [self addGestureRecognizers];
    
    //---
    [self callWS];
}

//---Functions For the Gesture---
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
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//---Memory Warning---
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---Device Orientation---
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

//---SideMenuProcess---
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

//---UI Process---
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    }];
}

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//---WebService Call---
-(void) callWS
{
    //---ProgressBar Show---
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    
    //---ProgressBar Show---
    NSString *action = @"get/about";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter= @{@"token":APP_TOKEN};
       NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"VALUE : %@",response);
        if ([[response objectForKey:@"code"] integerValue]==200)
        {
            self.tvAbout.text = [[response objectForKey:@"data"] objectForKey:@"aboutText"];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"get_garage: %@", error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}
@end
