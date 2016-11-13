//
//  UserObj.h
//  SmarkKid
//
//  Created by Phan Minh Tam on 3/22/14.
//  Copyright (c) 2014 SDC. All rights reserved.
//

#import "DataCenter.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "JSON.h"
#import "Define.h"
#import "AppDelegate.h"
#import "Common.h"

/*============================================================================
 PRIVATE METHOD
 =============================================================================*/
@interface DataCenter ()



@end

@implementation DataCenter


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super dealloc];
}

-(void)add_user:(NSString*)token username:(NSString*)username fname:(NSString*)fname lname:(NSString*)lname email:(NSString*)email password:(NSString*)password repassword:(NSString*)repassword age:(int)age terms_agreed:(NSString*)terms_agreed phone:(NSString*)phone zip:(NSString*)zip clubName:(NSString*)clubName andCountry:(NSString *) country andType:(int) type{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/user"]]];
    
    NSDictionary *parameter;
    parameter = @{@"token":token, @"username":username, @"fname":fname, @"lname":lname,@"email":email, @"password":password, @"repassword":repassword, @"age":[NSString stringWithFormat:@"%d", age],@"terms_agreed":terms_agreed, @"phone":phone,@"zip":zip,@"clubName":clubName,@"andType":[NSString stringWithFormat:@"%d", type],@"andCountry":country};
    NSLog(@"PARAME %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/user"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_user: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_user: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_user_fail object:error];
    }];
    [httpClient release];
}
-(void)edit_user:(NSString*)token userID:(int)userID username:(NSString*)username fname:(NSString*)fname lname:(NSString*)lname email:(NSString*)email password:(NSString*)password repassword:(NSString*)repassword age:(int)age phone:(NSString*)phone zip:(NSString*)zip clubName:(NSString*)clubName andCountry:(NSString *)country andType:(int)type{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/user"]]];
    
    NSDictionary *parameter;
    if (type==1) {
        parameter  = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"username":username, @"fname":fname, @"lname":lname,@"email":email, @"password":password, @"repassword":repassword, @"age":[NSString stringWithFormat:@"%d", age], @"phone":phone,@"zip":zip,@"clubName":clubName,@"registration_updated":@"1",@"country":country};
    }
    else
    {
        parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"username":username, @"fname":fname, @"lname":lname,@"email":email, @"password":password, @"repassword":repassword, @"age":[NSString stringWithFormat:@"%d", age], @"phone":phone,@"city":zip,@"clubName":clubName,@"registration_updated":@"1",@"country":country};
    }
    NSLog(@"%@", parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/user"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"edit_user: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"edit_user: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_user_fail object:error];
    }];
    [httpClient release];
}
-(void)get_users:(NSString*)token userID:(int)userID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/user"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/user"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_users: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_users: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_user_fail object:error];
    }];
    [httpClient release];
}
-(void)get_categories:(NSString*)token{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/categories"]]];
    
    NSDictionary *parameter = @{@"token":token};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/categories"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_users: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_categories_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_users: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_categories_fail object:error];
    }];
    [httpClient release];
}

#pragma mark - Vehicle

-(void)get_vehicle:(NSString*)token{
    NSString *action = @"get/vehicles";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_vehicle: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_vehicle_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_vehicle: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_vehicle_fail object:error];
    }];
    [httpClient release];
}

-(void)add_vehicle:(NSString*)token userID:(int)userID type:(NSString*)type make:(NSString*)make model:(NSString*)model categoryID:(NSString*)categoryID year:(NSString*)year description:(NSString*)description{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/vehicle"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"type":type, @"make":make, @"model":model,@"categoryID":categoryID, @"year":year, @"description":description};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/vehicle"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_vehicle: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_vehicle_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_vehicle: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_vehicle_fail object:error];
    }];
    [httpClient release];
}
-(void)edit_vehicle:(NSString*)token userID:(int)userID type:(NSString*)type make:(NSString*)make model:(NSString*)model categoryID:(NSString*)categoryID year:(NSString*)year description:(NSString*)description vehicleID:(NSString*)vehicleID {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/vehicle"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"type":type, @"make":make, @"model":model,@"categoryID":categoryID, @"year":year, @"description":description, @"vehicleID":vehicleID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/vehicle"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"edit_vehicle: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_vehicle_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"edit_vehicle: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_vehicle_fail object:error];
    }];
    [httpClient release];
}
-(void)get_vehicle:(NSString*)token vehicleID:(NSString*)vehicleID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/vehicle"]]];
    
    NSDictionary *parameter = @{@"token":token, @"vehicleID":vehicleID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/vehicle"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_vehicle: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_vehicle_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_vehicle: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_vehicle_fail object:error];
    }];
    [httpClient release];
}
-(void)remove_vehicle:(NSString*)token vehicleID:(NSString*)vehicleID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"remove/vehicle"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"], @"vehicleID":vehicleID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"remove/vehicle"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_vehicle: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_vehicle_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_vehicle: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_vehicle_fail object:error];
    }];
    [httpClient release];
}


