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
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        createAccountButton.layer.cornerRadius = 5
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    // Create a new user account, and if successfull, automatically log the user in.
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        if newUserNameTextField.text != "" && newUserPasswordTextField.text != "" && newUserEmailTextField.text != "" {
            let user = PFUser()
            user.username = newUserNameTextField.text
            user.password = newUserPasswordTextField.text
            user.email = newUserEmailTextField.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if error != nil {
                    self.displayErrorAlert(error!)
                } else {
                    self.logInNewUser()
                }
            }
        } else {
            emptyUserFieldsAlert()
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
                PFUser.logOut()
                self.accountCreationAlert()
            } else {
                print("Roster object failed to save to user's account.")
            }
        }
    }
    
    func displayErrorAlert(errorToCheck: NSError) {
        switch errorToCheck.code {
            case 100:
                let alert = UIAlertController(title: "Network connection error", message: "Unable to log in at this time", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            
            case 202:
                let alert = UIAlertController(title: "Can't create user account", message: "That username has already been used.  Please choose another.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            
            case 203:
                let alert = UIAlertController(title: "Can't create user account", message: "That e-mail address has already been used.  Please choose another.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)

            default:
                "Nothing Happening"
        }
    }
    
    func accountCreationAlert() {
        let alert = UIAlertController(title: "Account creation successful", message: "You will receive a e-mail to verify your account shortly.  Click the link you receive in your e-mail to activate your account and allow you access to login.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler:  { (actionSheetController) -> Void in self.performSegueWithIdentifier("signupSegue", sender: self)
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func emptyUserFieldsAlert() {
        let alert = UIAlertController(title: "Can't create user account", message: "You must provide a user name, password, and e-mail to proceed.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
}
