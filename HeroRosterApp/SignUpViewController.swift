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
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGestureRecognizerForKeyboardDismiss()
        setTheBackgroundViewToClearColor()
        adjustBordersOfUiElements()
        adjustAlphaForUiElements(0.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
         UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.8)}, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func createGestureRecognizerForKeyboardDismiss() {
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setTheBackgroundViewToClearColor() {
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
    }
    
    func adjustBordersOfUiElements() {
        newUserNameTextField.layer.borderColor = UIColor.blackColor().CGColor
        newUserNameTextField.layer.borderWidth = 1.0
        newUserNameTextField.layer.masksToBounds = true
        newUserNameTextField.layer.cornerRadius = 5
        newUserEmailTextField.layer.borderColor = UIColor.blackColor().CGColor
        newUserEmailTextField.layer.borderWidth = 1.0
        newUserEmailTextField.layer.masksToBounds = true
        newUserEmailTextField.layer.cornerRadius = 5
        newUserPasswordTextField.layer.borderColor = UIColor.blackColor().CGColor
        newUserPasswordTextField.layer.borderWidth = 1.0
        newUserPasswordTextField.layer.masksToBounds = true
        newUserPasswordTextField.layer.cornerRadius = 5
        createAccountButton.layer.borderColor = UIColor.blackColor().CGColor
        createAccountButton.layer.borderWidth = 1.0
        createAccountButton.layer.cornerRadius = 5
        cancelButton.layer.borderColor = UIColor.blackColor().CGColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 5
    }
    
    func adjustAlphaForUiElements(alpha: CGFloat) {
        newUserNameTextField.alpha = alpha
        newUserPasswordTextField.alpha = alpha
        newUserEmailTextField.alpha = alpha
        createAccountButton.alpha = alpha
        cancelButton.alpha = alpha
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissKeyboard()
        executeUnwindForSegueSequence()
    }
    
    func executeUnwindForSegueSequence() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0)}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "unwindSegueToLogInView", userInfo: nil, repeats: false)
    }
    
    func unwindSegueToLogInView() {
        self.performSegueWithIdentifier("signupSegue", sender: self)
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }

    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        dismissKeyboard()
        if newUserNameTextField.text == "" || newUserPasswordTextField.text == "" || newUserEmailTextField.text == "" {
            displayEmptyUserFieldsAlert()
        } else {
            displayPrivacyPolicyAcceptanceAlert()
        }
    }
    
    func displayEmptyUserFieldsAlert() {
        let alert = UIAlertController(title: "Can't create user account", message: "You must provide a username, password, and e-mail to proceed.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func displayPrivacyPolicyAcceptanceAlert() {
        let alert = UIAlertController(title: "About to create account", message: "By tapping Ok, you agree to the terms of the Privacy Policy described in this app.  If you do not, tap Cancel to abort the account creation process.", preferredStyle: .Alert)
        let acceptAction = UIAlertAction(title: "Ok", style: .Default, handler: { (actionSheetController) -> Void in
            self.startAccountCreationProcess()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func startAccountCreationProcess() {
        let user = PFUser()
        user.username = newUserNameTextField.text
        user.password = newUserPasswordTextField.text
        user.email = newUserEmailTextField.text
        user.signUpInBackgroundWithBlock {(succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                self.displayErrorAlert(error!)
            } else {
                self.logInNewUser()
            }
        }
    }
    
    func displayErrorAlert(errorToCheck: NSError) {
        var title = String()
        var message = String()
        switch errorToCheck.code {
            case 100:
                title = "Network connection error"
                message = "Unable to log in at this time"
            case 125:
                title = "Can't create user account"
                message = "The e-mail address you provided is not valid.  Please choose another."
            case 202:
                title = "Can't create user account"
                message = "That username has already been used.  Please choose another."
            case 203:
                title = "Can't create user account"
                message = "That e-mail address has already been used.  Please choose another."
            default:
                title = "Can't create user account"
                message = "An unknown error has occured.  Please try again."
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
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
        let heroRoster = Roster(userName: newUserNameTextField.text!, heros: [], usedHeroNames: [], scenarioRecords: [String : [String]](), gmSessionLogs: [], usedGmScenarioNames: [], parseObjectId: "")
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
    
    func accountCreationAlert() {
        let alert = UIAlertController(title: "Account creation successful", message: "You will receive a e-mail to verify your account shortly.  Click the link you receive in your e-mail to activate your account and allow you access to login.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler:  { (actionSheetController) -> Void in self.executeUnwindForSegueSequence()
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
