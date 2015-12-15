//
//  ScenarioSearchViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 12/4/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class ScenarioSearchViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scenarioNameTextView: UITextView!
    @IBOutlet weak var searchHeroRecordsButton: UIButton!
    @IBOutlet weak var searchGmRecordsButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var activeRoster = Roster?()
    var foundName = String()
    var foundDate = String()
    var matchCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundTheLabelsAndButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func searchHeroRecordsButtonPressed(sender: UIButton) {
        if scenarioNameTextView.text == "" {
            displaySearchResultsAlert("empty")
        } else {
            searchScenarioRecordsForMatch()
            displayScenarioSearchResult()
        }
    }
    
    @IBAction func searchGmRecordsButtonPressed(sender: UIButton) {
        if scenarioNameTextView.text == "" {
            displaySearchResultsAlert("empty")
        } else {
            searchGmScenarioRecordsForMatch()
            displayGmScenarioSearchResult()
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(ScenarioListViewController)) {
            let scenarioName: ScenarioListViewController = unwindSegue.sourceViewController as! ScenarioListViewController
            scenarioNameTextView.text = scenarioName.nameToReturn
        }
    }
    
    func searchScenarioRecordsForMatch() {
        for (key, value) in activeRoster!.scenarioRecords {
            if key == scenarioNameTextView.text! {
                foundName = value[0]
                foundDate = value[1]
                matchCount++
            }
        }
    }
    
    func searchGmScenarioRecordsForMatch() {
        for scenario in activeRoster!.gmSessionLogs{
            if scenario.name == scenarioNameTextView.text {
                foundDate = GmSessionLog().stringFromDate(scenario.date)
                matchCount++
            }
        }
    }
    
    func displayScenarioSearchResult() {
        if matchCount == 1 {
            displaySearchResultsAlert("match")
            matchCount = 0
        } else {
            displaySearchResultsAlert("noMatch")
        }
    }
    
    func displayGmScenarioSearchResult() {
        if matchCount == 1 {
            displaySearchResultsAlert("gmMatch")
            matchCount = 0
        } else {
            displaySearchResultsAlert("noGmMatch")
        }
    }
    
    func displaySearchResultsAlert(result: String) {
        var title = String()
        var message = String()
        switch result {
            case "match":
                title = "You've played this scenario"
                message = "\(scenarioNameTextView.text) was played by \(foundName) on \(foundDate)."
            case "gmMatch":
                title = "You've run this scenario as a GM"
                message = "\(scenarioNameTextView.text) was run on \(foundDate)."
            case "noMatch":
                title = "No record found"
                message = "You have not played \(scenarioNameTextView.text)."
            case "noGmMatch":
                title = "No record found"
                message = "You have not run \(scenarioNameTextView.text) as a GM."
            case "empty":
                title = "Can't search the records"
                message = "You must provide a scenario name in order to do a search."
            default:
                "no action"
        }
        
        let alert = UIAlertController(
            title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(
            title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView == scenarioNameTextView {
            self.performSegueWithIdentifier("scenarioListSegueTwo", sender: self)
        }
    }
    
    func roundTheLabelsAndButtons() {
        instructionLabel.layer.borderColor = UIColor.blackColor().CGColor
        instructionLabel.layer.borderWidth = 1.0
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.clipsToBounds = true
        scenarioNameTextView.layer.borderColor = UIColor.blackColor().CGColor
        scenarioNameTextView.layer.borderWidth = 1.0
        scenarioNameTextView.layer.masksToBounds = true
        scenarioNameTextView.layer.cornerRadius = 8
        searchHeroRecordsButton.layer.borderColor = UIColor.blackColor().CGColor
        searchHeroRecordsButton.layer.borderWidth = 1.0
        searchHeroRecordsButton.layer.cornerRadius = 5
        searchGmRecordsButton.layer.borderColor = UIColor.blackColor().CGColor
        searchGmRecordsButton.layer.borderWidth = 1.0
        searchGmRecordsButton.layer.cornerRadius = 5
        doneButton.layer.borderColor = UIColor.blackColor().CGColor
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.cornerRadius = 5
    }
}
