//
//  ProfileViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/20/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileUsernameLabel: UILabel!
    var myPosts = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileUserImageView: PFImageView?
    let user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        profileUsernameLabel.text = user!.username
        profileRefresh()
        
        profileUserImageView!.layer.borderWidth = 1
        profileUserImageView!.layer.masksToBounds = false
        profileUserImageView!.layer.cornerRadius = profileUserImageView!.frame.height/2
        profileUserImageView!.clipsToBounds = true
        
        if let propic = self.profileUserImageView {
            propic.file = self.user!["profilepic"] as? PFFile
            self.profileUserImageView!.loadInBackground()}
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func onLogOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            // PFUser.currentUser() will now be nil
            print("User logged out successfully")
            self.performSegueWithIdentifier("logOutSegue", sender: nil)
        }
    }
    func profileRefresh() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.whereKey("author", equalTo: user!)
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.myPosts = objects
                self.collectionView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("my posts: \(myPosts.count)")
        return myPosts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
        if let post = myPosts[indexPath.row] as? PFObject {
            cell.profileImageView.file = (post[Post.imageKey] as? PFFile)
            cell.profileImageView.loadInBackground()
        }
        return cell
    }
    @IBAction func onAddProfilePhoto(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let smallImage = resize(originalImage, newSize: CGSize(width: 1000, height: 1000))
        user!["profilepic"] = Post.getPFFileFromImage(smallImage)
        
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Propic saved")
                self.profileUserImageView!.file = self.user!["profilepic"] as? PFFile
                self.profileUserImageView!.loadInBackground()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
