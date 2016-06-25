//
//  UserViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/22/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var userPosts = []
    var user: PFUser?
    ///post

    @IBOutlet weak var userCollectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: PFImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        
        userImage!.layer.borderWidth = 1
        userImage!.layer.masksToBounds = false
        userImage!.layer.cornerRadius = userImage!.frame.height/2
        userImage!.clipsToBounds = true
        
        usernameLabel.text = user!.username
        if let propic = self.userImage {
            propic.file = self.user!["profilepic"] as? PFFile
            self.userImage!.loadInBackground()
        }
        userRefresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func userRefresh() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.whereKey("author", equalTo: user!)
      //  query.limit = 20
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.userPosts = objects
                self.userCollectionView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = userCollectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        if let post = userPosts[indexPath.row] as? PFObject {
            cell.userPostImageView.file = (post[Post.imageKey] as? PFFile)
            cell.userPostImageView.loadInBackground()
        }
        return cell
    }
}
