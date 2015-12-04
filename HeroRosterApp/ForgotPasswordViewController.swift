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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        resetPasswordButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
        switch errorToCheck.code {
            case 100:
                let alert = UIAlertController(title: "Network connection error", message: "Unable to send password reset request at this time.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            
            case 205:
                let alert = UIAlertController(title: "Invalid e-mail", message: "No user found with email \(emailTextField.text!)", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            
            default:
                "Nothing Happened"
        }
    }
    
    func resetPasswordAlert() {
        let alert = UIAlertController(title: "Reset password request sent", message: "Check your e-mail for a message which will assist you in reseting your password.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: { (actionSheetController) -> Void in self.performSegueWithIdentifier("forgotPasswordSegue", sender: self)
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
