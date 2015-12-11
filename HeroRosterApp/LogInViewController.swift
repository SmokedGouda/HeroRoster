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
    
    @IBOutlet weak var heroRosterLogo: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newUserSignUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    
    var activeUser = PFUser.currentUser()
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        navigationController?.navigationBar.alpha = 0.0
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        roundTheButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func newUserSignUpButtonPressed(sender: UIButton) {
        dismissKeyboard()
        executeNewUserSignupSegueSequence()
    }
    
    @IBAction func forgotPasswordButtonPressed(sender: UIButton) {
        dismissKeyboard()
        executeForgotPasswordSegueSequence()
    }
    
    @IBAction func creditsButtonPressed(sender: UIButton) {
        executeCreditsSegueSequence()
    }
    
    func executeNewUserSignupSegueSequence() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0)}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "segueToNewUserSignup", userInfo: nil, repeats: false)
    }
    
    func executeForgotPasswordSegueSequence() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0)}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "segueToForgotPassword", userInfo: nil, repeats: false)
    }
    
    func executeCreditsSegueSequence() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0); self.adjustAlphaForLogo(0.0)}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "segueToCredits", userInfo: nil, repeats: false)
    }
    
    func segueToNewUserSignup() {
        self.performSegueWithIdentifier("signupSegue", sender: self)
    }
    
    func segueToForgotPassword() {
        self.performSegueWithIdentifier("forgotPasswordSegue", sender: self)
    }
    
    func segueToCredits() {
        self.performSegueWithIdentifier("creditsSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        userNameField.text = ""
        userPasswordField.text = ""
        if segue.identifier == "heroRosterSegue" {
            navigationController?.navigationBarHidden = false
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.navigationController?.navigationBar.alpha = 1.0}, completion: nil)
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
            UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.8); self.adjustAlphaForLogo(1.0)}, completion: nil)
    }
    
   @IBAction func loginButtonPressed(sender: AnyObject) {
        startLoginProcess()
    }
    
    func startLoginProcess() {
        if userNameField.text == "" || userPasswordField.text == "" {
            displayLoginAlert("emptyUserFields")
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
                            self.displayLoginAlert("unverifiedEmail")
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
                    self.activeUser = PFUser.currentUser()
                    self.dismissKeyboard()
                    self.performSegueWithIdentifier("heroRosterSegue", sender: self)
                }
            } else {
                print(error)
                self.invalidLoginAlert(error!)
            }
        }
    }
    
    func displayLoginAlert(alertToDisplay: String) {
        let title = "Can't login to user account"
        var message = String()
        switch alertToDisplay {
            case "unverifiedEmail":
                message = "You must first verify your e-mail before you can log in."
            case "emptyUserFields":
                message = "You must provide a username and password to proceed."
            default:
                "No Message"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func invalidLoginAlert(errorToCheck: NSError) {
        var title = String()
        var message = String()
        switch errorToCheck.code {
            case 100:
                title = "Network connection error"
                message = "Unable to login at this time."
            
            case 101:
                title = "Invalid login"
                message = "The password you provided is invalid."
            
            default:
                title = "Unknown error"
                message = "Unable to login at this time."
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)

    }
    
    func invalidUserNameAlert() {
        let alert = UIAlertController(title: "Invalid user name", message: "The username you provided does not exist.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func roundTheButtons () {
        userNameField.layer.borderColor = UIColor.blackColor().CGColor
        userNameField.layer.borderWidth = 1.0
        userNameField.layer.masksToBounds = true
        userNameField.layer.cornerRadius = 5
        userPasswordField.layer.borderColor = UIColor.blackColor().CGColor
        userPasswordField.layer.borderWidth = 1.0
        userPasswordField.layer.masksToBounds = true
        userPasswordField.layer.cornerRadius = 5
        loginButton.layer.borderColor = UIColor.blackColor().CGColor
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.cornerRadius = 5
        newUserSignUpButton.layer.borderColor = UIColor.blackColor().CGColor
        newUserSignUpButton.layer.borderWidth = 1.0
        newUserSignUpButton.layer.cornerRadius = 5
        forgotPasswordButton.layer.borderColor = UIColor.blackColor().CGColor
        forgotPasswordButton.layer.borderWidth = 1.0
        forgotPasswordButton.layer.cornerRadius = 5
        creditsButton.layer.borderColor = UIColor.blackColor().CGColor
        creditsButton.layer.borderWidth = 1.0
        creditsButton.layer.cornerRadius = 5
    }
    
    func adjustAlphaForUiElements(alpha: CGFloat) {
        userNameField.alpha = alpha
        userPasswordField.alpha = alpha
        loginButton.alpha = alpha
        newUserSignUpButton.alpha = alpha
        forgotPasswordButton.alpha = alpha
        creditsButton.alpha = alpha
    }
    
    func adjustAlphaForLogo(alpha: CGFloat) {
        heroRosterLogo.alpha = alpha
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
        if sender == userPasswordField {
            startLoginProcess()
        }
    }
}

