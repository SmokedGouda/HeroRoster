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
    

    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        if newUserNameTextField.text != "" && newUserPasswordTextField.text != "" {
            let user = PFUser()
            user.username = newUserNameTextField.text
            user.password = newUserPasswordTextField.text
//            var userRoster = PFObject(className: "Roster")
//            var heroRoster = Roster(userName: "\(newUserNameTextField.text!)'s hero roster", heros: [], usedHeroNames: [])
//            userRoster["name"] = heroRoster.userName
//            userRoster["heros"] = heroRoster.heros
//            userRoster["usedHeroNames"] = heroRoster.usedHeroNames
//            user["roster"] = heroRoster
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? NSString
                } else {
                    print("account creation successfull")
                    self.performSegueWithIdentifier("signupSegue", sender: self)
                }
            }
        } else {
            print("You need to enter a new username and password")
        }
    }
   
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("signupSegue", sender: self)
    }

}
