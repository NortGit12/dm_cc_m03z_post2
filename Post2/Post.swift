//
//  Post.swift
//  Post2
//
//  Created by Jeff Norton on 7/16/16.
//  Copyright © 2016 JCN. All rights reserved.
//

import Foundation

class Post {
    
    // MARK: - Stored Properties
    
    let identifier: NSUUID
    let message: String
    let username: String
    let timestamp: NSTimeInterval
    
    private let kIdentifier = "identifier"
    private let kMessage = "text"
    private let kUsername = "username"
    private let kTimestamp = "timestamp"
    
    var descriptionString: String {
        
        return "\(kIdentifier) (UUIDString) = \(identifier.UUIDString), \(kMessage) = \(message), \(kUsername) = \(username), \(kTimestamp) (formatted) = \(timestampString)"
        
    }
    
    var timestampString: String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        let date = NSDate(timeIntervalSince1970: timestamp)
        
        let timestampString = formatter.stringFromDate(date)
        
        return timestampString
        
    }
    
    var dictionaryValue: [String : AnyObject] {
        
        return [kMessage: message, kUsername: username, kTimestamp: timestamp]
        
    }
    
    var jsonData: NSData? {
        
        return try? NSJSONSerialization.dataWithJSONObject(dictionaryValue, options: .PrettyPrinted)
        
    }
    
    var addPostURL: NSURL? {
        
        guard let basePostURL = PostController.baseURL else { return nil }
        
        return basePostURL
            .URLByAppendingPathComponent(identifier.UUIDString)
            .URLByAppendingPathExtension("json")
        
    }
    
    var queryTimestamp: NSTimeInterval {
        
        return timestamp - 1
        
    }
    
    // MARK: - Initializer(s)
    
    init(message: String, username: String) {
        
        self.identifier = NSUUID()
        self.message = message
        self.username = username
        self.timestamp = NSDate().timeIntervalSince1970
        
    }
    
    init?(identifier: String, dictionary: [String : AnyObject]) {
        
        guard let identifier = NSUUID(UUIDString: identifier),
            message = dictionary[kMessage] as? String,
            username = dictionary[kUsername] as? String,
            timestamp = dictionary[kTimestamp] as? NSTimeInterval
        else { return nil }
        
        self.identifier = identifier
        self.message = message
        self.username = username
        self.timestamp = timestamp
        
    }
    
}