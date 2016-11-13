import Foundation

import UIKit
import Photos
import AFNetworking

@objc class SwiftInterface : NSObject {
    var window: UIWindow?
    
    @objc func test() -> UIViewController?
    {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        OldVimeoUpload.sharedInstance.applicationDidFinishLaunching() // Ensure init is called on launch
        
        
        let uploadsViewController = UploadsViewController(nibName: UploadsViewController.NibName, bundle:NSBundle.mainBundle())
        
        self.requestCameraRollAccessIfNecessary()
        
        return uploadsViewController;
    }
    
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void)
    {
        if OldVimeoUpload.sharedInstance.descriptorManager.handleEventsForBackgroundURLSession(identifier: identifier, completionHandler: completionHandler) == false
        {
            assertionFailure("Unhandled background events")
        }
    }
    
    func backgroundProcess(identifier: String, completionHandler: () -> Void)
    {
        if OldVimeoUpload.sharedInstance.descriptorManager.handleEventsForBackgroundURLSession(identifier: identifier, completionHandler: completionHandler) == false
        {
            assertionFailure("Unhandled background events")
        }
    }
    func setNotifications(application: UIApplication)
    {
        let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    private func requestCameraRollAccessIfNecessary()
    {
        PHPhotoLibrary.requestAuthorization { status in
            switch status
            {
            case .Authorized:
                print("Camera roll access granted")
            case .Restricted:
                print("Unable to present camera roll. Camera roll access restricted.")
            case .Denied:
                print("Unable to present camera roll. Camera roll access denied.")
            default:
                // place for .NotDetermined - in this callback status is already determined so should never get here
                break
            }
        }
    }
}