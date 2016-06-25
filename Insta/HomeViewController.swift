//
//  HomeViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/20/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostHeaderDelegate {
    @IBOutlet weak var tableView: UITableView!
    var numberofposts: Int?
    var posts = []
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var limit: Int = 20
    let HeaderViewIdentifier = "TableViewHeaderView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        
        refresh()
        
        let refreshControl = UIRefreshControl()
        print("made table refresh control")
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up header
        let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("refreshcontrol")
        refresh()
        refreshControl.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func refresh() {
        print("refresh")
        limit = 20
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = limit
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.posts = objects
                self.tableView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)") //error
            }
        }
    }
    // HEADER & TABLE VIEW INFO
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
        let post = posts[indexPath.section] as! PFObject
        let user = (post["author"]) as! PFUser
        
        cell.postLikes = post["likesCount"] as? Int
        //cell.usernameLabel.text = user.username
        cell.captionLabel.text = (post["caption"])! as? String
        cell.commentLabel.text = "\(post["commentsCount"])"
        cell.instagramPost = post
        
        return cell
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let post = posts[section] as? PFObject
        let user = (post!["author"]) as! PFUser
        let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("TableSectionHeader") as! TableSectionHeader
        
        
        cell.delegate = self
        cell.profileButton.tag = section
        let header = cell as! TableSectionHeader
        
        header.headerUserLabel.text = user.username
        if let time = (post!["timestamp"]) as? String {
            header.headerTimeLabel.text = time
        }
        header.headerImageView.layer.borderWidth = 1
        header.headerImageView.layer.masksToBounds = false
        header.headerImageView.layer.cornerRadius = header.headerImageView.frame.height/2
        header.headerImageView.clipsToBounds = true
        if ((user["profilepic"] as? PFFile) != nil) {
            header.headerImageView.file = user["profilepic"] as? PFFile
            header.headerImageView.loadInBackground()
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    //LOAD MORE/INFINITE SCROLLING
    func loadMoreData() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        limit += 1
        query.limit = limit
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.posts = objects
                self.tableView.reloadData()
                self.loadingMoreView!.stopAnimating()
            } else {
                print("Error: \(error!) \(error!.userInfo)") //error
            }
        }
        self.isMoreDataLoading = false
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the position of one screen length before the bottom of the results
        let scrollViewContentHeight = tableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
            isMoreDataLoading = true
            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            loadMoreData()
        }
    }
    
    
    func goToUserScreen(sender: AnyObject) {
        print("hello from header to Home View Controller")
        performSegueWithIdentifier("userSegue", sender: sender)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //if sender.identifier == "idofDetailViewSegue" {
        if let detailVC = segue.destinationViewController as? DetailViewController {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            if let post = posts[indexPath!.section] as? PFObject {
                detailVC.detailPost = post
            }
        }
        if let userVC = segue.destinationViewController as? UserViewController {
            
            let indexPathSection = sender.tag
            
            if let post = posts[indexPathSection] as? PFObject {
                userVC.user = post["author"] as! PFUser
            }
        }
    }
    
}