#pragma mark - Garage

-(void)add_garage:(NSString*)token userID:(int)userID date:(NSString*)date terms:(NSString*)terms isShop:(int)isShop categoryID:(NSString*)categoryID website:(NSString*)website shopName:(NSString*)shopName zip:(NSString*)zip phone:(NSString*)phone address:(NSString*)address email:(NSString*)email{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/garage"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"date":date, @"terms":terms, @"isShop":[NSString stringWithFormat:@"%d",isShop],@"categoryID":categoryID, @"website":website, @"shopName":shopName, @"zip":zip, @"phone":phone, @"address":address, @"email":email};
    
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/garage"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_garage: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_garage: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_garage_fail object:error];
    }];
    [httpClient release];
}
-(void)edit_garage:(NSString*)token userID:(int)userID date:(NSString*)date terms:(NSString*)terms isShop:(int)isShop categoryID:(NSString*)categoryID website:(NSString*)website shopName:(NSString*)shopName zip:(NSString*)zip phone:(NSString*)phone address:(NSString*)address email:(NSString*)email garageID:(int)garageID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/garage"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"date":date, @"terms":terms, @"isShop":[NSString stringWithFormat:@"%d",isShop],@"categoryID":categoryID, @"website":website, @"shopName":shopName, @"zip":zip, @"phone":phone, @"address":address, @"email":email, @"garageID":[NSString stringWithFormat:@"%d",garageID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/garage"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"edit_garage: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"edit_garage: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_garage_fail object:error];
    }];
    [httpClient release];
}

-(void)get_garage:(NSString*)token andFillter:(NSString *) fillter andTypeManager:(int)type{
    NSString *action = @"get/garages";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter ;
    if (fillter.length==0) {
        if (type==0) {
            parameter= @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"isManage":@"0"};
        }
        else
        {
            parameter= @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"]};
        }
        
    }
    else
    {
        parameter= @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"],@"isManage":@"0",@"filter":fillter};
    }
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_garage: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_garage: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_garage_fail object:error];
    }];
    [httpClient release];
}

-(void)get_garage:(NSString*)token garageID:(NSString*)garageID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/garage"]]];
    
    NSDictionary *parameter = @{@"token":token, @"garageID":garageID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"get/garage"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_garage: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_garage: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_garage_fail object:error];
    }];
    [httpClient release];
}

-(void)remove_garage:(NSString*)token garageID:(NSString*)garageID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"remove/garage"]]];
    
    NSDictionary *parameter = @{@"token":token, @"garageID":garageID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"remove/garage"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_garage: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_garage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_garage: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_garage_fail object:error];
    }];
    [httpClient release];
}

#pragma mark - Photos

-(void)get_photo:(NSString*)token isGallery:(int)isGallery{
    NSString *action = @"get/photos";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"], @"isGallery":[NSString stringWithFormat:@"%d", isGallery]};
    NSLog(@"PARMA %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_photo: %@",response);
        if (isGallery == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:k_get_photo_manage_success object:response];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:k_get_photo_success object:response];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_photo: %@", error);
        if (isGallery == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:k_get_photo_manage_fail object:error];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:k_get_photo_fail object:error];
        }
        
    }];
    [httpClient release];
}

-(void)get_photoTab{
    NSString *action = @"get/gallery/photos";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_photo: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_photo_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_photo: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_photo_fail object:error];
    }];
    [httpClient release];
}


-(void)remove_photo:(NSString*)token photoID:(NSString*)photoID{
    NSString *action = @"remove/photo";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"photoID":photoID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_photo: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_photo_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_photo: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_photo_fail object:error];
    }];
    [httpClient release];
}

#pragma mark - Video

-(void)get_video:(NSString*)token{
    NSString *action = @"get/videos";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[USER_DEFAULT objectForKey:@"userID"]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_video: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_video_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_video: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_video_fail object:error];
    }];
    [httpClient release];
}

-(void)get_videoTab{
    NSString *action = @"get/gallery/videos";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"userID":[USER_DEFAULT objectForKey:@"userID"]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_video: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_video_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_video: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_video_fail object:error];
    }];
    [httpClient release];
}

-(void)remove_video:(NSString*)token videoID:(NSString*)videoID{
    NSString *action = @"remove/video";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"videoID":videoID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_video: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_video_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_video: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_video_fail object:error];
    }];
    [httpClient release];
}

-(void)add_video:(NSString*)token url:(NSString*)url uid:(int)uid description:(NSString*)description catid:(NSString*)catid title:(NSString*)title thumbnail:(NSString*)thumbnail zip:(NSString*)zip country:(NSString*)country eventID:(int)eventID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/video"]]];
    
    NSDictionary *parameter = @{@"token":token, @"url":url, @"uid":[NSString stringWithFormat:@"%d",uid], @"description":description, @"categoryID":catid,
                                @"title": title, @"thumbnail": thumbnail, @"zip" : zip, @"country" : country, @"eventID": [NSString stringWithFormat:@"%d", eventID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"add/video"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_video: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_video_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_video: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_video_fail object:error];
    }];
    [httpClient release];
}
-(void)edit_video:(NSString*)token url:(NSString*)url uid:(int)uid description:(NSString*)description catid:(NSString*)catid tags:(NSString*)tags videoID:(int)videoID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/video"]]];
    
    NSDictionary *parameter = @{@"token":token, @"url":url, @"userID":[NSString stringWithFormat:@"%d",uid], @"description":description, @"categoryID":catid, @"videoID":[NSString stringWithFormat:@"%d",videoID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"edit/video"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"edit_video: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_video_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"edit_video: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_video_fail object:error];
    }];
    [httpClient release];
}

