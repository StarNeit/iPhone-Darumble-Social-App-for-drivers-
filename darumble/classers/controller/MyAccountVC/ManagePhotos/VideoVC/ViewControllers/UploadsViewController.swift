//
//  UploadsViewController.swift
//  VimeoUpload
//
//  Created by Hanssen, Alfie on 12/14/15.
//  Copyright © 2015 Vimeo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import AVFoundation

typealias AssetIdentifier = String

class UploadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    static let NibName = "UploadsViewController"
    var controller = UIImagePickerController()
    var assetsLibrary = ALAssetsLibrary()

    // MARK: 
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: 
    
    private var items: [AssetIdentifier] = []
    
    // MARK:
    
    deinit
    {
        self.removeObservers()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.addObservers()
        self.setupTableView()
        
        self.navigationController?.navigationBarHidden = true
        
        
        //---hide empty cell---
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.backgroundColor = UIColor.clearColor()
        
        RegisterVideoMeta.initVideoCount();
    }
    
    // MARK: Setup
    
    private func setupTableView()
    {
        let nib = UINib(nibName: UploadCell.NibName, bundle: NSBundle.mainBundle())
        self.tableView.registerNib(nib, forCellReuseIdentifier: UploadCell.CellIdentifier)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(UploadCell.CellIdentifier) as! UploadCell
        
        let assetIdentifier = self.items[indexPath.row]
        cell.assetIdentifier = assetIdentifier
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UploadCell.Height
    }
    
    // MARK: Observers
    
    private func addObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "descriptorAdded:", name: DescriptorManagerNotification.DescriptorAdded.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "descriptorDidCancel:", name: DescriptorManagerNotification.DescriptorDidCancel.rawValue, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "returnToManageVideo:", name: "popView", object: nil)
    }
    
    private func removeObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DescriptorManagerNotification.DescriptorAdded.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: DescriptorManagerNotification.DescriptorDidCancel.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "popView", object: nil)
    }
    
    func descriptorAdded(notification: NSNotification)
    {
        // TODO: should we move this dispatch to within the descriptor manager itself?
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if let descriptor = notification.object as? OldUploadDescriptor,
                let identifier = descriptor.identifier
            {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.items.insert(identifier, atIndex: indexPath.row)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    func descriptorDidCancel(notification: NSNotification)
    {
        // TODO: should we move this dispatch to within the descriptor manager itself?
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if let descriptor = notification.object as? OldUploadDescriptor,
                let identifier = descriptor.identifier,
                let index = self.items.indexOf(identifier)
            {
                self.items.removeAtIndex(index)

                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    func returnToManageVideo(notification: NSNotification)
    {
        self.navigationController?.popViewControllerAnimated(true)
        
        
    }
    
    @IBAction func clickUploadButton(sender: AnyObject) {
        let cameraRollViewController = CameraRollViewController(nibName: BaseCameraRollViewController.NibName, bundle:NSBundle.mainBundle())
        self.presentViewController(cameraRollViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickBackButton(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func takeVideo(sender: AnyObject)
    {
        // 1 Check if project runs on a device with camera available
        if UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            
            // 2 Present UIImagePickerController to take video
            //controller = UIImagePickerController()
            controller.sourceType = .Camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            controller.videoMaximumDuration = 10.0
            
            presentViewController(controller, animated: true, completion: nil)
        }
        else
        {
            print("Camera is not available")
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        // 1
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
        
        if let type:AnyObject = mediaType
        {
            if type is String
            {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String
                {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                    if let url = urlOfVideo
                    {
                        // 2
                        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(url,
                                                                         completionBlock:
                            {
                                (url: NSURL!, error: NSError!) in
                                if let theError = error
                                {
                                    print("Error saving video = \(theError)")
                                }
                                else
                                {
                                    print("no errors happened")
                                    print(url)
                                    
                                    let backgroundSessionIdentifier = "com.vimeo.upload"
                                    var authToken = "29c6eff16c4c8bc2343222e447ee7847"
                                    
                                    let vimeoUpload = VimeoUpload<OldUploadDescriptor>(backgroundSessionIdentifier: backgroundSessionIdentifier, authTokenBlock: { () -> String? in
                                        return authToken 
                                    })
                                    
                                    let avAsset = AVURLAsset(URL: url)
                                    let operation = ExportOperation(asset: avAsset)
                                    
                                    // Optionally set a progress block
                                    operation.progressBlock = { (progress: Double) -> Void in
                                        // Do something with progress
                                    }
                                    
                                    operation.completionBlock = {
                                        guard operation.cancelled == false else
                                        {
                                            return
                                        }
                                        
                                        if let error = operation.error
                                        {
                                            // Do something with the error
                                        }
                                        else if let url = operation.outputURL
                                        {
                                            // Use the url to start your upload (see below)
                                        }
                                        else
                                        {
                                            assertionFailure("error and outputURL are mutually exclusive, this should never happen.")
                                        }
                                    }
                                    
                                    operation.start()
                                    
                                }
                        })
                    }
                }
            }
        }
        
        // 3
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
