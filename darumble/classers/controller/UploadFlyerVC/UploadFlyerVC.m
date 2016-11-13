//
//  GalleryVC.m
//  DaRumble
//
//  Created by Phan Minh Tam on 3/28/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "UploadFlyerVC.h"
#import "SearchItemsVC.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"

@interface UploadFlyerVC ()<UIGestureRecognizerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate>
{
    BOOL PORTRAIT_ORIENTATION;
    __weak IBOutlet UIImageView *_bgTopBar;
    __weak IBOutlet UIImageView *_bgMain;
    CGPoint velocityF;
    CGPoint velocityL;
    
    __weak  IBOutlet UIImageView *imgPhoto;
    UIImage *imageChoosePicker;
}
@end

@implementation UploadFlyerVC
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
    
    if (![self.flyerURL isEqualToString:@""] && self.flyerURL != nil)
    {
        NSURL *url = [NSURL URLWithString: self.flyerURL];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imgPhoto.image = image;
                    });
                }
            }
        }];
        [task resume];
    }else{
        imgPhoto.image = [UIImage imageNamed:@"drlogo2.png"];
    }
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
//         AppDelegate *app = [Common appDelegate];
//         [app initSideMenu];
             [self.navigationController popViewControllerAnimated:YES]; 
         }
    }
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


- (IBAction)doPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:picker animated:YES completion:nil];
            });
            
        }else if (buttonIndex == 1)
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:picker animated:YES completion:nil];
            });
        }
    }
}



#pragma mark - imagepicker controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        imgPhoto.image = [info valueForKey:UIImagePickerControllerEditedImage];
        imgPhoto.tag = 501;
        imageChoosePicker  =  [info valueForKey:UIImagePickerControllerEditedImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadFlyer:(id)sender {
    if (imgPhoto.tag == 500)
    {
        [Common showAlert:@"Select flyer image"];
        return;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger mounth = [components month];
    NSInteger year = [components year];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    NSString *imgName = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld.png", (long)day, (long)mounth, (long)year, (long)hour, (long)minutes, (long)seconds];
    
    [self uploadImage:imgName];
}

-(void) uploadImage:(NSString *) imageName
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Waiting..." animated:YES];
    //NSData *imageToUpload = UIImageJPEGRepresentation(imgPhoto.image, 1.0);
    NSData *imageToUpload = UIImageJPEGRepresentation([Common resizeImage:imgPhoto.image], 0.0);
    
    if (imageToUpload)
    {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:APP_TOKEN, @"token", nil];
        
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://test-api.darumble.com"]];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://test-api.darumble.com/api/upload/photo/" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            [formData appendPartWithFileData: imageToUpload name:@"imagedata" fileName:[NSString stringWithFormat:@"%@.jpeg",imageName] mimeType:@"image/jpeg"];
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"response: %@",jsons);
             if ([[jsons objectForKey:@"code"] integerValue]==200)
             {
                 NSLog(@"----->%@",[[jsons objectForKey:@"data"] objectForKey:@"photoID"]);
                 
                 int flyerID = [[[jsons objectForKey:@"data"] objectForKey:@"photoID"] intValue];
                 
                 [self.delegate addItemViewController:self didFinishEnteringItem:imageName flyer_id:flyerID];
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
             }
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             if([operation.response statusCode] == 403)
             {
                 return;
             }
             
         }];
        
        [operation start];
    }
}
@end