//http://test-api.darumble.com/api/new/edit/video?token=capitol-es-are-dev&title=test30&description=test32&id=224
-(void)edit_video2:(NSString*)token description:(NSString*)description title:(NSString*)title videoID:(int)videoID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/edit/video"]]];
    NSDictionary *parameter = @{@"token":token, @"title":title, @"description":description, @"id":[NSString stringWithFormat:@"%d",videoID]};
    
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/edit/video"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"edit_video2: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_video_success2 object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"edit_video2: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_video_fail2 object:error];
    }];
    [httpClient release];
}

#pragma mark - Events
-(void)get_event:(NSString*)token{
    NSString *action = @"get/events";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    NSString *isManager,*userID;
    isManager = @"1";
    if ([USER_DEFAULT objectForKey:@"userID"]) {
        userID = [USER_DEFAULT objectForKey:@"userID"];
    }
    else
    {
        userID =@"0";
    }
    NSDictionary *parameter = @{@"token":token, @"isManage":isManager,@"userID":userID};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_event: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_event: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_fail object:error];
    }];
    [httpClient release];
}

-(void)get_event_not_user:(NSString*)token{
    NSString *action = @"get/events";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    NSString *isManager,*userID;
    isManager = @"0";
    if ([USER_DEFAULT objectForKey:@"userID"]) {
        userID = [USER_DEFAULT objectForKey:@"userID"];
    }
    else
    {
        userID =@"0";
    }
    
    NSDictionary *parameter = @{@"token":token, @"isManage":isManager,@"userID":userID};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_event: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_event: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_fail object:error];
    }];
    [httpClient release];
}

-(void)remove_event:(NSString*)token eventID:(NSString*)eventID{
    NSString *action = @"remove/event";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"eventID":eventID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_event: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_event_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_event: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_event_fail object:error];
    }];
    [httpClient release];
}

#pragma mark User

-(void)login:(NSString*)token username:(NSString*)username password:(NSString*)password registration_key:(NSString*)registration_key{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/login"]]];
    
    NSDictionary *parameter = @{@"token":token, @"email":username, @"password":password, @"registration_key":registration_key};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/login"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"login: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_login_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"login: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_login_fail object:error];
    }];
    [httpClient release];
}

-(void)loginfb:(NSString*)fb_id fb_email:(NSString*)fb_email fb_fname:(NSString*)fb_fname fb_lname:(NSString*)fb_lname fb_age:(NSString *)fb_age fb_zipcode:(NSString *)fb_zipcode fb_phone:(NSString *)phone registration_key:(NSString*)registration_key
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/fb-login"]]];
    
    NSDictionary *parameter = @{@"token":APP_TOKEN, @"email":fb_email, @"firstName":fb_fname, @"lastName":fb_lname,@"facebookID":fb_id,@"age":fb_age,@"zip":fb_zipcode,@"phone":phone, @"registration_key":registration_key};
    NSLog(@"PARAM %@",parameter);
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/fb-login"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"login: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_login_fb_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"login: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_login_fb_fail object:error];
    }];
    [httpClient release];
}

-(void)forgot_password:(NSString*)token email:(NSString*)email{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/forgot-password"]]];
    
    NSDictionary *parameter = @{@"token":token, @"email":email};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/forgot-password"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"forgot_password: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_forgot_password_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"forgot_password: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_forgot_password_fail object:error];
    }];
    [httpClient release];
}



-(void)searchTerms:(NSString*)token searchTerms:(NSString*)searchTerms parentCategoryID:(NSString*)parentCategoryID subCategoryID:(NSString*)subCategoryID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/search"]]];
    
    NSDictionary *parameter = @{@"token":token, @"searchTerms":searchTerms, @"parentCategoryID":parentCategoryID, @"subCategoryID":subCategoryID};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"user/search"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"searchTerms: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_searchTerms_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"searchTerms: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_searchTerms_fail object:error];
    }];
    [httpClient release];
}

- (void) uploadPhoto:(NSString*)token andUserID:(NSString*)userID andCategoryID:(NSString*)categoryID andDescription:(NSString*)description andImageData:(NSString*)imageData
{
    NSString *action = @"upload/photo";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":userID, @"categoryID":categoryID, @"description":description, @"imageData":imageData};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"uploadPhoto: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_photo_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"uploadPhoto: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_photo_fail object:error];
    }];
    [httpClient release];
}

