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
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
   @IBAction func loginButtonPressed(sender: AnyObject) {
        startLoginProcess()
    }
    
    func startLoginProcess() {
        if userNameField.text == "" || userPasswordField.text == "" {
            emptyUserFieldsAlert()
        } else {
            let query = PFUser.query()
            query?.whereKey("username", equalTo: userNameField.text!)
            query?.findObjectsInBackgroundWithBlock { (userInfo: [PFObject]?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if userInfo!.count == 0 {
                    self.invalidUserNameAlert()
                } else {
                    for object:PFObject in userInfo! {
                        if object["emailVerified"] as! Bool == false {
                            self.unverifiedEmailAlert()
                        } else {
                            self.loginUser()
                        }
                    }
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
        let alert = UIAlertController(title: "Can't login to user account", message: "You must first verify your e-mail before you can log in.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func emptyUserFieldsAlert() {
        let alert = UIAlertController(title: "Can't login to user account", message: "You must provide a username and password to proceed.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func invalidLoginAlert(errorToCheck: NSError) {
        switch errorToCheck.code {
            case 100:
                let alert = UIAlertController(title: "Network connection error", message: "Unable to login at this time.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)

            case 101:
                let alert = UIAlertController(title: "Invalid login", message: "The password you provided is invalid.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            
            default:
                "Nothing Happened"
        }
    }
    
    func invalidUserNameAlert() {
        let alert = UIAlertController(title: "Invalid user name", message: "The username you provided does not exist.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func roundTheButtons () {
        loginButton.layer.cornerRadius = 5
        newUserSignUpButton.layer.cornerRadius = 5
        forgotPasswordButton.layer.cornerRadius = 5
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
        if sender == userPasswordField {
            startLoginProcess()
        }
    }
}

