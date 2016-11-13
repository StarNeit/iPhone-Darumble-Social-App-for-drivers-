//
//  Define.h
//  Saverpassport
//
//  Created by Phan Minh Tam on 6/9/14.
//  Copyright (c) 2015 Phan Minh Tam. All rights reserved.
//

#ifndef Define_h

#define APP_NAME                @"DaRumble"

#define NETWORK_DISCONNECT      @"No Internet Connection Available. Please try again."
//ERROR
#define EROOR_MISS_USERNAME     @"Username is required."
#define ERROR_MISS_EMAIL       @"Your email is required."
#define ERROR_EMAIL_FORMAT      @"Your email is invalid."
#define ERROR_MISS_PASSWORD     @"Password is required."
#define ERROR_MISS_CURRENT_PASSWORD     @"Current password is required."
#define ERROR_MISS_CURRENT_PASSWORD_MATCH     @"Current Password does not match."
#define ERROR_MISS_NEW_PASSWORD @"New password is required."
#define EROOR_MISS_FIRSTNAME     @"First name is required."
#define EROOR_MISS_LASTNAME     @"Last name is required."
#define EROOR_MISS_AGE     @"Age is required."
#define EROOR_MISS_PHONE     @"Phone is required."
#define EROOR_MISS_ZIPCODE     @"Zipcode is required."
#define EROOR_MISS_CITY     @"City is required."
#define EROOR_MISS_TERM     @"Term and Conditions is required."

#define Cat_GeneralPhotos 1
#define Cat_Videos 2
#define Cat_Vehicles 3
#define Cat_Garages 4
#define Cat_Events 5

#define UD_FB_USER_DETAIL @"FacebookUserDetail"
#define UD_FB_LOGIN_REQUEST @"FacebookLoginRequest"
#define UD_FB_TOKEN @"FacebookToken"
#define FBID @"1417858111854756"

#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
#define trimString(str) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define APP_TOKEN   @"capitol-es-are-dev"
//---#define WS_LINK     @"http://capitolstreet.vndsupport.com/api/"
#define WS_LINK     @"http://test-api.darumble.com/api/"

//#define WS_LINK @"capitolstreet.vndsupport.com"
#define k_add_user_success @"k_add_user_success"
#define k_add_user_fail @"k_add_user_fail"
#define k_edit_user_success @"k_edit_user_success"
#define k_edit_user_fail @"k_edit_user_fail"
#define k_get_user_success @"k_get_user_success"
#define k_get_user_fail @"k_get_user_fail"
#define k_get_categories_success @"k_get_categories_success"
#define k_get_categories_fail @"k_get_categories_fail"

#define k_add_vehicle_success @"k_add_vehicle_success"
#define k_add_vehicle_fail @"k_add_vehicle_fail"
#define k_edit_vehicle_success @"k_edit_vehicle_success"
#define k_edit_vehicle_fail @"k_edit_vehicle_fail"
#define k_get_vehicle_success @"k_get_vehicle_success"
#define k_get_vehicle_fail @"k_get_vehicle_fail"
#define k_remove_vehicle_success @"k_remove_vehicle_success"
#define k_remove_vehicle_fail @"k_remove_vehicle_fail"

#define k_add_garage_success @"k_add_garage_success"
#define k_add_garage_fail @"k_add_garage_fail"
#define k_edit_garage_success @"k_edit_garage_success"
#define k_edit_garage_fail @"k_edit_garage_fail"
#define k_get_garage_success @"k_get_garage_success"
#define k_get_garage_fail @"k_get_garage_fail"
#define k_remove_garage_success @"k_remove_garage_success"
#define k_remove_garage_fail @"k_remove_garage_fail"

#define k_add_photo_success @"k_add_photo_success"
#define k_add_photo_fail @"k_add_photo_fail"
#define k_get_photo_manage_success @"k_get_photo_manage_success"
#define k_get_photo_manage_fail @"k_get_photo_manage_fail"
#define k_edit_photo_success @"k_edit_photo_success"
#define k_edit_photo_fail @"k_edit_photo_fail"
#define k_get_photo_success @"k_get_photo_success"
#define k_get_photo_fail @"k_get_photo_fail"
#define k_remove_photo_success @"k_remove_photo_success"
#define k_remove_photo_fail @"k_remove_photo_fail"

