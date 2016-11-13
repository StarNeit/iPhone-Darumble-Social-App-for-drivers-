//
//  AppDelegate.h
//  DaRumble
//
//  Created by Vidic Phan on 3/26/15.
//  Copyright (c) 2015 DaRumble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/CloudMessaging.h>
#import "MFSideMenuContainerViewController.h"
#import "SideMenuVC.h"

@interface AppDelegate : UIResponder <GGLInstanceIDDelegate, GCMReceiverDelegate, UIApplicationDelegate, UITabBarControllerDelegate>
{
    MFSideMenuContainerViewController *container;   //MainRootVC( = leftSideMenuVC + TabBarController)
    SideMenuVC *leftMenuViewController; //leftSideMenuVC
    UINavigationController *_navi1;     //HomeVC
    UINavigationController *_navi2;     //EventVC
    UINavigationController *_navi3;     //GalleryVC
    UINavigationController *_navi4;     //ShopVC
    UINavigationController *_navi5;     //MyAccountVC
    UINavigationController *_navi6;     //SearchItemsVC
    UINavigationController *navi;       //
    UINavigationController *naviLogin;
    UITabBarController *tabar;          //TabBarController
    UINavigationController *naviSetting;
    MFSideMenuContainerViewController *containerSetting;
}

@property (strong, nonatomic) UIWindow *window;
- (void) initSideMenu;
- (void) findRumbler;
- (void) initTabbar;
- (void) initLogin;
- (void) closeLogin;
- (void) openTabbar:(int)_tab;
- (void) goToSearchRumbler;
- (void) initSetting;
- (void) setBackgroundTarbar:(BOOL) PORTRAIT_ORIENTATION;
- (void) disableTabbar;
- (void) enableTabbar;
- (void) showSearchItems;
- (void) showMessages;
- (void) authenticateVimeo;

@property(nonatomic,assign) BOOL isEditProfielMenu;
@property(nonatomic,assign) int isRumbler;
@property(nonatomic,assign) int msg_redir;
@property(nonatomic,retain) SideMenuVC *sideMenu;

//---GCM---
@property(nonatomic, readonly, strong) NSString *registrationKey;
@property(nonatomic, readonly, strong) NSString *messageKey;
@property(nonatomic, readonly, strong) NSString *gcmSenderID;
@property(nonatomic, readonly, strong) NSDictionary *registrationOptions;
@property(nonatomic, strong) NSString* registrationToken;
@property BOOL restrictRotation;
@end


