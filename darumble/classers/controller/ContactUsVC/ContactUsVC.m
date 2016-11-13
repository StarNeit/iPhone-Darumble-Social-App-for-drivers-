//
//  ContactUsVC.m
//  DaRumble
//
//  Created by Colin on 5/12/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "ContactUsVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
@interface ContactUsVC ()<UITextViewDelegate>
{
    __weak IBOutlet UIImageView *_bgMain;
    __weak IBOutlet UIImageView *_bgTopBar;
    BOOL PORTRAIT_ORIENTATION;
    CGPoint velocityF;
    CGPoint velocityL;
}
@end

@implementation ContactUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGestureRecognizers];
    [_scrollPage setContentSize:CGSizeMake(_scrollPage.frame.size.width,500)];
    // Do any additional setup after loading the view from its nib.
    
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap1:)];
    singleTap1.cancelsTouchesInView = NO;
    singleTap1.delegate = self;
    
    [_scrollPage addGestureRecognizer:singleTap1];
}

//---Gesture Recognizer---
- (void)singleTap1:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
    [self.scrollPage setContentOffset:CGPointMake(0, 0) animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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

- (IBAction)clickSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)doSend:(id)sender {
    if (_tvMessage.text.length ==0) {
        [Common showAlert:@"Message is required"];
        [_tvMessage becomeFirstResponder];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    NSString *action = @"/user/contact/";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter= @{@"userID":[USER_DEFAULT objectForKey:@"userID"],@"comment":_tvMessage.text,@"token":APP_TOKEN};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"VALUE : %@",response);
        if ([[response objectForKey:@"code"] integerValue]==200) {
            [Common showAlert:@"Your message was sent successfully!"];
            _tvMessage.text =@"";
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_garage: %@", error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];

}

- (void)textViewDidChange:(UITextView *)textView{
    self.lblHideMessage.hidden =textView.text.length;
}
@end
