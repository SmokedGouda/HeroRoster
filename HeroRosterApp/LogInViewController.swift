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

    var activeUser = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if segue.identifier == "heroRosterSegue" {
           let destVC: HeroRosterViewController = segue.destinationViewController as! HeroRosterViewController
            userNameField.text = ""
            userPasswordField.text = ""
        }
    }
    
   @IBAction func loginButtonPressed(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(userNameField.text!, password: userPasswordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                dispatch_async(dispatch_get_main_queue()){
                print("Login successful")
                self.activeUser = PFUser.currentUser()
                self.performSegueWithIdentifier("heroRosterSegue", sender: self)
                }
            } else {
                print("Login failed")
            }
        }
    }
}

