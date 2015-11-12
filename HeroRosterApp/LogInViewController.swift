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
        PFUser.logInWithUsernameInBackground(userNameField.text!, password: userPasswordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                dispatch_async(dispatch_get_main_queue()){
                print("Login successful")
                self.activeUser = PFUser.currentUser()
                self.performSegueWithIdentifier("heroRosterSegue", sender: self)
                }
            } else {
                print("Login failed")
            }
        }
    }
    
    func roundTheButtons () {
        loginButton.layer.cornerRadius = 5
        newUserSignUpButton.layer.cornerRadius = 5
    }
}