- (void) uploadPhoto:(NSString*)token andUserID:(NSString*)userID andCategoryID:(NSString*)categoryID garageID:(NSString*)garageID andImageData:(NSString*)imageData
{
    NSString *action = @"upload/photo";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, action]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":userID, @"categoryID":categoryID, @"garageID":garageID, @"imageData":imageData};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, action] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"uploadPhoto: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_photo_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"uploadPhoto: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_photo_fail object:error];
    }];
    [httpClient release];
}




//---New WS API---
//---Public Profile---
-(void)load_public_profile:(NSString*)token userID:(int)userID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/user_public_profile"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/user_public_profile"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_public_profile: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_publicprofile_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_public_profile: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_publicprofile_fail object:error];
    }];
    [httpClient release];
}
//---Global Feed---
-(void)load_global_feed:(NSString *)token{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global"]]];
    
    NSDictionary *parameter = @{@"token":token};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_feed: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalfeed_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_feed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalfeed_fail object:error];
    }];
    [httpClient release];
}
//---Local Feed---
-(void)load_local_feed:(NSString *)token geolocation:(NSString*)geolocation zip:(NSString*)zip userID:(int)userID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local"]]];
    
    NSDictionary *parameter = @{@"token":token, @"geolocation":[NSString stringWithFormat:@"%@",geolocation], @"zip":zip, @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_local_feed: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_localfeed_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_local_feed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_localfeed_fail object:error];
    }];
    [httpClient release];
}
//---Load Global/Local Photos---
-(void)load_global_photos:(NSString*)token userID:(int)userID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/photos"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/photos"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_photos: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalphotos_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_photos: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalphotos_fail object:error];
    }];
    [httpClient release];
}
-(void)load_local_photos:(NSString*)token zip:(NSString*)zip userID:(int)userID{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/photos"]]];
    
    NSDictionary *parameter = @{@"token":token, @"zip":zip, @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/photos"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_photos: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalphotos_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_photos: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalphotos_fail object:error];
    }];
    [httpClient release];
}
//---Get Photo Details---
-(void)get_photo_details:(NSString*)token photoID:(int)photoID userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/photo_details"]]];
    
    NSDictionary *parameter = @{@"token":token, @"photoID":[NSString stringWithFormat:@"%d",photoID], @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/photo_details"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_local_feed: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_photo_details_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_local_feed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_photo_details_fail object:error];
    }];
    [httpClient release];
}


//---Load Global/Local Events---
-(void)load_global_events:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/events"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/events"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_event_details: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalevents_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_event_details: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalevents_fail object:error];
    }];
    [httpClient release];
}
-(void)load_local_events:(NSString*)token zip:(NSString*)zip userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/events"]]];
    
    NSDictionary *parameter = @{@"token":token, @"zip":zip, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/events"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_event_details: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalevents_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_event_details: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalevents_fail object:error];
    }];
    [httpClient release];
}
//---Get Event Details---
-(void)get_event_details:(NSString*)token eventID:(int)eventID userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/event_details"]]];
    
    NSDictionary *parameter = @{@"token":token, @"eventID":[NSString stringWithFormat:@"%d",eventID], @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/event_details"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_event_details: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_event_details_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_event_details: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_event_details_fail object:error];
    }];
    [httpClient release];
}

//---Load Global/Local Vehicles---
-(void)load_global_vehicles:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/vehicles"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d", userID ]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/vehicles"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_vehicles: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvehicles_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_vehicles: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvehicles_fail object:error];
    }];
    [httpClient release];
}
-(void)load_local_vehicles:(NSString*)token zip:(NSString*)zip userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/vehicles"]]];
    
    NSDictionary *parameter = @{@"token":token, @"zip":zip, @"userID":[NSString stringWithFormat:@"%d", userID ]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/vehicles"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_vehicles: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvehicles_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_vehicles: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvehicles_fail object:error];
    }];
    [httpClient release];
}
//---Get Vehicles Details---
-(void)get_vehicle_details:(NSString*)token vehicleID:(int)vehicleID userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/vehicle_details"]]];
    
    NSDictionary *parameter = @{@"token":token, @"vehicleID":[NSString stringWithFormat:@"%d",vehicleID], @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/vehicle_details"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_vehicle_details: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_vehicle_details_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_vehicle_details: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_vehicle_details_fail object:error];
    }];
    [httpClient release];
}

//---Load Global/Local Shops---
-(void)load_global_shops:(NSString*)token
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/shops"]]];
    
    NSDictionary *parameter = @{@"token":token};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/shops"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_shops: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalshops_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_shops: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalshops_fail object:error];
    }];
    [httpClient release];
}
-(void)load_local_shops:(NSString*)token zip:(NSString*)zip userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/shops"]]];
    
    NSDictionary *parameter = @{@"token":token, @"zip":zip, @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/shops"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_shops: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalshops_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_shops: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalshops_fail object:error];
    }];
    [httpClient release];
}
//---Get Shops Details---
-(void)get_shop_details:(NSString*)token shopID:(int)shopID userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/shop_details"]]];
    
    NSDictionary *parameter = @{@"token":token, @"shopID":[NSString stringWithFormat:@"%d",shopID], @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/shop_details"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_shop_details: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_shop_details_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_shop_details: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_shop_details_fail object:error];
    }];
    [httpClient release];
}



