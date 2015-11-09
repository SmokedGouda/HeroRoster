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

    override func viewDidLoad() {
        super.viewDidLoad()
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            self.performSegueWithIdentifier("heroRosterSegue", sender: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if segue.identifier == "heroRosterSegue" {
            let destVC: HeroRosterViewController = segue.destinationViewController as! HeroRosterViewController
            destVC.userRoster.userName = userNameField.text!
            userNameField.text = ""
            userPasswordField.text = ""
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    @IBAction func loginButtonPressed(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(userNameField.text!, password: userPasswordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("Login successful")
                self.performSegueWithIdentifier("heroRosterSegue", sender: self)
            } else {
                print("Login failed")
            }
        }
    }
}

