//
//  PostsListTableViewController.swift
//  Post2
//
//  Created by Jeff Norton on 7/17/16.
//  Copyright © 2016 JCN. All rights reserved.
//

import UIKit

class PostsListTableViewController: UITableViewController, PostDelegate {
    
    // MARK: - Stored Properties
    
    var postController = PostController()
    
    // MARK: - General

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postController.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        self.refreshControl?.addTarget(self, action: #selector(PostsListTableViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        refreshControl.beginRefreshing()
        postController.getPosts()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    // MARK: - Action(s)
    
    @IBAction func addButtonTapped(sender: UIButton) {
        
        presentAddPostAlert()
        
    }
    
    // MARK: - PostDelegate
    
    func postsUpdated(post: [Post]) {
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("postsListCell", forIndexPath: indexPath) as? PostsListTableViewCell
            else{ return UITableViewCell() }

        let post = postController.posts[indexPath.row]
        
        cell.updateWithPost(post)

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row + 1) >= postController.posts.count {
            
            // Get the next batch of cells
            
            postController.getPosts(false, completion: { (posts) in
                
                if posts != nil {
                    
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: - Methods
    
    func presentAddPostAlert() {
        
        let addPostAlertController = UIAlertController(title: "Add New Post", message: "Create a new post and add it to the existing posts", preferredStyle: .Alert)
        
        // Create the text fields
        
        addPostAlertController.addTextFieldWithConfigurationHandler { (messageTextField) in
            
            messageTextField.placeholder = "Message..."
            messageTextField.becomeFirstResponder()
        }
        
        addPostAlertController.addTextFieldWithConfigurationHandler { (usernameTextField) in
            
            usernameTextField.placeholder = "Username..."
        }
        
        // Create the alert actions, add them to the alert controller, and present the alert
        
        let addPostAction = UIAlertAction(title: "Add Post", style: .Default) { (UIAlertAction) in
            
            guard let message = addPostAlertController.textFields?[0].text,
                username = addPostAlertController.textFields?[1].text
                where message.characters.count > 0 && username.characters.count > 0
            else {
                self.presentErrorAlert()
                return
            }
            
            self.postController.addPost(message, username: username)
            self.postController.getPosts()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        addPostAlertController.addAction(addPostAction)
        addPostAlertController.addAction(cancelAction)
        
        presentViewController(addPostAlertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        
        let errorAlertController = UIAlertController(title: "Holy Freaking Crap, Batman!", message: "The message and username fields are required.  Make sure that they both have values.", preferredStyle: .Alert)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .Default) { (placeholder) in
            self.presentAddPostAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        errorAlertController.addAction(tryAgainAction)
        errorAlertController.addAction(cancelAction)
        
        presentViewController(errorAlertController, animated: true, completion: nil)
        
    }
}