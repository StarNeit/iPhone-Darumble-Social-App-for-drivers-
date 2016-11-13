//
//  UserObj.h
//  SmarkKid
//
//  Created by Phan Minh Tam on 3/22/14.
//  Copyright (c) 2014 SDC. All rights reserved.
//

#import <Foundation/Foundation.h>

/*============================================================================
 DECLARE CLASS NAME
 =============================================================================*/
@interface DataCenter : NSObject
{
}
-(void)add_user:(NSString*)token username:(NSString*)username fname:(NSString*)fname lname:(NSString*)lname email:(NSString*)email password:(NSString*)password repassword:(NSString*)repassword age:(int)age terms_agreed:(NSString*)terms_agreed phone:(NSString*)phone zip:(NSString*)zip clubName:(NSString*)clubName andCountry:(NSString *) country andType:(int) type;
-(void)edit_user:(NSString*)token userID:(int)userID username:(NSString*)username fname:(NSString*)fname lname:(NSString*)lname email:(NSString*)email password:(NSString*)password repassword:(NSString*)repassword age:(int)age phone:(NSString*)phone zip:(NSString*)zip clubName:(NSString*)clubName andCountry:(NSString *) country andType:(int) type;

-(void)get_users:(NSString*)token userID:(int)userID;
-(void)get_categories:(NSString*)token;

#pragma mark - Vehicle
-(void)get_vehicle:(NSString*)token;
-(void)add_vehicle:(NSString*)token userID:(int)userID type:(NSString*)type make:(NSString*)make model:(NSString*)model categoryID:(NSString*)categoryID year:(NSString*)year description:(NSString*)description;
-(void)edit_vehicle:(NSString*)token userID:(int)userID type:(NSString*)type make:(NSString*)make model:(NSString*)model categoryID:(NSString*)categoryID year:(NSString*)year description:(NSString*)description vehicleID:(NSString*)vehicleID;
-(void)get_vehicle:(NSString*)token vehicleID:(NSString*)vehicleID;
-(void)remove_vehicle:(NSString*)token vehicleID:(NSString*)vehicleID;

#pragma mark - Garage
-(void)get_garage:(NSString*)token andFillter:(NSString *) fillter andTypeManager:(int) type;
-(void)add_garage:(NSString*)token userID:(int)userID date:(NSString*)date terms:(NSString*)terms isShop:(int)isShop categoryID:(NSString*)categoryID website:(NSString*)website shopName:(NSString*)shopName zip:(NSString*)zip phone:(NSString*)phone address:(NSString*)address email:(NSString*)email;
-(void)edit_garage:(NSString*)token userID:(int)userID date:(NSString*)date terms:(NSString*)terms isShop:(int)isShop categoryID:(NSString*)categoryID website:(NSString*)website shopName:(NSString*)shopName zip:(NSString*)zip phone:(NSString*)phone address:(NSString*)address email:(NSString*)email garageID:(int)garageID;
-(void)get_garage:(NSString*)token garageID:(NSString*)garageID;
-(void)remove_garage:(NSString*)token garageID:(NSString*)garageID;

#pragma mark - Photo
-(void)get_photo:(NSString*)token isGallery:(int)isGallery;
-(void)get_photoTab;
-(void)remove_photo:(NSString*)token photoID:(NSString*)photoID;

#pragma mark - Video
-(void)get_video:(NSString*)token;
-(void)get_videoTab;
-(void)remove_video:(NSString*)token videoID:(NSString*)videoID;
-(void)add_video:(NSString*)token url:(NSString*)url uid:(int)uid description:(NSString*)description catid:(NSString*)catid title:(NSString*)title thumbnail:(NSString*)thumbnail zip:(NSString*)zip country:(NSString*)country eventID:(int)eventID;
-(void)edit_video:(NSString*)token url:(NSString*)url uid:(int)uid description:(NSString*)description catid:(NSString*)catid tags:(NSString*)tags videoID:(int)videoID;
//http://test-api.darumble.com/api/new/edit/video?token=capitol-es-are-dev&title=test30&description=test32&id=224
-(void)edit_video2:(NSString*)token description:(NSString*)description title:(NSString*)title videoID:(int)videoID;

#pragma mark - Events
-(void)get_event:(NSString*)token;
-(void)get_event_not_user:(NSString*)tokens;
-(void)remove_event:(NSString*)token eventID:(NSString*)eventID;

#pragma mark User

-(void)login:(NSString*)token username:(NSString*)username password:(NSString*)password registration_key:(NSString*)registration_key;
-(void)loginfb:(NSString*)fb_id fb_email:(NSString*)fb_email fb_fname:(NSString*)fb_fname fb_lname:(NSString*)fb_lname fb_age:(NSString *) fb_age fb_zipcode:(NSString *) fb_zipcode fb_phone:(NSString *) phone registration_key:(NSString*)registration_key;
-(void)forgot_password:(NSString*)token email:(NSString*)email;
-(void)searchTerms:(NSString*)token searchTerms:(NSString*)searchTerms parentCategoryID:(NSString*)parentCategoryID subCategoryID:(NSString*)subCategoryID;
- (void) uploadPhoto:(NSString*)token andUserID:(NSString*)userID andCategoryID:(NSString*)categoryID andDescription:(NSString*)description andImageData:(NSString*)imageData;
- (void) uploadPhoto:(NSString*)token andUserID:(NSString*)userID andCategoryID:(NSString*)categoryID garageID:(NSString*)garageID andImageData:(NSString*)imageData;