#define k_add_video_success @"k_add_video_success"
#define k_add_video_fail @"k_add_video_fail"
#define k_edit_video_success @"k_edit_video_success"
#define k_edit_video_fail @"k_edit_video_fail"
#define k_edit_video_success2 @"k_edit_video_success2"
#define k_edit_video_fail2 @"k_edit_video_fail2"
#define k_get_video_success @"k_get_video_success"
#define k_get_video_fail @"k_get_video_fail"
#define k_remove_video_success @"k_remove_video_success"
#define k_remove_video_fail @"k_remove_video_fail"

#define k_add_event_success @"k_add_event_success"
#define k_add_event_fail @"k_add_event_fail"
#define k_edit_event_success @"k_edit_event_success"
#define k_edit_event_fail @"k_edit_event_fail"
#define k_get_event_success @"k_get_event_success"
#define k_get_event_fail @"k_get_event_fail"
#define k_remove_event_success @"k_remove_event_success"
#define k_remove_event_fail @"k_remove_event_fail"

#define k_login_success @"k_login_success"
#define k_login_fail @"k_login_fail"
#define k_login_fb_success @"k_login_fb_success"
#define k_login_fb_fail @"k_login_fb_fail"
#define k_forgot_password_success @"k_forgot_password_success"
#define k_forgot_password_fail @"k_forgot_password_fail"
#define k_searchTerms_success @"k_forgot_password_success"
#define k_searchTerms_fail @"k_forgot_password_fail"
#define k_add_photo_success @"k_add_photo_success"
#define k_add_photo_fail @"k_add_photo_fail"




//---NEW WS CONSTANTS---
#define k_publicprofile_success @"k_publicprofile_success"
#define k_publicprofile_fail @"k_publicprofile_fail"

#define k_globalfeed_success @"k_globalfeed_success"
#define k_globalfeed_fail @"k_globalfeed_fail"

#define k_localfeed_success @"k_localfeed_success"
#define k_localfeed_fail @"k_localfeed_fail"

#define k_globalphotos_success @"k_globalphotos_success"
#define k_globalphotos_fail @"k_globalphotos_fail"
#define k_photo_details_success @"k_photo_details_success"
#define k_photo_details_fail @"k_photo_details_fail"

#define k_globalevents_success @"k_globalevents_success"
#define k_globalevents_fail @"k_globalevents_fail"
#define k_event_details_success @"k_event_details_success"
#define k_event_details_fail @"k_event_details_fail"

#define k_globalvehicles_success @"k_globalvehicles_success"
#define k_globalvehicles_fail @"k_globalvehicles_fail"
#define k_vehicle_details_success @"k_vehicle_details_success"
#define k_vehicle_details_fail @"k_vehicle_details_fail"


#define k_globalshops_success @"k_globalshops_success"
#define k_globalshops_fail @"k_globalshops_fail"
#define k_shop_details_success @"k_shop_details_success"
#define k_shop_details_fail @"k_shop_details_fail"


#define k_globalvideos_success @"k_globalvideos_success"
#define k_globalvideos_fail @"k_globalvideos_fail"
#define k_video_details_success @"k_video_details_success"
#define k_video_details_fail @"k_video_details_fail"


#define k_add_comment_success @"k_add_comment_success"
#define k_add_comment_fail @"k_add_comment_fail"

#define k_like_content_success @"k_like_content_success"
#define k_like_content_fail @"k_like_content_fail"

#define k_flag_content_success @"k_flag_content_success"
#define k_flag_content_fail @"k_flag_content_fail"

#define k_follow_user_success @"k_follow_user_success"
#define k_follow_user_fail @"k_follow_user_fail"

#define k_send_message_success @"k_send_message_success"
#define k_send_message_fail @"k_send_message_fail"

#define k_block_user_success @"k_block_user_success"
#define k_block_user_fail @"k_block_user_fail"

#define k_report_user_success @"k_report_user_success"
#define k_report_user_fail @"k_report_user_fail"

#define k_message_history_success @"k_message_history_success"
#define k_message_history_fail @"k_message_history_fail"

#define k_private_log_success @"k_private_log_success"
#define k_private_log_fail @"k_private_log_fail"

#define k_remove_message_success @"k_remove_message_success"
#define k_remove_message_fail @"k_remove_message_fail"

