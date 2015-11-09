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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "heroRosterSegueTwo" {
            let destVC: HeroRosterViewController = segue.destinationViewController as! HeroRosterViewController
            destVC.userRoster.userName = newUserNameTextField.text!
        }
    }
    
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        if newUserNameTextField.text != "" && newUserPasswordTextField.text != "" {
            let user = PFUser()
            user.username = newUserNameTextField.text
            user.password = newUserPasswordTextField.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                } else {
                    print("account creation successfull")
                    PFUser.logInWithUsernameInBackground(self.newUserNameTextField.text!, password: self.newUserPasswordTextField.text!) {
                        (user: PFUser?, error: NSError?) -> Void in
                        if user != nil {
                            print("Login successful")
                            self.performSegueWithIdentifier("heroRosterSegueTwo", sender: self)
                        } else {
                            print("Login failed")
                        }
                    }
                }
            }
        } else {
            print("You need to enter a new username and password")
        }
    }
    //            var userRoster = PFObject(className: "Roster")
    //            var heroRoster = Roster(userName: "\(newUserNameTextField.text!)'s hero roster", heros: [], usedHeroNames: [])
    //            userRoster["name"] = heroRoster.userName
    //            userRoster["heros"] = heroRoster.heros
    //            userRoster["usedHeroNames"] = heroRoster.usedHeroNames
    //            user["roster"] = heroRoster

}
