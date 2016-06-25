//
//  Comment.swift
//  Insta
//
//  Created by Nancy Yao on 6/23/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class Comment: NSObject {
    
    
    class func postComment(withComment commentText: String?, withMedia media: String?, withCompletion completion: PFBooleanResultBlock?) {
        
        let comment = PFObject(className: "Comment")
        
        comment["user"] = PFUser.currentUser() //person commenting
        comment["comment"] = commentText
        comment["media"] = media
        
        comment.saveInBackgroundWithBlock(completion)
    }
}