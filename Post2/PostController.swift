//
//  PostController.swift
//  Post2
//
//  Created by Jeff Norton on 7/16/16.
//  Copyright © 2016 JCN. All rights reserved.
//

import Foundation

class PostController {
    
    // MARK: - Stored Properties
    
    static let baseURL = NSURL(string: "https://devmtn-post.firebaseio.com/posts")
    
    static let getPostsURL = PostController.baseURL?.URLByAppendingPathExtension("json")
    
    var posts: [Post] {
        
        didSet {
            self.delegate?.postsUpdated(posts)
        }
    }
    
    weak var delegate: PostDelegate?
    
    // MARK: - Initializer(s)
    
    init() {
        
        self.posts = []
        
        getPosts{ (posts) in
            
            if let posts = posts {
                self.posts = posts
            }
        }
    }
    
    func addPost(message: String, username: String) {
        
        let post = Post(message: message, username: username)
        
        guard let postURL = post.addPostURL else { return }
        
        NetworkController.performRequestForURL(postURL, httpMethod: .Put, body: post.jsonData) { (data, error) in
            
            let responseDataString = NSString(data: data!, encoding: NSUTF8StringEncoding) ?? ""
            
            if error != nil {
                print("Error (instance): \(error)")
            } else if responseDataString.containsString("error") {
                print("Error (in message): \(responseDataString)")
            } else {
                print("Added new post successfully")
            }
        }
    }
    
    func getPosts(reset: Bool = true, completion: ((posts: [Post]?) -> Void)? = nil) {
        
        let queryEndInterval = reset ? NSDate().timeIntervalSince1970 : posts.last?.queryTimestamp ?? NSDate().timeIntervalSince1970
        
        let pagingURLParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        guard let unwrappedURL = PostController.getPostsURL else {
            
            if let completion = completion {
                completion(posts: nil)
            }
            return
        }
        
        NetworkController.performRequestForURL(unwrappedURL, httpMethod: .Get, urlParameters: pagingURLParameters) { (data, error) in
            
            guard let data = data,
            jsonPostsArray = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? [String : AnyObject]
            else {
                
                if let completion = completion {
                    completion(posts: nil)
                }
                return
            }
            
            print("jsonPostsArray = \(jsonPostsArray)")
            
            var getPostsArray: [Post] = []
            
            for (identifier, dictionary) in jsonPostsArray {
                
                guard let dictionary = dictionary as? [String : AnyObject] else { break }
                
                if let post = Post(identifier: identifier, dictionary: dictionary) {
                    getPostsArray.append(post)
                }
            }
            
            getPostsArray = getPostsArray.sort{ $0.0.timestamp > $0.1.timestamp }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if reset == true {
                    self.posts = getPostsArray
                } else {
                    self.posts.appendContentsOf(getPostsArray)
                }
                
                if let completion = completion {
                    completion(posts: getPostsArray)
                }
            })
        }
    }
    
}

protocol PostDelegate: class {
    
    func postsUpdated(post: [Post])
    
}