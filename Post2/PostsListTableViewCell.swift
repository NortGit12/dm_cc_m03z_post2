//
//  PostsListTableViewCell.swift
//  Post2
//
//  Created by Jeff Norton on 7/17/16.
//  Copyright © 2016 JCN. All rights reserved.
//

import UIKit

class PostsListTableViewCell: UITableViewCell {

    // MARK: - Stored Properties
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeAndUsernameLabel: UILabel!
    
    // Method(s)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateWithPost(post: Post) {
        
        messageLabel.text = post.message
        timeAndUsernameLabel.text = "\(post.timestampString) - \(post.username)"
        
    }

}
