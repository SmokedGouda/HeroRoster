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
            PFUser.requestPasswordResetForEmailInBackground(emailTextField.text!)
            resetPasswordAlert()
        }
    }
    
    func emptyEmailTextFieldAlert() {
        let alert = UIAlertController(title: "Can't reset password.", message: "You must provide a valid e-mail.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func resetPasswordAlert() {
        let alert = UIAlertController(title: "Reset password request sent.", message: "Check your e-mail for a message which will assist you in reseting your password.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: { (actionSheetController) -> Void in self.performSegueWithIdentifier("forgotPasswordSegue", sender: self)
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