#define k_get_notifications_success @"k_get_notifications_success"
#define k_get_notifications_fail @"k_get_notifications_fail"

#define k_remove_follower_success @"k_remove_follower_success"
#define k_remove_follower_fail @"k_remove_follower_fail"

#define k_block_follower_success @"k_block_follower_success"
#define k_block_follower_fail @"k_block_follower_fail"

#define k_load_comments_success @"k_load_comments_success"
#define k_load_comments_fail @"k_load_comments_fail"

#define k_search_event_success @"k_search_event_success"
#define k_search_event_fail @"k_search_event_fail"

#define k_search_photo_success @"k_search_photo_success"
#define k_search_photo_fail @"k_search_photo_fail"

#define k_search_rumbler_success @"k_search_rumbler_success"
#define k_search_rumbler_fail @"k_search_rumbler_fail"

#define k_search_vehicle_success @"k_search_vehicle_success"
#define k_search_vehicle_fail @"k_search_vehicle_fail"

#define k_search_video_success @"k_search_video_success"
#define k_search_video_fail @"k_search_video_fail"

#define k_get_myshops_clubs_success @"k_get_myshops_clubs_success"
#define k_get_myshops_clubs_fail @"k_get_myshops_clubs_fail"

#define k_get_followers_success @"k_get_followers_success"
#define k_get_followers_fail @"k_get_followers_fail"

#define k_get_myfans_success @"k_get_myfans_success"
#define k_get_myfans_fail @"k_get_myfans_fail"

#define k_add_shop_success @"k_add_shop_success"
#define k_add_shop_fail @"k_add_shop_fail"

#define k_edit_shop_success @"k_edit_shop_success"
#define k_edit_shop_fail @"k_edit_shop_fail"

#define k_remove_shop_success @"k_remove_shop_success"
#define k_remove_shop_fail @"k_remove_shop_fail"

#define k_request_membership_success @"k_request_membership_success"
#define k_request_membership_fail @"k_request_membership_fail"

#define k_get_clubmembers_success @"k_get_clubmembers_success"
#define k_get_clubmembers_fail @"k_get_clubmembers_fail"

#define k_get_request_member_list_success @"k_get_request_member_list_success"
#define k_get_request_member_list_fail @"k_get_request_member_list_fail"

#define k_accept_member_success @"k_accept_member_success"
#define k_accept_member_fail @"k_accept_member_fail"

#define k_decline_member_success @"k_decline_member_success"
#define k_decline_member_fail @"k_decline_member_fail"

#define k_block_member_success @"k_block_member_success"
#define k_block_member_fail @"k_block_member_fail"

#define k_disable_group_request_success @"k_disable_group_request_success"
#define k_disable_group_request_fail @"k_disable_group_request_fail"

#define k_invite_user_success @"k_invite_user_success"
#define k_invite_user_fail @"k_invite_user_fail"

#define k_accept_invitation_success @"k_accept_invitation_success"
#define k_accept_invitation_fail @"k_accept_invitation_fail"

#define k_create_event_success @"k_create_event_success"
#define k_create_event_fail @"k_create_event_fail"

#define k_add_eventimage_fromother_success @"k_add_eventimage_fromother_success"
#define k_add_eventimage_fromother_fail @"k_add_eventimage_fromother_fail"

#define k_get_event_otherimage_success @"k_get_event_otherimage_success"
#define k_get_event_otherimage_fail @"k_get_event_otherimage_fail"

#define k_get_event_videos_success @"k_get_event_videos_success"
#define k_get_event_videos_fail @"k_get_event_videos_fail"

#define k_check_blocked_status_success @"k_check_blocked_status_success"
#define k_check_blocked_status_fail @"k_check_blocked_status_fail"

#define k_get_membership_status_success @"k_get_membership_status_success"
#define k_get_membership_status_fail @"k_get_membership_status_fail"

#define k_remove_member_success @"k_remove_member_success"
#define k_remove_member_fail @"k_remove_member_fail"

#define k_set_photo_formember_success @"k_set_photo_formember_success"
#define k_set_photo_formember_fail @"k_set_photo_formember_fail"

//---NEW PRO CONSTANTS---
#define c_flag_content 4000
#define c_like_content 4001
#define c_share_content 4002
#define c_block_user 4003
#define c_report_user 4004
#define c_block_follower 4005
#define c_remove_follower 4006



#endif