//---Load Global/Local Videos---
-(void)load_global_videos:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/videos"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID": [NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/global/videos"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_videos: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvideos_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_videos: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvideos_fail object:error];
    }];
    [httpClient release];
}
-(void)load_local_videos:(NSString*)token zip:(NSString*)zip userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/videos"]]];
    
    NSDictionary *parameter = @{@"token":token, @"zip":zip, @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/feed/local/videos"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_global_videos: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvideos_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_global_videos: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_globalvideos_fail object:error];
    }];
    [httpClient release];
}
//---Get Video Details---
-(void)get_video_details:(NSString*)token videoID:(int)videoID userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/video_details"]]];
    
    NSDictionary *parameter = @{@"token":token, @"videoID":[NSString stringWithFormat:@"%d",videoID], @"userID":[NSString stringWithFormat:@"%d", userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/video_details"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_video_details: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_video_details_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_video_details: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_video_details_fail object:error];
    }];
    [httpClient release];
}


//---Add Comment---
-(void)add_comment:(NSString*)token uid:(int)uid catid:(int)catid contentid:(int)contentid description:(NSString*)description creatorid:(int)creatorid
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/add/comment"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",uid], @"catID":[NSString stringWithFormat:@"%d",catid], @"contentID":[NSString stringWithFormat:@"%d",contentid], @"description": description, @"creatorid": [NSString stringWithFormat:@"%d",creatorid]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/add/comment"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_comment: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_comment_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_comment: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_comment_fail object:error];
    }];
    [httpClient release];
}


//---Like Content---
-(void)like_content:(NSString*)token uid:(int)uid catid:(int)catid contentid:(int)contentid isLike:(int)isLike creatorid:(int)creatorid
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/like/content"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",uid], @"catID":[NSString stringWithFormat:@"%d",catid], @"contentID":[NSString stringWithFormat:@"%d",contentid], @"isLike": [NSString stringWithFormat:@"%d", isLike], @"creatorid" : [NSString stringWithFormat:@"%d", creatorid]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/like/content"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"like_content: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_like_content_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"like_content: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_like_content_fail object:error];
    }];
    [httpClient release];
}


//---Flag Content---
-(void)flag_content:(NSString*)token uid:(int)uid catid:(int)catid contentid:(int)contentid isFlag:(int)isFlag
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/flag/content"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",uid], @"catID":[NSString stringWithFormat:@"%d",catid], @"contentID":[NSString stringWithFormat:@"%d",contentid],
                                @"isFlag": [NSString stringWithFormat:@"%d", isFlag]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/flag/content"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"flag_content: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_flag_content_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"flag_content: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_flag_content_fail object:error];
    }];
    [httpClient release];
}

//---Follow User---
-(void)follow_user:(NSString*)token uid:(int)uid followerid:(int)followerid action:(int)action
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/follow/user"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",uid], @"followerID":[NSString stringWithFormat:@"%d",followerid], @"action": [NSString stringWithFormat:@"%d", action]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/follow/user"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"follow_user: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_follow_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"follow_user: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_follow_user_fail object:error];
    }];
    [httpClient release];
}

-(void)send_message:(NSString*)token from_userID:(int)from_userID to_userID:(int)to_userID text_message:(NSString *)text_message
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/send/message"]]];
    
    NSDictionary *parameter = @{@"token":token, @"from_userID":[NSString stringWithFormat:@"%d",from_userID], @"to_userID":[NSString stringWithFormat:@"%d",to_userID], @"text_message": text_message};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/send/message"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"send_message: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_send_message_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"send_message: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_send_message_fail object:error];
    }];
    [httpClient release];
}

-(void)block_user:(NSString*)token blocker_id:(int)blocker_id blockee_id:(int)blockee_id status:(int)status
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/block/user"]]];
    
    NSDictionary *parameter = @{@"token":token, @"blocker_id":[NSString stringWithFormat:@"%d",blocker_id], @"blockee_id":[NSString stringWithFormat:@"%d",blockee_id], @"status":[NSString stringWithFormat:@"%d", status]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/block/user"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"block_user: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_block_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"block_user: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_block_user_fail object:error];
    }];
    [httpClient release];
}

-(void)report_user:(NSString*)token from_userID:(int)from_userID about_userID:(int)about_userID report_text:(NSString*)report_text reason_id:(int)reason_id
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/report/user"]]];
    
    NSDictionary *parameter = @{@"token":token, @"from_userID":[NSString stringWithFormat:@"%d",from_userID], @"about_userID":[NSString stringWithFormat:@"%d",about_userID], @"report_text":report_text, @"reason_id":[NSString stringWithFormat:@"%d", reason_id]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/report/user"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"block_user: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_report_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"block_user: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_report_user_fail object:error];
    }];
    [httpClient release];
}

