//
//  AppDelegate.m
//  DaRumble
//
//  Created by Vidic Phan on 3/26/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"
#import "Define.h"
#import "GlobalFeedVC.h"
#import "LocalFeedVC.h"
#import "LoginVC.h"
#import "MyAccountVC.h"
#import "SettingVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FacebookUtility.h"
#import "ManageProfileVC.h"
#import "MessageHistoryVC.h"
#import "SearchItemsVC.h"
#import "darumble-Swift.h"
#import "VIMNetworking.h"

@interface AppDelegate ()
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, assign) BOOL subscribedToTopic;
@end

NSString *const SubscriptionTopic = @"/topics/global";

@implementation AppDelegate NSString *const FBSessionStateChangedNotification = @"com.facebook.samples.DaRumble:FBSessionStateChangedNotification";

// called from AppDelegate didFinishLaunchingWithOptions:
- (void)configureVimeo
{
    VIMSessionConfiguration *config = [[VIMSessionConfiguration alloc] init];
    config.clientKey = @"7db3dd3681fdc18752869d0fbf10dd325dc2cb53";
    config.clientSecret = @"KyhUDmLimBkv05JRSDjZE1IPIyevDy7ZOpCF5WmzARUYtBMfdm2xPWAEelOLCH/+uVWHcEE/NaoaRGq3gD1tpkXJuACRmAeMn6OokmoRNv473usCEL6ABgGfWiQrqE5g";
    config.scope = @"public private purchased create edit delete interact upload"; // E.g. "private public upload etc"
    config.keychainService = @"abcd";
    
    [VIMSession setupWithConfiguration:config];
}

