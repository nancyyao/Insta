//
//  CommentsViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/23/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentField: UITextField!
    var postForComments: PFObject!
    var comments = []
    var currentMedia: String!
    var commentsCount: Int?
    @IBOutlet weak var dummyConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        self.commentsCount = postForComments["commentsCount"] as? Int
        refreshComments()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func keyboardWillShow(notification: NSNotification!) {
        print("keyboard shown")
        let info = notification.userInfo
        let keyboardFrame = info![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardFrame?.size.height
        dummyConstraint.constant = keyboardHeight!
        print(dummyConstraint.constant)
        view.layoutIfNeeded()
    }
    func keyboardWillHide(notification: NSNotification!) {
        dummyConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentsCell", forIndexPath: indexPath) as! CommentsCell
        let currentComment = comments[indexPath.row] as! PFObject
        cell.commentLabel.text = currentComment["comment"] as? String
        
        let currentUser = currentComment["user"] as! PFUser
        cell.usernameLabel.text = currentUser.username
        
        return cell
    }
    @IBAction func onSend(sender: AnyObject) {
        commentsCount = commentsCount! + 1
        print("comments count: \(commentsCount)")
        Comment.postComment(withComment: commentField.text, withMedia: currentMedia) { (success: Bool, error: NSError?) in
            if success {
                print("comment posted successfully")
                self.refreshComments()
            } else {
                print(error?.localizedDescription)
            }
        }
        postForComments["commentsCount"] = commentsCount
        self.postForComments.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success {
                print("comments count updated to \(self.comments.count)")
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    func refreshComments() {
        print("refreshed comments")
        let query = PFQuery(className: "Comment")
        query.addAscendingOrder("createdAt")
        query.includeKey("user")
        query.whereKey("media", equalTo: currentMedia)
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                print("successfully retrieved \(objects!.count) comments.")
                if let objects = objects {
                    self.comments = objects
                    self.commentsCount = self.comments.count
                    self.tableView.reloadData()
                }
            } else {
                print(error?.localizedDescription)
            }
        })
    }
}

