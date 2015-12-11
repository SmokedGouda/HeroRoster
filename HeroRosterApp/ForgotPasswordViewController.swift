//
//  ForgotPasswordViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/24/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        roundTheButtons()
        adjustAlphaForUiElements(0.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.8)}, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func cancelButtonPressed(sender: UIButton) {
        executeUnwindForSegueSequence()
    }
    
    func executeUnwindForSegueSequence() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0)}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "unwindSegueToLogInView", userInfo: nil, repeats: false)
    }
    
    func unwindSegueToLogInView() {
        self.performSegueWithIdentifier("forgotPasswordSegue", sender: self)
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func resetPasswordButtonPressed(sender: UIButton) {
        if emailTextField.text == "" {
            emptyEmailTextFieldAlert()
        } else {
            PFUser.requestPasswordResetForEmailInBackground(emailTextField.text!) {(success: Bool, error: NSError?) -> Void in
                if error != nil {
                    self.displayErrorAlert(error!)
                } else {
                    self.resetPasswordAlert()
                }
            }
        }
    }
    
    func emptyEmailTextFieldAlert() {
        let alert = UIAlertController(title: "Can't reset password", message: "You must provide a valid e-mail.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayErrorAlert(errorToCheck: NSError) {
        var title = String()
        var message = String()
        switch errorToCheck.code {
            case 100:
                title = "Network connection error"
                message = "Unable to send password reset request at this time."
            
            case 205:
                title = "Invalid e-mail"
                message = "No user found with email \(emailTextField.text!)"
            
            default:
                title = "Unknown error"
                message = "An unknown error has occured.  Please try again."
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func resetPasswordAlert() {
        let alert = UIAlertController(title: "Reset password request sent", message: "Check your e-mail for a message which will assist you in reseting your password.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: { (actionSheetController) -> Void in self.executeUnwindForSegueSequence()
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func roundTheButtons() {
        emailTextField.layer.borderColor = UIColor.blackColor().CGColor
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.masksToBounds = true
        emailTextField.layer.cornerRadius = 5
        resetPasswordButton.layer.borderColor = UIColor.blackColor().CGColor
        resetPasswordButton.layer.borderWidth = 1.0
        resetPasswordButton.layer.cornerRadius = 5
        cancelButton.layer.borderColor = UIColor.blackColor().CGColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 5
    }
    
    func adjustAlphaForUiElements(alpha: CGFloat) {
        emailTextField.alpha = alpha
        resetPasswordButton.alpha = alpha
        cancelButton.alpha = alpha
    }
}