//---New WS API---
#pragma mark - User Public Profile
-(void)load_public_profile:(NSString*)token userID:(int)userID;

#pragma mark - Load Global Feed
-(void)load_global_feed:(NSString*)token;
-(void)load_local_feed:(NSString*)token geolocation:(NSString*)geolocation zip:(NSString*)zip userID:(int)userID;

#pragma mark - Load Global Photo Content / Photo Detail
-(void)load_global_photos:(NSString*)token userID:(int)userID;
-(void)get_photo_details:(NSString*)token photoID:(int)photoID userID:(int)userID;

#pragma mark - Load Global Event Content / Event Detail
-(void)load_global_events:(NSString*)token userID:(int)userID;
-(void)get_event_details:(NSString*)token eventID:(int)eventID userID:(int)userID;

#pragma mark - Load Global Vehicle Content / Vehicle Detail
-(void)load_global_vehicles:(NSString*)token userID:(int)userID;
-(void)get_vehicle_details:(NSString*)token vehicleID:(int)vehicleID userID:(int)userID;

#pragma mark - Load Global Shop Content / Shop Detail
-(void)load_global_shops:(NSString*)token;
-(void)get_shop_details:(NSString*)token shopID:(int)shopID userID:(int)userID;

#pragma mark - Load Global Video Content / Video Detail
-(void)load_global_videos:(NSString*)token userID:(int)userID;
-(void)get_video_details:(NSString*)token videoID:(int)videoID userID:(int)userID;


#pragma mark - Load Local Photo Content / Photo Detail
-(void)load_local_photos:(NSString*)token zip:(NSString*)zip userID:(int)userID;

#pragma mark - Load Local Event Content / Event Detail
-(void)load_local_events:(NSString*)token zip:(NSString*)zip userID:(int)userID;

#pragma mark - Load Local Vehicle Content / Vehicle Detail
-(void)load_local_vehicles:(NSString*)token zip:(NSString*)zip userID:(int)userID;

#pragma mark - Load Local Shop Content / Shop Detail
-(void)load_local_shops:(NSString*)token zip:(NSString*)zip userID:(int)userID;

#pragma mark - Load Local Video Content / Video Detail
-(void)load_local_videos:(NSString*)token zip:(NSString*)zip userID:(int)userID;




#pragma mark - Add Comment
-(void)add_comment:(NSString*)token uid:(int)uid catid:(int)catid contentid:(int)contentid description:(NSString*)description creatorid:(int)creatorid;

#pragma mark - Like Content
-(void)like_content:(NSString*)token uid:(int)uid catid:(int)catid contentid:(int)contentid isLike:(int)isLike creatorid:(int)creatorid;

#pragma mark - Flag Content
-(void)flag_content:(NSString*)token uid:(int)uid catid:(int)catid contentid:(int)contentid isFlag:(int)isFlag;




#pragma mark - Follow User
-(void)follow_user:(NSString*)token uid:(int)uid followerid:(int)followerid action:(int)action;

#pragma mark - Send Message
-(void)send_message:(NSString*)token from_userID:(int)from_userID to_userID:(int)to_userID text_message:(NSString *)text_message;

#pragma mark - Block User
-(void)block_user:(NSString*)token blocker_id:(int)blocker_id blockee_id:(int)blockee_id status:(int)status;

#pragma mark - Report User
-(void)report_user:(NSString*)token from_userID:(int)from_userID about_userID:(int)about_userID report_text:(NSString*)report_text reason_id:(int)reason_id;




#pragma mark - Get Message History
-(void)get_message_history:(NSString*)token userID:(int)userID;

#pragma mark - Get Private Log
-(void)get_private_log:(NSString*)token from_userID:(int)from_userID to_userID:(int)to_userID;


-(void)remove_message:(NSString*)token from_userID:(int)from_userID to_userID:(int)to_userID;

#pragma mark - Get Notifications
-(void)get_notifications:(NSString*)token userID:(int)userID;

#pragma mark - Remove Follower
-(void)remove_follower:(NSString*)token userID:(int)userID followerID:(int)followerID;

#pragma mark - Block Follower
-(void)block_follower:(NSString*)token userID:(int)userID followerID:(int)followerID;

#pragma mark - Get Followers
-(void)get_followers:(NSString*)token userID:(int)userID;

#pragma mark - Get My fans who I follow
-(void)get_fans:(NSString*)token userID:(int)userID;

#pragma mark - Load Comments
-(void)load_comments:(NSString*)token catID:(int)catID contentID:(int)contentID;




