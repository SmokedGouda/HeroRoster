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

    var activeUser = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundTheButtons()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            userNameField.text = ""
            userPasswordField.text = ""
    }
    
   @IBAction func loginButtonPressed(sender: AnyObject) {
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
            }
        }
    }
    
    func unverifiedEmailAlert() {
        let alert = UIAlertController(title: "Can't login to account.", message: "You must first verify your e-mail before you can log in.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func roundTheButtons () {
        loginButton.layer.cornerRadius = 5
        newUserSignUpButton.layer.cornerRadius = 5
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
}

