//
//  SignUpViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/8/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var newUserNameTextField: UITextField!
    @IBOutlet weak var newUserPasswordTextField: UITextField!
    @IBOutlet weak var newUserEmailTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAccountButton.layer.cornerRadius = 5
    }

    // Create a new user account, and if successfull, automatically log the user in.
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        if newUserNameTextField.text != "" && newUserPasswordTextField.text != "" {
            let user = PFUser()
            user.username = newUserNameTextField.text
            user.password = newUserPasswordTextField.text
            user.email = newUserEmailTextField.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if error != nil {
                    self.duplicateUserNameAlert(error!)
                    self.networkConnectionFailureAlert(error!)
                } else {
                    print("account creation successfull")
                    self.logInNewUser()
                }
            }
        } else {
            print("You need to enter a new username and password")
        }
    }

    func logInNewUser() {
        PFUser.logInWithUsernameInBackground(self.newUserNameTextField.text!, password: self.newUserPasswordTextField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("Login successful")
                self.createUserRoster()
            } else {
                print("Login failed")
            }
        }
    }
    
    func createUserRoster () {
        let userRoster = PFObject(className: "Roster")
        let heroRoster = Roster(userName: "\(newUserNameTextField.text!)'s hero roster", heros: [], usedHeroNames: [])
        userRoster["name"] = heroRoster.userName
        userRoster.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("Roster object successfully saved to user's account.")
                self.performSegueWithIdentifier("heroRosterSegueTwo", sender: self)
            } else {
                print("Roster object failed to save to user's account.")
            }
        }
    }
    
    func duplicateUserNameAlert(errorToCheck: NSError) {
        if errorToCheck.code == 202 {
            let alert = UIAlertController(title: "Can't create user account.", message: "That username has already been used.  Please choose another.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func networkConnectionFailureAlert(errorToCheck: NSError) {
        if errorToCheck.code == 100 {
            let alert = UIAlertController(title: "Network Connection Error", message: "Unable to log in at this time", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
}
