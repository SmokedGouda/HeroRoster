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
        creditsTextView.layer.cornerRadius = 8
        backButton.layer.cornerRadius = 5
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        adjustAlphaForUiElements(0.0)
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

    func adjustAlphaForUiElements(alpha: CGFloat) {
        creditsTextView.alpha = alpha
        backButton.alpha = alpha
    }
}
