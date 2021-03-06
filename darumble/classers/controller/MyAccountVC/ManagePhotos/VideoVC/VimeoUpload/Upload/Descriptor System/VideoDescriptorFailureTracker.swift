//
//  UploadFailureTracker.swift
//  VimeoUpload
//
//  Created by Hanssen, Alfie on 12/9/15.
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

import Foundation

@objc class VideoDescriptorFailureTracker: NSObject
{
    private static let ArchiveKey = "descriptors_failed"

    // MARK: 
    
    private let archiver: KeyedArchiver
    private var failedDescriptors: [VideoUri: Descriptor] = [:]

    // MARK: - Initialization
    
    deinit
    {
        self.removeObservers()
    }
    
    init(name: String)
    {
        self.archiver = self.dynamicType.setupArchiver(name: name)

        super.init()
        
        self.failedDescriptors = self.load()

        self.addObservers()
    }
    
    // MARK: Setup
    
    private static func setupArchiver(name name: String) -> KeyedArchiver
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        var documentsURL = NSURL(string: documentsPath)!
        documentsURL = documentsURL.URLByAppendingPathComponent(name)
        
        if NSFileManager.defaultManager().fileExistsAtPath(documentsURL.path!) == false
        {
            try! NSFileManager.defaultManager().createDirectoryAtPath(documentsURL.path!, withIntermediateDirectories: true, attributes: nil)
        }
        
        return KeyedArchiver(basePath: documentsURL.path!)
    }
    
    private func load() -> [VideoUri: Descriptor]
    {
        return self.archiver.loadObjectForKey(self.dynamicType.ArchiveKey) as? [VideoUri: Descriptor] ?? [:]
    }
    
    private func save()
    {
        self.archiver.saveObject(self.failedDescriptors, key: self.dynamicType.ArchiveKey)
    }
    
    // MARK: Public API
    
    func removeAllFailures()
    {
        self.failedDescriptors.removeAll()
        self.save()
    }
    
    func removeFailedDescriptorForKey(key: VideoUri) -> Descriptor?
    {
        guard let descriptor = self.failedDescriptors.removeValueForKey(key) else
        {
            return nil
        }
        
        self.save()

        return descriptor
    }
    
    func failedDescriptorForKey(key: VideoUri) -> Descriptor?
    {
        return self.failedDescriptors[key]
    }
    
    // MARK: Notifications
    
    private func addObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "descriptorDidFail:", name: DescriptorManagerNotification.DescriptorDidFail.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "descriptorDidCancel:", name: DescriptorManagerNotification.DescriptorDidCancel.rawValue, object: nil)
    }
    
    private func removeObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DescriptorManagerNotification.DescriptorDidFail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DescriptorManagerNotification.DescriptorDidCancel.rawValue, object: nil)
    }
    
    func descriptorDidFail(notification: NSNotification)
    {
        if let descriptor = notification.object as? Descriptor,
            let key = (descriptor as? VideoDescriptor)?.videoUri
            where descriptor.error != nil
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.failedDescriptors[key] = descriptor
                self.save()
            }
        }
    }
    
    func descriptorDidCancel(notification: NSNotification)
    {
        if let descriptor = notification.object as? Descriptor, let key = (descriptor as? VideoDescriptor)?.videoUri
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.removeFailedDescriptorForKey(key)
            }
        }
    }
}