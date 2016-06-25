//
//  DetailViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/21/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class DetailViewController: UIViewController {
    @IBOutlet weak var detailImageView: PFImageView!
    @IBOutlet weak var detailUsernameLabel: UILabel!
    @IBOutlet weak var detailTimestampLabel: UILabel!
    @IBOutlet weak var detailCaptionLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var detailProfilePic: PFImageView!
    var detailPost: PFObject!
    @IBOutlet weak var viewCommentsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailProfilePic.layer.borderWidth = 1
        detailProfilePic.layer.masksToBounds = false
        detailProfilePic.layer.cornerRadius = detailProfilePic.frame.height/2
        detailProfilePic.clipsToBounds = true
        
        detailUsernameLabel.text = (detailPost["author"])!.username
        detailCaptionLabel.text = (detailPost["caption"])! as! String
        detailTimestampLabel.text = (detailPost["timestamp"]) as? String
        viewCommentsLabel.text = "View all \(detailPost["commentsCount"]) comments"
        self.detailImageView.file = detailPost[Post.imageKey] as? PFFile
        self.detailImageView.loadInBackground()
        
        likesLabel.text = "\(detailPost["likesCount"]) likes"
        let detailUser = detailPost["author"] as! PFUser
        if let propic = detailUser["profilepic"] as? PFFile {
            self.detailProfilePic.file = propic
            self.detailProfilePic.loadInBackground()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let commentsVC = segue.destinationViewController as? CommentsViewController
        commentsVC!.currentMedia = detailPost["caption"] as! String
        commentsVC!.postForComments = detailPost as! PFObject
    }
}