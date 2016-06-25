//
//  PostCell.swift
//  Insta
//
//  Created by Nancy Yao on 6/20/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PostCell: UITableViewCell {
    @IBOutlet weak var postImageView: PFImageView!
    @IBOutlet weak var userImageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    var postLikes: Int?
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var instagramPost: PFObject! {
        didSet {
            print("posted image")
            self.postImageView.file = instagramPost[Post.imageKey] as? PFFile
            self.postImageView.loadInBackground()
            self.likeLabel.text = "\(self.postLikes!)"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func onLike(sender: AnyObject) {
        postLikes! += 1
        instagramPost["likesCount"] = postLikes
        instagramPost.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if success {
                print("likes count updated to \(self.postLikes)")
                self.likeLabel.text = "\(self.postLikes!)"
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}