//
//  CameraViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/20/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    var timestamp: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onChooseImage(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(vc, animated: true, completion: nil)
    }
    @IBAction func onTakePhoto(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(vc, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let smallImage = resize(originalImage, newSize: CGSize(width: 1000, height: 1000))
        imageView.image = smallImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func onSubmit(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let imageToPost = imageView.image
        Post.postUserImage(imageToPost, withCaption: captionField.text) { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("picture posted successfully")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.performSegueWithIdentifier("postedSegue", sender: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
