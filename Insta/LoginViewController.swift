//
//  LoginViewController.swift
//  Insta
//
//  Created by Nancy Yao on 6/20/16.
//  Copyright © 2016 Nancy Yao. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var dummyViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    func keyboardWillShow(notification: NSNotification!) {
        print("keyboard shown")
        let info = notification.userInfo
        let keyboardFrame = info![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardHeight = keyboardFrame?.size.height
        dummyViewBottomConstraint.constant = keyboardHeight!
        view.layoutIfNeeded()
    }
    func keyboardWillHide(notification: NSNotification!) {
        dummyViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    private func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // handle response here.
        }
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true) {
            // optional code for what happens after the alert controller has finished presenting
        }
    }
    @IBAction func onLogIn(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            if let error = error {
                print("User login failed.")
                print(error.localizedDescription)
                self.alert("Alert:", message: "Error logging in, please try again")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
                print("User logged in successfully")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func onSignUp(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let newUser = PFUser()
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.alert("Alert:", message: "Error signing up, please try again")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
                print("User Registered successfully")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
