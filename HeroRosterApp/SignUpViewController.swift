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
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        createAccountButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

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
                self.createUserRoster()
            } else {
                print(error)
            }
        }
    }
    
    func createUserRoster () {
        let userRoster = PFObject(className: "Roster")
        let heroRoster = Roster(userName: newUserNameTextField.text!, heros: [], usedHeroNames: [], scenarioRecords: [String : [String]](), parseObjectId: "")
        userRoster["name"] = heroRoster.userName
        userRoster["scenarioRecords"] = heroRoster.scenarioRecords
        userRoster.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                PFUser.logOut()
                self.accountCreationAlert()
            } else {
                print(error)
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
        let alert = UIAlertController(title: "Can't create user account", message: "You must provide a username, password, and e-mail to proceed.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
}