-(void)get_message_history:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/message_history"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/message_history"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_message_history: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_message_history_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_message_history: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_message_history_fail object:error];
    }];
    [httpClient release];
}

-(void)remove_message:(NSString*)token from_userID:(int)from_userID to_userID:(int)to_userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/message"]]];
    
    NSDictionary *parameter = @{@"token":token, @"from_userID":[NSString stringWithFormat:@"%d",from_userID], @"to_userID":[NSString stringWithFormat:@"%d",to_userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/message"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_message: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_message_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_message: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_message_fail object:error];
    }];
    [httpClient release];
}

-(void)get_private_log:(NSString*)token from_userID:(int)from_userID to_userID:(int)to_userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/privatelog"]]];
    
    NSDictionary *parameter = @{@"token":token, @"from_userID":[NSString stringWithFormat:@"%d",from_userID], @"to_userID":[NSString stringWithFormat:@"%d",to_userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/privatelog"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_private_log: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_private_log_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_private_log: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_private_log_fail object:error];
    }];
    [httpClient release];
}

-(void)get_notifications:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/notifications"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/notifications"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_notifications: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_notifications_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_notifications: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_notifications_fail object:error];
    }];
    [httpClient release];
}

-(void)remove_follower:(NSString*)token userID:(int)userID followerID:(int)followerID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/follower"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"followerID":[NSString stringWithFormat:@"%d",followerID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/follower"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_follower: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_follower_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_follower: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_follower_fail object:error];
    }];
    [httpClient release];
}

-(void)block_follower:(NSString*)token userID:(int)userID followerID:(int)followerID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/block/follower"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"followerID":[NSString stringWithFormat:@"%d",followerID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/block/follower"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"block_follower: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_block_follower_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"block_follower: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_block_follower_fail object:error];
    }];
    [httpClient release];
}


-(void)load_comments:(NSString*)token catID:(int)catID contentID:(int)contentID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/load/comments"]]];
    
    NSDictionary *parameter = @{@"token":token, @"catID":[NSString stringWithFormat:@"%d",catID], @"contentID":[NSString stringWithFormat:@"%d",contentID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/load/comments"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"load_comments: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_load_comments_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"load_comments: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_load_comments_fail object:error];
    }];
    [httpClient release];
}


-(void)search_event:(NSString*)token eventName:(NSString*)eventName isMyLocation:(int)isMyLocation startDate:(NSString*)startDate endDate:(NSString*)endDate
              fName:(NSString*)fName lName:(NSString*)lName country:(NSString*)country city:(NSString*)city zip:(NSString*)zip miles:(NSString*)miles type:(int)type
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/event"]]];
    
    NSDictionary *parameter = @{@"token":token, @"eventName":eventName, @"isMyLocation":[NSString stringWithFormat:@"%d", (isMyLocation + 1)], @"startDate":startDate, @"endDate":endDate, @"fName":fName, @"lName":lName, @"country":country, @"city":city, @"zip":zip, @"miles":miles, @"type":[NSString stringWithFormat:@"%d", type]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/event"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"search_event: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_event_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"search_event: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_event_fail object:error];
    }];
    [httpClient release];
}








-(void)search_photo:(NSString*)token startDate:(NSString*)startDate endDate:(NSString*)endDate fname:(NSString*)fname lname:(NSString*)lname tags:(NSString*)tags associated_shop:(NSString*)associated_shop
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/photo"]]];
    
    NSDictionary *parameter = @{@"token":token, @"startDate":startDate, @"endDate":endDate, @"fname":fname, @"lname":lname, @"tags":tags, @"associated_shop":associated_shop};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/photo"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"search_event: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_photo_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"search_event: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_photo_fail object:error];
    }];
    [httpClient release];
}

-(void)search_rumbler:(NSString*)token username:(NSString*)username email:(NSString*)email firstname:(NSString*)firstname lastname:(NSString*)lastname
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/rumbler"]]];
    
    NSDictionary *parameter = @{@"token":token, @"username":username, @"email":email, @"firstname":firstname, @"lastname":lastname};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/rumbler"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"search_rumbler: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_rumbler_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"search_rumbler: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_rumbler_fail object:error];
    }];
    [httpClient release];
}


-(void)search_vehicle:(NSString*)token make:(NSString*)make model:(NSString*)model year:(NSString*)year type:(NSString*)type garage:(NSString*)garage  to_year:(NSString*)to_year
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/vehicle"]]];
    
    NSDictionary *parameter = @{@"token":token, @"make":make, @"model":model, @"year":year, @"type":type, @"garage":garage,@"to_year":to_year};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/vehicle"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"search_vehicle: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_vehicle_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"search_vehicle: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_vehicle_fail object:error];
    }];
    [httpClient release];
}


-(void)search_video:(NSString*)token startDate:(NSString*)startDate endDate:(NSString*)endDate fname:(NSString*)fname lname:(NSString*)lname title:(NSString*)title description:(NSString*)description
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/video"]]];
    
    NSDictionary *parameter = @{@"token":token, @"startDate":startDate, @"endDate":endDate, @"fname":fname, @"lname":lname, @"title":title, @"description":description};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/search/video"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"search_video: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_video_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"search_video: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_search_video_fail object:error];
    }];
    [httpClient release];
}