// authenticate - called in previous tableView controller prior to arriving at videos list tableview controller
- (void)authenticateVimeo
{
    NSLog(@">>> Entering %s <<<", __PRETTY_FUNCTION__);
    
    if ([[VIMSession sharedSession].account isAuthenticated] == NO)
    {
        [[VIMSession sharedSession] authenticateWithClientCredentialsGrant:^(NSError *error) {
            if (error == nil)
            {
                NSLog(@"Success!");
//                [Common showAlert:@"11- authenticateWithClientCredentialsGrant Success!"];//-------
            } else
            {
                NSLog(@"Failure: %@", error);
//                [Common showAlert:[NSString stringWithFormat:@"12- authenticateWithClientCredentialsGrant %@",error ]];//-------
            }
        }];
    }else
    {
        NSLog(@"-->Vimeo Session isAuthenticated: %d", [[VIMSession sharedSession].account isAuthenticated]);
//        [Common showAlert:[NSString stringWithFormat:@"13- -->Vimeo Session isAuthenticated: %d", [[VIMSession sharedSession].account isAuthenticated]]];//-------
    }
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(!self.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self initSideMenu];
    //************************//
    //*         Vimeo        *//
    //************************//
    
    SwiftInterface *inter = [[SwiftInterface alloc] init];
    [inter setNotifications:application];
    
    [self configureVimeo];
    [self authenticateVimeo];

    
    //************************//
    //*         GCM          *//
    //************************//
    
    // [START_EXCLUDE]
     _registrationKey = @"onRegistrationCompleted";
     _messageKey = @"onMessageReceived";
    
    
     // Configure the Google context: parses the GoogleService-Info.plist, and initializes
     // the services that have entries in the file
     NSError* configureError;
     [[GGLContext sharedInstance] configureWithError:&configureError];
     NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
     _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    
    
     // Register for remote notifications
     if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
     {
         // iOS 7.1 or earlier
         UIRemoteNotificationType allNotificationTypes =
         (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
         [application registerForRemoteNotificationTypes:allNotificationTypes];
     } else
     {
         // iOS 8 or later
         // [END_EXCLUDE]
         UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
         UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
         [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
         [[UIApplication sharedApplication] registerForRemoteNotifications];
     }
    
    
     // [END register_for_remote_notifications]
     // [START start_gcm_service]
     GCMConfig *gcmConfig = [GCMConfig defaultConfig];
     gcmConfig.receiverDelegate = self;
     [[GCMService sharedInstance] startWithConfig:gcmConfig];
    
    
    
     // [END start_gcm_service]
     __weak typeof(self) weakSelf = self;
    
    
     // Handler for registration token request
     _registrationHandler = ^(NSString *registrationToken, NSError *error)
    {
     if (registrationToken != nil)
     {
         weakSelf.registrationToken = registrationToken;
         [USER_DEFAULT setValue:registrationToken forKey:@"registrationToken"];
         NSLog(@"Registration Token: %@", registrationToken);
         //[Common showAlert:registrationToken];
//         [Common showAlert:@"Notification installed successfully"];
         [weakSelf subscribeToTopic];
         NSDictionary *userInfo = @{@"registrationToken":registrationToken};
         [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                             object:nil
                                                           userInfo:userInfo];
     } else
     {
         NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
         NSDictionary *userInfo = @{@"error":error.localizedDescription};
         [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                             object:nil
                                                           userInfo:userInfo];
         [USER_DEFAULT setValue:@"" forKey:@"registrationToken"];
         [Common showAlert:registrationToken];
     }
    };
    
    
    
    //************************//
    //*         FB           *//
    //************************//
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // attempt to extract a token from the url(FB)
    [FBAppCall handleOpenURL:url
           sourceApplication:sourceApplication
                 withSession:[FacebookUtility sharedObject].session];
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}
/*
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
 annotation:(id)annotation
 {
 // attempt to extract a token from the url(FB)
     [FBAppCall handleOpenURL:url
            sourceApplication:sourceApplication
                  withSession:[FacebookUtility sharedObject].session];
     
     return true;
 }*/

- (void) closeSession
{
    [[FBSession activeSession] closeAndClearTokenInformation];
}


- (void) initSideMenu
{
    NSLog(@"initSideMenu");
    
    //---1) INITIALIZE TABBAR---
    [self initTabbar];
    //---2) INITIALIZE LEFTMENUVC---
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:[NSString stringWithFormat:@"SideMenuVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
    
    
    //---SETTING MAIN ROOTVC AS CONTAINER(TABBAR + LEFTMENUVC)---
    container = [MFSideMenuContainerViewController
                 containerWithCenterViewController:tabar
                 leftMenuViewController:leftMenuViewController
                 rightMenuViewController:nil];
    
    //---SETTING ROOTVC---
    self.window.rootViewController = container;
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self homeController]];
}

- (HomeVC *)homeController {
    if (IS_IPAD) {
        return [[HomeVC alloc] initWithNibName:@"HomeVC_iPad" bundle:nil];
    }
    else
    {
        return [[HomeVC alloc] init];
    }
}

- (void) initTabbar
{
    NSLog(@"initTabbar");
    //-----INITIALIZE VC VARIABLES------
    
    //---1) HOMEVC---
    HomeVC *controller1;
    if (IS_IPAD)
    {
        controller1  = [[HomeVC alloc] initWithNibName:@"HomeVC_iPad" bundle:nil];
    }
    else
    {
        controller1  = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
    }
    _navi1 = [[UINavigationController alloc] initWithRootViewController:controller1];
    
    //---2) LocalFeedVC---
    LocalFeedVC *controller2 = [[LocalFeedVC alloc] init];
    _navi2 = [[UINavigationController alloc] initWithRootViewController:controller2];
    
    //---3) GlobalFeedVC---
    GlobalFeedVC *controller3 = [[GlobalFeedVC alloc] initWithNibName:[NSString stringWithFormat:@"GlobalFeedVC%@", IS_IPAD?@"~ipad":@""] bundle:nil];
    _navi3 = [[UINavigationController alloc] initWithRootViewController:controller3];
    
    //---4) SHOPVC---
    MessageHistoryVC *controller4 = [[MessageHistoryVC alloc] init];
    _navi4 = [[UINavigationController alloc] initWithRootViewController:controller4];
    
    //---5) MYACCOUNTVC---
    MyAccountVC *controller5 = [[MyAccountVC alloc] initWithNibName:[NSString stringWithFormat:@"MyAccountVC"] bundle:nil];
    _navi5 = [[UINavigationController alloc] initWithRootViewController:controller5];
    
    tabar = [[UITabBarController alloc] init];
    tabar.viewControllers = [NSArray arrayWithObjects:_navi3,_navi2,_navi1,_navi4,_navi5, nil];
    tabar.selectedIndex = 2;
    [tabar setDelegate:self];
    
    
    
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    UITabBar *tabBar = tabar.tabBar;
    
    //------1) SETTING ABOUT FIRST TABBAR IMAGE (GLOBAL FEED)------
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    item0.selectedImage = [[UIImage imageNamed:@"ic_tabbar_global_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.image = [[UIImage imageNamed:@"ic_tabbar_global.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    //------2) SETTING ABOUT SECOND TABBAR IMAGE (LOCAL FEED)------
    item0 = [tabBar.items objectAtIndex:1];
    item0.selectedImage = [[UIImage imageNamed:@"ic_tabbar_local_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.image = [[UIImage imageNamed:@"ic_tabbar_local.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    //------3) SETTING ABOUT THIRD TABBAR IMAGE (MESSAGES)------
    item0 = [tabBar.items objectAtIndex:3];
    item0.selectedImage = [[UIImage imageNamed:@"ic_tabbar_messages_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.image = [[UIImage imageNamed:@"ic_tabbar_messages.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    //------4) SETTING ABOUT FORTH TABBAR IMAGE (MY ACCOUNT)------
    item0 = [tabBar.items objectAtIndex:4];
    item0.selectedImage = [[UIImage imageNamed:@"ic_tabbar_my_account_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.image = [[UIImage imageNamed:@"ic_tabbar_my_account.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    item0.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) initLogin
{
    if (naviLogin) {
        self.window.rootViewController = naviLogin;
    }else
    {
        LoginVC *vc = [[LoginVC alloc] initWithNibName:[NSString stringWithFormat:@"LoginVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
        naviLogin = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = naviLogin;
    }
}

- (void) closeLogin
{
    self.window.rootViewController = container;
}

- (void) openTabbar:(int)_tab
{
    self.restrictRotation = false;
    
    self.window.rootViewController = container;
    tabar.selectedIndex = _tab;
    
    NSLog([NSString stringWithFormat:@"%d",tabar.selectedIndex]);
    
    switch (_tab) {
        case 0:
            [_navi3 popToRootViewControllerAnimated:NO];
            NSLog(@"tck - 0");
            break;
        case 1:
            [_navi2 popToRootViewControllerAnimated:NO];
            NSLog(@"tck - 1");
            break;
        case 2:
            [_navi1 popToRootViewControllerAnimated:NO];
            NSLog(@"tck - 2");
            break;
        case 3:
            [_navi4 popToRootViewControllerAnimated:NO];
            break;
        case 4:
        {
            //            MyAccountVC *vc = [[MyAccountVC alloc] init];
            //            [self.navigationController pushViewController:vc animated:YES];
            NSLog(@"tck - 4");
            [_navi5 popToRootViewControllerAnimated:NO];
            break;
        }
            /*
             if (self.isEditProfielMenu)
             {
             
             // [_navi5 popToRootViewControllerAnimated:NO];
             self.isEditProfielMenu = NO;
             ManageProfileVC *vc = [[ManageProfileVC alloc] initWithNibName:[NSString stringWithFormat:@"ManageProfileVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
             [(UINavigationController *) tabar.selectedViewController pushViewController:vc animated:NO];
             }
             else
             {
             [_navi5 popToRootViewControllerAnimated:NO];
             }*/
            break;
        default:
            break;
    }
}


- (void) initSetting
{
//    if (containerSetting)
//    {
//        self.window.rootViewController = containerSetting;
//        [naviSetting popToRootViewControllerAnimated:NO];
//    }
//    else
    {
        leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
        SettingVC *vc =[[SettingVC alloc] initWithNibName:IS_IPAD?@"SettingVC_iPad":@"SettingVC" bundle:[NSBundle mainBundle]];
        naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
        containerSetting = [MFSideMenuContainerViewController
                            containerWithCenterViewController:naviSetting
                            leftMenuViewController:leftMenuViewController
                            rightMenuViewController:nil];
        self.window.rootViewController = containerSetting;
    }
}

- (void) showSearchItems
{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    SearchItemsVC *search_vc =[[SearchItemsVC alloc] initWithNibName:@"SearchItemsVC" bundle:[NSBundle mainBundle]];
    naviSetting = [[UINavigationController alloc] initWithRootViewController:search_vc];
    containerSetting = [MFSideMenuContainerViewController
                        containerWithCenterViewController:naviSetting
                        leftMenuViewController:leftMenuViewController
                        rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}

- (void) findRumbler
{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    SearchItemsVC *vc =[[SearchItemsVC alloc] initWithNibName:@"SearchItemsVC" bundle:[NSBundle mainBundle]];
    naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    containerSetting = [MFSideMenuContainerViewController
                            containerWithCenterViewController:naviSetting
                            leftMenuViewController:leftMenuViewController
                            rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}

- (void) showMessages
{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    MessageHistoryVC *message_vc =[[MessageHistoryVC alloc] initWithNibName:@"MessageHistoryVC" bundle:[NSBundle mainBundle]];
    naviSetting = [[UINavigationController alloc] initWithRootViewController:message_vc];
    containerSetting = [MFSideMenuContainerViewController
                        containerWithCenterViewController:naviSetting
                        leftMenuViewController:leftMenuViewController
                        rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}

- (void) setBackgroundTarbar:(BOOL) PORTRAIT_ORIENTATION
{
    [[tabar tabBar] setBackgroundImage:[UIImage imageNamed:IS_IPAD?(PORTRAIT_ORIENTATION?@"bg_tabbar_ipad.png":@"bg_tabbar_landscape_ipad.png"):(PORTRAIT_ORIENTATION?@"bg_tabbar.png":([UIScreen mainScreen].bounds.size.width == 568.0?@"bg_tabbar_landscape_568h.png":@"bg_tabbar_landscape.png"))]];
}

- (void) disableTabbar
{
    [[[[tabar tabBar]items]objectAtIndex:0]setEnabled:NO];
    [[[[tabar tabBar]items]objectAtIndex:3]setEnabled:NO];
    [[[[tabar tabBar]items]objectAtIndex:4]setEnabled:NO];
}

- (void) enableTabbar
{
    [[[[tabar tabBar]items]objectAtIndex:0]setEnabled:YES];
    [[[[tabar tabBar]items]objectAtIndex:3]setEnabled:YES];
    [[[[tabar tabBar]items]objectAtIndex:4]setEnabled:YES];
}



//************************//
//*         GCM          *//
//************************//
 - (void)subscribeToTopic
{
 // If the app has a registration token and is connected to GCM, proceed to subscribe to the
 // topic
 if (_registrationToken && _connectedToGCM)
 {
     [[GCMPubSub sharedInstance] subscribeWithToken:_registrationToken
                                              topic:SubscriptionTopic
                                            options:nil
                                            handler:^(NSError *error) {
                                                if (error) {
                                                    // Treat the "already subscribed" error more gently
                                                    if (error.code == 3001) {
                                                        NSLog(@"Already subscribed to %@",
                                                              SubscriptionTopic);
                                                    } else {
                                                        NSLog(@"Subscription failed: %@",
                                                              error.localizedDescription);
                                                    }
                                                } else {
                                                    self.subscribedToTopic = true;
                                                    NSLog(@"Subscribed to %@", SubscriptionTopic);
                                                }
                                            }];
    }
 }
 
 // [START connect_gcm_service]
 - (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Connect to the GCM server to receive non-APNS notifications
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
    if (error)
    {
        NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
    } else
    {
        _connectedToGCM = true;
        NSLog(@"Connected to GCM");
        // [START_EXCLUDE]
        [self subscribeToTopic];
        // [END_EXCLUDE]
    }
 }];
}
// [END connect_gcm_service]



 // [START disconnect_gcm_service]
 - (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[GCMService sharedInstance] disconnect];
    // [START_EXCLUDE]
    _connectedToGCM = NO;
    // [END_EXCLUDE]
}
 // [END disconnect_gcm_service]
 
 
 // [START receive_apns_token]
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // [END receive_apns_token]
    // [START get_gcm_reg_token]
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
 
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
 
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
 
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                              kGGLInstanceIDAPNSServerTypeSandboxOption:@NO};
 
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
 // [END get_gcm_reg_token]
 }
 
 
 // [START receive_apns_token_error]
 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
 {
     NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
     // [END receive_apns_token_error]
     NSDictionary *userInfo = @{@"error" :error.localizedDescription};
     [[NSNotificationCenter defaultCenter] postNotificationName:_registrationKey
                                                         object:nil
                                                       userInfo:userInfo];
 }
 
 // [START ack_message_reception]
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 {
     NSLog(@"Notification received: %@", userInfo);
     // This works only if the app started the GCM service
     [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
     // Handle the received message
     // [START_EXCLUDE]
     [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                         object:nil
                                                       userInfo:userInfo];
     // [END_EXCLUDE]
     
//     [Common showAlert:@"didReceiveRemoteNotification1"];
 }
 
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler
 {
     NSLog(@"Notification received: %@", userInfo);
     // This works only if the app started the GCM service
     [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
     
     // Handle the received message
     // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
     // [START_EXCLUDE]
     [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                         object:nil
                                                       userInfo:userInfo];
     handler(UIBackgroundFetchResultNoData);
     // [END_EXCLUDE]
     
//     [Common showAlert:@"didReceiveRemoteNotification2"];
 }
 // [END ack_message_reception]
 
 // [START on_token_refresh]
 - (void)onTokenRefresh
{
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSLog(@"The GCM registration token needs to be changed.");
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}
 // [END on_token_refresh]
 
 // [START upstream_callbacks]
- (void)willSendDataMessageWithID:(NSString *)messageID error:(NSError *)error
{
     if (error) {
         // Failed to send the message.
     } else {
         // Will send message, you can save the messageID to track the message
     }
}
 
 - (void)didSendDataMessageWithID:(NSString *)messageID
{
    // Did successfully send message identified by messageID
}
 // [END upstream_callbacks]
 
 - (void)didDeleteMessagesOnServer
{
    // Some messages sent to this device were deleted on the GCM server before reception, likely
    // because the TTL expired. The client should notify the app server of this, so that the app
    // server can resend those messages.
}


//---vimeo process---
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    SwiftInterface *inter = [[SwiftInterface alloc] init];
    [inter backgroundProcess:(NSString*)identifier completionHandler:(void (^)())completionHandler];
}
 
@end
