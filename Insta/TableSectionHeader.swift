//
//  TableSectionHeader.swift
//  Insta
//
//  Created by Nancy Yao on 6/24/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol PostHeaderDelegate {
    func goToUserScreen(sender: AnyObject)
}

class TableSectionHeader: UITableViewHeaderFooterView {
    
    
    var delegate: PostHeaderDelegate?
    
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var headerUserLabel: UILabel!
    @IBOutlet weak var headerTimeLabel: UILabel!
    @IBOutlet weak var headerImageView: PFImageView!
    
    @IBAction func didTapHeaderButton(sender: AnyObject) {
        print("tepped header button")
        delegate?.goToUserScreen(sender)
    }
    
    
    
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
