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
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    var activeUser = PFUser.currentUser()
    var timer = NSTimer()
    var logoAlphaValue: CGFloat = 1.0
    var legalText = Legal()
    var legalTextToDisplay = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideTheNavigationBar()
        createGestureRecognizerForKeyboardDismiss()
        adjustBordersOfUiElements()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func hideTheNavigationBar() {
        navigationController?.navigationBarHidden = true
        navigationController?.navigationBar.alpha = 0.0
    }
    
    func createGestureRecognizerForKeyboardDismiss() {
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func adjustBordersOfUiElements () {
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
        privacyPolicyButton.layer.borderColor = UIColor.blackColor().CGColor
        privacyPolicyButton.layer.borderWidth = 1.0
        privacyPolicyButton.layer.cornerRadius = 5
    }

    @IBAction func newUserSignUpButtonPressed(sender: UIButton) {
        dismissKeyboard()
        executeSegueSequence("segueToNewUserSignup")
    }
    
    func executeSegueSequence(segueToPerform: Selector) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0, logoAlpha: self.logoAlphaValue )}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: segueToPerform, userInfo: nil, repeats: false)
    }
    
    func adjustAlphaForUiElements(alpha: CGFloat, logoAlpha: CGFloat) {
        userNameField.alpha = alpha
        userPasswordField.alpha = alpha
        loginButton.alpha = alpha
        newUserSignUpButton.alpha = alpha
        forgotPasswordButton.alpha = alpha
        creditsButton.alpha = alpha
        privacyPolicyButton.alpha = alpha
        heroRosterLogo.alpha = logoAlpha
    }
    
    func segueToNewUserSignup() {
        self.performSegueWithIdentifier("signupSegue", sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(sender: UIButton) {
        dismissKeyboard()
        executeSegueSequence("segueToForgotPassword")
    }
    
    func segueToForgotPassword() {
        self.performSegueWithIdentifier("forgotPasswordSegue", sender: self)
    }

    @IBAction func creditsButtonPressed(sender: UIButton) {
        dismissKeyboard()
        logoAlphaValue = 0.0
        legalTextToDisplay = legalText.credits
        executeSegueSequence("segueToCredits")
    }
    
    func segueToCredits() {
        self.performSegueWithIdentifier("creditsSegue", sender: self)
    }

    @IBAction func privacyPolicyButtonPressed(sender: UIButton) {
        logoAlphaValue = 0.0
        legalTextToDisplay = legalText.privacyPolicy
        executeSegueSequence("segueToCredits")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        userNameField.text = ""
        userPasswordField.text = ""
        if segue.identifier == "heroRosterSegue" {
            navigationController?.navigationBarHidden = false
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.navigationController?.navigationBar.alpha = 1.0}, completion: nil)
        } else if segue.identifier == "creditsSegue" {
            let destVC: CreditsViewController = segue.destinationViewController as! CreditsViewController
            destVC.legalText = legalTextToDisplay
        }
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
        logoAlphaValue = 1.0
        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.8, logoAlpha: self.logoAlphaValue)}, completion: nil)
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
        if sender == userPasswordField {
            startLoginProcess()
        }
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        dismissKeyboard()
        startLoginProcess()
    }
    
    func startLoginProcess() {
        if userNameField.text == "" || userPasswordField.text == "" {
            displayInvalidLoginAlert("emptyUserFields")
        } else {
            queryParseForUser()
        }
    }
    
    func displayInvalidLoginAlert(alertToDisplay: String) {
        let title = "Can't login to user account"
        var message = String()
        switch alertToDisplay {
            case "emptyUserFields":
                message = "You must provide a username and password to proceed."
            case "invalidUserName":
                message = "The username you provided does not exist."
            case "unverifiedEmail":
                message = "You must first verify your e-mail before you can log in."
            default:
                "No Message"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func queryParseForUser() {
        let query = PFUser.query()
        query?.whereKey("username", equalTo: userNameField.text!)
        query?.findObjectsInBackgroundWithBlock { (userInfo: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if userInfo!.count == 0 {
                self.displayInvalidLoginAlert("invalidUserName")
            } else {
                self.checkUserEmailVerificationStatus(userInfo!)
            }
        }
    }
    
    func checkUserEmailVerificationStatus(userInfo: [PFObject]) {
        for object:PFObject in userInfo {
            if object["emailVerified"] as! Bool == false {
                self.displayInvalidLoginAlert("unverifiedEmail")
            } else {
                self.loginUser()
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
                self.displayErrorAlert(error!)
            }
        }
    }
    
    func displayErrorAlert(errorToCheck: NSError) {
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
}

