//
//  ViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newUserSignUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var activeUser = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        roundTheButtons()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            userNameField.text = ""
            userPasswordField.text = ""
    }
    
   @IBAction func loginButtonPressed(sender: AnyObject) {
        if userNameField.text == "" || userPasswordField.text == "" {
            emptyUserFieldsAlert()
        } else {
            let query = PFUser.query()
            query?.whereKey("username", equalTo: userNameField.text!)
            query?.findObjectsInBackgroundWithBlock { (emailVerified: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    for object:PFObject in emailVerified! {
                        if object["emailVerified"] as! Bool == false {
                            self.unverifiedEmailAlert()
                        } else {
                            self.loginUser()
                        }
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    func loginUser() {
        PFUser.logInWithUsernameInBackground(userNameField.text!, password: userPasswordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                dispatch_async(dispatch_get_main_queue()){
                    print("Login successful")
                    self.activeUser = PFUser.currentUser()
                    self.performSegueWithIdentifier("heroRosterSegue", sender: self)
                }
            } else {
                print(error)
                self.invalidLoginAlert(error!)
            }
        }
    }
    
    func unverifiedEmailAlert() {
        let alert = UIAlertController(title: "Can't login to user account.", message: "You must first verify your e-mail before you can log in.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func emptyUserFieldsAlert() {
        let alert = UIAlertController(title: "Can't login to user account.", message: "You must provide a user name and password to proceed.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func invalidLoginAlert(errorToCheck: NSError) {
        if errorToCheck.code == 101 {
            let alert = UIAlertController(title: "Invalid Login", message: "The user name or password you provided is invalid.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }


    func roundTheButtons () {
        loginButton.layer.cornerRadius = 5
        newUserSignUpButton.layer.cornerRadius = 5
        forgotPasswordButton.layer.cornerRadius = 5
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
}

