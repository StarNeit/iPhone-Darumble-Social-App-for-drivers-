//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "EditVideoVC.h"
#import "SearchItemsVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"

#import "YTVimeoExtractor.h"
#import <MediaPlayer/MediaPlayer.h>

@interface EditVideoVC ()<UIGestureRecognizerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    
    IBOutlet UIImageView *img_video_thumbnail;
    IBOutlet UITextField *txf_title;
    IBOutlet UITextView *tv_description;
}
@end

@implementation EditVideoVC
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
    
    if (IS_IPAD)
    {
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,2000)];
    }else{
        [self._srcMain setContentSize:CGSizeMake(self._srcMain.frame.size.width,1000)];
    }
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [__srcMain addGestureRecognizer:singleTap];
    
    //---Video Detail Image---
    UIImage *holder = [UIImage imageNamed:@"drlogo.png"];
    NSURL *url = [NSURL URLWithString:self.photoObj.videoThumbnailURL];
    if(url)
    {
        [img_video_thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                   placeholderImage:holder
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             img_video_thumbnail.contentMode = UIViewContentModeScaleAspectFill;
             img_video_thumbnail.clipsToBounds = YES;
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             img_video_thumbnail.image = holder;
         }];
    }else
    {
        img_video_thumbnail.image = holder;
    }
    
    //---title---
    txf_title.text = self.photoObj.title;
    
    //---description---
    tv_description.text = self.photoObj.des;
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


- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    // Close keyboard for any text edit views that are children of the main view
    [gestureRecognizer.view endEditing:YES];
}


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

- (IBAction)clickVideoPlay:(id)sender {
    [[YTVimeoExtractor sharedExtractor]fetchVideoWithVimeoURL:self.photoObj.URL withReferer:nil completionHandler:^(YTVimeoVideo * _Nullable video, NSError * _Nullable error) {        
        if (video) {
            NSURL *highQualityURL = [video lowestQualityStreamURL];
            MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:highQualityURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
        }else{
            [Common showAlert:@"Video is finalizing"];
        }
    }];
}
- (IBAction)clickEditVideo:(id)sender {
   
    txf_title.text = [Common trimString:txf_title.text];
    tv_description.text = [Common trimString:tv_description.text];
    if (txf_title.text.length == 0)
    {
        [Common showAlert:@"Video title is empty"];
        return;
    }
    if (tv_description.text.length == 0)
    {
        [Common showAlert:@"Video description is empty"];
        return;
    }
    
    //---WS API Call(Edit Video)---
    [self removeNotifi];
    [self addNotifi];
        
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    DataCenter *ws = [[DataCenter alloc] init];
    [ws edit_video2:APP_TOKEN description:tv_description.text title:txf_title.text videoID:self.photoObj.id];
}


//*******************************//
//*          WEBSERVICE         *//
//*******************************//

//---VIP User Login---
- (void)addNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EditVideo_Success:) name:k_edit_video_success2 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EditVideo_Fail:) name:k_edit_video_fail2 object:nil];
}
- (void)removeNotifi
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_video_success2 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_edit_video_fail2 object:nil];
}
-(void) EditVideo_Success:(NSNotification*)notif
{
    NSDictionary *dic = notif.object;
#if DEBUG
    NSLog(@"EditVideo_Success %@",dic);
#endif
    if ([[dic objectForKey:@"code"] intValue] == 200)
    {
        if ([[dic objectForKey:@"data"] objectForKey:@"result"] != [NSNull null])
        {
            [Common showAlert:@"Successfully video edited."];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            
            [Common showAlert:@"There was a problem when retriving data from database."];
        }
    }else
    {
        [Common showAlert:[[dic objectForKey:@"data"] objectForKey:@"Errors"]];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
-(void) EditVideo_Fail:(NSNotification*)notif
{
    NSLog(@"EditVideo_Fail %@",notif);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self removeNotifi];
}
@end
