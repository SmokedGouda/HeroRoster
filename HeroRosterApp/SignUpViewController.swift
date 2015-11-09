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
//            destVC.activeUser = newUserNameTextField.text!
        }
    }
    
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        // Attempt to create a new user and save it to Parse.com
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
                    // Automatically log in the new user after successful account creation
                    PFUser.logInWithUsernameInBackground(self.newUserNameTextField.text!, password: self.newUserPasswordTextField.text!) {
                        (user: PFUser?, error: NSError?) -> Void in
                        if user != nil {
                            print("Login successful")
                            self.createUserRoster()
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
  
    // Create the instance of Roster for the user which will be saved to Parse and store all of the users heros and their session logs.
    func createUserRoster () {
        let userRoster = PFObject(className: "Roster")
        let heroRoster = Roster(userName: "\(newUserNameTextField.text!)'s hero roster", heros: [], usedHeroNames: [])
        userRoster["name"] = heroRoster.userName
        userRoster["heros"] = heroRoster.heros
        userRoster["usedHeroNames"] = heroRoster.usedHeroNames
        userRoster.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("Roster object successfully saved to user's account.")
                self.performSegueWithIdentifier("heroRosterSegueTwo", sender: self)
            } else {
                print("Roster object failed to save to user's account.")
            }
        }
    }
}