#pragma mark - Search Event
-(void)search_event:(NSString*)token eventName:(NSString*)eventName isMyLocation:(int)isMyLocation startDate:(NSString*)startDate endDate:(NSString*)endDate
              fName:(NSString*)fName lName:(NSString*)lName country:(NSString*)country city:(NSString*)city zip:(NSString*)zip miles:(NSString*)miles type:(int)type;

#pragma mark - Search Photo
-(void)search_photo:(NSString*)token startDate:(NSString*)startDate endDate:(NSString*)endDate fname:(NSString*)fname lname:(NSString*)lname tags:(NSString*)tags associated_shop:(NSString*)associated_shop;

#pragma mark - Search Rumbler
-(void)search_rumbler:(NSString*)token username:(NSString*)username email:(NSString*)email firstname:(NSString*)firstname lastname:(NSString*)lastname;

#pragma mark - Search Vehicle
-(void)search_vehicle:(NSString*)token make:(NSString*)make model:(NSString*)model year:(NSString*)year type:(NSString*)type garage:(NSString*)garage  to_year:(NSString*)to_year;

#pragma mark - Search Video
-(void)search_video:(NSString*)token startDate:(NSString*)startDate endDate:(NSString*)endDate fname:(NSString*)fname lname:(NSString*)lname title:(NSString*)title description:(NSString*)description;




#pragma mark - Get Myshops/clubs
-(void)get_myshops_clubs:(NSString*)token userID:(int)userID;

#pragma mark - Add Shop
-(void)add_shop:(NSString*)token userID:(int)userID shop_name:(NSString*)shop_name contact_info:(NSString*)contact_info country:(NSString*)country city:(NSString*)city zip:(NSString*)zip private:(int)mprivate description:(NSString*)description photo_id:(int)photo_id shop_status:(NSString*)shop_status;

#pragma mark - Edit Shop
-(void)edit_shop:(NSString*)token shop_name:(NSString*)shop_name contact_info:(NSString*)contact_info country:(NSString*)country city:(NSString*)city zip:(NSString*)zip private:(int)mprivate description:(NSString*)description shop_id:(int)shop_id photo_id:(int)photo_id;

//http://test-api.darumble.com/api/new/remove/shop?token=capitol-es-are-dev&shopID=550
#pragma mark - Edit Shop
-(void)remove_shop:(NSString*)token shopID:(int)shopID;



#pragma mark - Request Membership
-(void)request_membership:(NSString*)token userID:(int)userID shopID:(int)shopID creatorid:(int)creatorid;

#pragma mark - Get Membership Status
-(void)get_membership_status:(NSString*)token userID:(int)userID shopID:(int)shopID;

#pragma mark - Get Club Members
-(void)get_clubmembers:(NSString*)token shopID:(int)shopID;

#pragma mark - Get Request Member List
-(void)get_request_member_list:(NSString*)token shopID:(int)shopID;

#pragma mark - Accept Member
-(void)accept_member:(NSString*)token userID:(int)userID shopID:(int)shopID;

#pragma mark - Decline Member
-(void)decline_member:(NSString*)token userID:(int)userID shopID:(int)shopID;

#pragma mark - Block Member
-(void)block_member:(NSString*)token userID:(int)userID shopID:(int)shopID;

#pragma mark - Disable Group Request
-(void)disable_group_request:(NSString*)token shopID:(int)shopID;

#pragma mark - Invite User
-(void)invite_user:(NSString*)token username:(NSString*)username email:(NSString*)email shopID:(int)shopID;

#pragma mark - Accept Invitation
-(void)accept_invitation:(NSString*)token userID:(int)userID shopID:(int)shopID;

#pragma mark - Leave Group(Remove member)
-(void)remove_member:(NSString*)token userID:(int)userID shopID:(int)shopID;


#pragma mark - Create Event
-(void)create_event:(NSString*)token userID:(int)userID eventName:(NSString*)eventName eventLocation:(NSString*)eventLocation country:(NSString*)country state:(NSString*)state city:(NSString*)city contact_info:(NSString*)contact_info flyer:(NSString*)flyer eventType:(NSString*)eventType startDate:(NSString*)startDate is_recurring:(int)is_recurring recurringCount:(int)recurringCount recurringTime:(NSString*)recurringTime recurringEndCount:(int)recurringEndCount recurringEndTime:(NSString*)recurringEndTime photoID:(int)photoID zip:(NSString*)zip event_id:(int)event_id;

#pragma mark - Event Image From Others
-(void)add_eventimage_fromother:(NSString*)token eventID:(int)eventID photoID:(int)photoID adderID:(int)adderID creatorid:(int)creatorid;

#pragma mark - Get event other image
-(void)get_event_otherimage:(NSString*)token eventID:(int)eventID;

#pragma mark - Get event other image
-(void)get_event_videos:(NSString*)token eventID:(int)eventID;

#pragma mark - Is blocked account each other?
-(void)check_blocked_status:(NSString*)token userID:(int)userID userID2:(int)userID2;




#pragma mark - set photo whether for public or members
-(void)set_photo_formembers:(NSString*)token formember:(int)formember photoID:(int)photoID userID:(int)userID;
@end
