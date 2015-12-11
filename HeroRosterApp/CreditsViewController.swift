//
//  CreditsViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 12/9/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

    @IBOutlet weak var creditsTextView: UITextView!
    @IBOutlet weak var backButton: UIButton!
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        prepTheButtonAndTextView()
        adjustAlphaForUiElements(0.0)
        creditsTextView.text = credits
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.8)}, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    @IBAction func backButtonPressed(sender: UIButton) {
        executeUnwindForSegueSequence()
    }
    
    func executeUnwindForSegueSequence() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {self.adjustAlphaForUiElements(0.0)}, completion: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "unwindSegueToLogInView", userInfo: nil, repeats: false)
    }
    
    func unwindSegueToLogInView() {
        self.performSegueWithIdentifier("creditsSegue", sender: self)
    }
    
    func prepTheButtonAndTextView() {
        creditsTextView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        creditsTextView.selectable = false
        creditsTextView.layer.cornerRadius = 8
        backButton.layer.borderColor = UIColor.blackColor().CGColor
        backButton.layer.borderWidth = 1.0
        backButton.layer.cornerRadius = 5
    }

    func adjustAlphaForUiElements(alpha: CGFloat) {
        creditsTextView.alpha = alpha
        backButton.alpha = alpha
    }
}