-(void)get_myshops_clubs:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/myshops_clubs"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/myshops_clubs"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_myshops_clubs: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_myshops_clubs_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_myshops_clubs: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_myshops_clubs_fail object:error];
    }];
    [httpClient release];
}


-(void)get_followers:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/followers"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/followers"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_followers: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_followers_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_followers: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_followers_fail object:error];
    }];
    [httpClient release];
}


-(void)get_fans:(NSString*)token userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/myfans"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/myfans"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_fans: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_myfans_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_fans: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_myfans_fail object:error];
    }];
    [httpClient release];
}



-(void)add_shop:(NSString*)token userID:(int)userID shop_name:(NSString*)shop_name contact_info:(NSString*)contact_info country:(NSString*)country city:(NSString*)city zip:(NSString*)zip private:(int)mprivate description:(NSString*)description photo_id:(int)photo_id shop_status:(NSString*)shop_status
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/add/shop"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shop_name":shop_name, @"contact_info":contact_info, @"country":country, @"city":city, @"zip":zip, @"private":[NSString stringWithFormat:@"%d",mprivate], @"description":description, @"photo_id":[NSString stringWithFormat:@"%d", photo_id], @"shop_status":shop_status};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/add/shop"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_shop: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_shop_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_shop: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_shop_fail object:error];
    }];
    [httpClient release];
}


-(void)edit_shop:(NSString*)token shop_name:(NSString*)shop_name contact_info:(NSString*)contact_info country:(NSString*)country city:(NSString*)city zip:(NSString*)zip private:(int)mprivate description:(NSString*)description shop_id:(int)shop_id photo_id:(int)photo_id
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/edit/shop"]]];
    
    NSDictionary *parameter = @{@"token":token, @"shop_name":shop_name, @"contact_info":contact_info, @"country":country, @"city":city, @"zip":zip, @"private":[NSString stringWithFormat:@"%d",mprivate], @"description":description, @"shop_id":[NSString stringWithFormat:@"%d", shop_id], @"photo_id":[NSString stringWithFormat:@"%d", photo_id]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/edit/shop"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"edit_shop: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_shop_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"edit_shop: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_edit_shop_fail object:error];
    }];
    [httpClient release];
}

-(void)remove_shop:(NSString*)token shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/shop"]]];
    
    NSDictionary *parameter = @{@"token":token, @"shopID":[NSString stringWithFormat:@"%d", shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/shop"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"remove_shop: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_shop_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"remove_shop: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_shop_fail object:error];
    }];
    [httpClient release];
}


-(void)request_membership:(NSString*)token userID:(int)userID shopID:(int)shopID creatorid:(int)creatorid
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/request/membership"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID], @"creatorid":[NSString stringWithFormat:@"%d",creatorid]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/request/membership"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"request_membership: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_request_membership_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request_membership: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_request_membership_fail object:error];
    }];
    [httpClient release];
}


-(void)get_membership_status:(NSString*)token userID:(int)userID shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/membership_status"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/membership_status"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_membership_status: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_membership_status_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_membership_status: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_membership_status_fail object:error];
    }];
    [httpClient release];
}


-(void)get_clubmembers:(NSString*)token shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/club_members"]]];
    
    NSDictionary *parameter = @{@"token":token, @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/club_members"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_clubmembers: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_clubmembers_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_clubmembers: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_clubmembers_fail object:error];
    }];
    [httpClient release];
}


-(void)get_request_member_list:(NSString*)token shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/request_member_list"]]];
    
    NSDictionary *parameter = @{@"token":token, @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/request_member_list"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_request_member_list: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_request_member_list_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_request_member_list: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_request_member_list_fail object:error];
    }];
    [httpClient release];
}


-(void)accept_member:(NSString*)token userID:(int)userID shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/accept/member"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/accept/member"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"accept_member: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_accept_member_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"accept_member: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_accept_member_fail object:error];
    }];
    [httpClient release];
}


-(void)decline_member:(NSString*)token userID:(int)userID shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/decline/member"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/decline/member"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"decline_member: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_decline_member_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"decline_member: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_decline_member_fail object:error];
    }];
    [httpClient release];
}


-(void)block_member:(NSString*)token userID:(int)userID shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/block/member"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/block/member"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"block_member: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_block_member_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"block_member: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_block_member_fail object:error];
    }];
    [httpClient release];
}


-(void)disable_group_request:(NSString*)token shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/disable/group_request"]]];
    
    NSDictionary *parameter = @{@"token":token, @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/disable/group_request"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"disable_group_request: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_disable_group_request_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"disable_group_request: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_disable_group_request_fail object:error];
    }];
    [httpClient release];
}


-(void)invite_user:(NSString*)token username:(NSString*)username email:(NSString*)email shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/invite/to_member"]]];
    
    NSDictionary *parameter = @{@"token":token, @"username":username, @"email":email, @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/invite/to_member"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"invite_user: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_invite_user_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"invite_user: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_invite_user_fail object:error];
    }];
    [httpClient release];
}

-(void)accept_invitation:(NSString*)token userID:(int)userID shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/accept/invitation"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/accept/invitation"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"accept_invitation: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_accept_invitation_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"accept_invitation: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_accept_invitation_fail object:error];
    }];
    [httpClient release];
}


-(void)create_event:(NSString*)token userID:(int)userID eventName:(NSString*)eventName eventLocation:(NSString*)eventLocation country:(NSString*)country state:(NSString*)state city:(NSString*)city contact_info:(NSString*)contact_info flyer:(NSString*)flyer eventType:(NSString*)eventType startDate:(NSString*)startDate is_recurring:(int)is_recurring recurringCount:(int)recurringCount recurringTime:(NSString*)recurringTime recurringEndCount:(int)recurringEndCount recurringEndTime:(NSString*)recurringEndTime photoID:(int)photoID zip:(NSString*)zip event_id:(int)event_id
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/create/event"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d", userID],@"eventName":eventName, @"eventLocation":eventLocation, @"country":country, @"state":state, @"city":city, @"contact_info":contact_info, @"flyer":flyer, @"eventType":eventType, @"startDate":startDate, @"is_recurring":[NSString stringWithFormat:@"%d",is_recurring], @"recurringCount":[NSString stringWithFormat:@"%d", recurringCount],@"recurringTime":recurringTime, @"recurringEndCount":[NSString stringWithFormat:@"%d", recurringEndCount], @"recurringEndTime":recurringEndTime , @"photoID" : [NSString stringWithFormat:@"%d", photoID], @"zip" : zip, @"event_id" : [NSString stringWithFormat:@"%d", event_id]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/create/event"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"create_event: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_create_event_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"create_event: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_create_event_fail object:error];
    }];
    [httpClient release];
}


-(void)add_eventimage_fromother:(NSString*)token eventID:(int)eventID photoID:(int)photoID adderID:(int)adderID creatorid:(int)creatorid
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/add/eventimage_fromother"]]];
    
    NSDictionary *parameter = @{@"token":token, @"eventID":[NSString stringWithFormat:@"%d",eventID], @"photoID":[NSString stringWithFormat:@"%d",photoID], @"adderID":[NSString stringWithFormat:@"%d",adderID], @"creatorid":[NSString stringWithFormat:@"%d", creatorid]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/add/eventimage_fromother"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"add_eventimage_fromother: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_eventimage_fromother_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"add_eventimage_fromother: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_add_eventimage_fromother_fail object:error];
    }];
    [httpClient release];
}


-(void)get_event_otherimage:(NSString*)token eventID:(int)eventID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/event_otherimage"]]];
    
    NSDictionary *parameter = @{@"token":token, @"eventID":[NSString stringWithFormat:@"%d",eventID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/event_otherimage"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_event_otherimage: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_otherimage_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_event_otherimage: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_otherimage_fail object:error];
    }];
    [httpClient release];
}

-(void)get_event_videos:(NSString*)token eventID:(int)eventID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/event_videos"]]];
    
    NSDictionary *parameter = @{@"token":token, @"eventID":[NSString stringWithFormat:@"%d",eventID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/event_videos"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"get_event_videos: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_videos_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get_event_videos: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_get_event_videos_fail object:error];
    }];
    [httpClient release];
}



-(void)check_blocked_status:(NSString*)token userID:(int)userID userID2:(int)userID2
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/isblocked"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"userID2":[NSString stringWithFormat:@"%d",userID2]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/get/isblocked"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"check_blocked_status: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_check_blocked_status_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"check_blocked_status: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_check_blocked_status_fail object:error];
    }];
    [httpClient release];
    
}


-(void)remove_member:(NSString*)token userID:(int)userID shopID:(int)shopID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/club_member"]]];
    
    NSDictionary *parameter = @{@"token":token, @"userID":[NSString stringWithFormat:@"%d",userID], @"shopID":[NSString stringWithFormat:@"%d",shopID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/remove/club_member"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"block_member: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_member_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"block_member: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_remove_member_fail object:error];
    }];
    [httpClient release];
}

-(void)set_photo_formembers:(NSString*)token formember:(int)formember photoID:(int)photoID userID:(int)userID
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/edit/member_public"]]];
    
    NSDictionary *parameter = @{@"token":token, @"formember":[NSString stringWithFormat:@"%d",formember], @"photoID":[NSString stringWithFormat:@"%d",photoID], @"userID":[NSString stringWithFormat:@"%d",userID]};
    [httpClient postPath:[NSString stringWithFormat:@"%@%@", WS_LINK, @"new/edit/member_public"] parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"set_photo_formembers: %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_set_photo_formember_success object:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"set_photo_formembers: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:k_set_photo_formember_fail object:error];
    }];
    [httpClient release];
}
@end
