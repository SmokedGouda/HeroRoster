//
//  LogDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/6/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class LogDetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scenarioNameTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var addLogButton: UIButton!
    @IBOutlet weak var scenarioNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
      
    var activeRoster = Roster?()
    var heroDisplayed = Hero?()
    var heroLogDisplayed = SessionLog?()
    var date = String()
    var notes = String()
    var newSenarioName = String()
    var sessionLogNameBeforeEdit = String()
    var activateEditMode = false
    var newLogObjectId = String()
    var sectionIndex: Int?
    var rowIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        roundTheLabelsAndButtons()
        loadTheDateFieldWithCurrentDate()
        
        if activateEditMode == true {
            loadTheViewWithSelectedSession()
            setViewToStaticMode()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        findIndexValuesForPreviouslySelectedScenarioName()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addLogButtonPressed(sender: UIButton) {
        let buttonLabel = addLogButton.titleLabel!.text!
        switch buttonLabel {
            case "Edit Log":
            setViewToEditMode()
            
            case "Save":
                if scenarioNameTextView.text != sessionLogNameBeforeEdit {
                    checkEditedLogNameAgainstUsedLogNames()
                } else {
                    activeRoster?.scenarioRecords[scenarioNameTextView.text] = [heroDisplayed!.name, dateTextField.text!]
                    saveEditedLog()
                }
            
            default:
                newSenarioName = scenarioNameTextView.text!
                if newSenarioName == "" {
                    displayEmptyScenarioNameAlert()
                } else if activeRoster?.scenarioRecords.keys.contains(newSenarioName) == true {
                    displayDuplicateSessionLogNameAlert(newSenarioName)
                } else {
                    date = dateTextField.text!
                    notes = notesTextView.text!
                    let newSessionLog = SessionLog(name: newSenarioName, date: date, notes: notes, parseObjectId: "")
                    activeRoster?.scenarioRecords[newSenarioName] = [heroDisplayed!.name, date]
                    createSessionLogOnParse(newSessionLog)
                    self.performSegueWithIdentifier("addSessionLogSegue", sender: self)
                }
        }
    }
    
    func checkEditedLogNameAgainstUsedLogNames() {
        if activeRoster?.scenarioRecords.keys.contains(scenarioNameTextView.text!) == true {
            displayDuplicateSessionLogNameAlert(scenarioNameTextView.text!)
        } else {
            updateScenarioRecords()
            saveEditedLog()
        }
    }
    
    func displayDuplicateSessionLogNameAlert(scenarioPlayedByHero: String) {
        let heroName = activeRoster?.scenarioRecords[scenarioPlayedByHero]![0]
        let alert = UIAlertController(
            title: "Can't save session", message: "That scenario has already been played by \(heroName!).  Please choose another one.", preferredStyle: .Alert)
        let action = UIAlertAction(
            title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayEmptyScenarioNameAlert() {
        let alert = UIAlertController(
            title: "Can't save session", message: "You must select a scenario name in order to save the session.", preferredStyle: .Alert)
        let action = UIAlertAction(
            title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateScenarioRecords() {
        activeRoster?.scenarioRecords[sessionLogNameBeforeEdit] = nil
        activeRoster?.scenarioRecords[scenarioNameTextView.text!] = [heroDisplayed!.name, dateTextField.text!]
          sessionLogNameBeforeEdit = scenarioNameTextView.text!
    }
    
    func saveEditedLog() {
        setViewToStaticMode()
        let updatedScenarioName = scenarioNameTextView.text
        let updatedDate = dateTextField.text
        let updatedNotes = notesTextView.text
        heroDisplayed?.updateSessionLog(heroLogDisplayed!, newName: updatedScenarioName!, newDate: updatedDate!, newNotes: updatedNotes)
        updateSessionLogOnParse()
        activeRoster!.updateScenarioRecordsOnParse(activeRoster!)
    }
    
    func createSessionLogOnParse(logToCreate: SessionLog) {
        let parseLog = PFObject(className: "Log")
        parseLog["owner"] = activeRoster!.userName
        parseLog["logForHero"] = heroDisplayed?.name
        parseLog["sessionName"] = logToCreate.name
        parseLog["date"] = logToCreate.date
        parseLog["notes"] = logToCreate.notes
        
        parseLog.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if (success) {
                dispatch_async(dispatch_get_main_queue()){
                    print("session log saved to parse")
                    self.newLogObjectId = parseLog.objectId!
                    logToCreate.parseObjectId = self.newLogObjectId
                    self.heroDisplayed?.addSessionLog(logToCreate)
                    print("The updated hero's log ids are \(self.heroDisplayed?.logIds)")
                    self.updateHeroLogIdsParse()
                    self.activeRoster!.updateScenarioRecordsOnParse(self.activeRoster!)
                }
            } else {
                print("hero did not save to parse")
            }
        }
    }
    
    func updateSessionLogOnParse() {
        let query = PFQuery(className:"Log")
        query.getObjectInBackgroundWithId(heroLogDisplayed!.parseObjectId) {
            (Log: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let log = Log {
                log["sessionName"] = self.scenarioNameTextView.text
                log["date"] = self.dateTextField.text
                log["notes"] = self.notesTextView.text
                log.saveInBackground()
                print("log updated on parse")
            }
        }
    }
    
    func updateHeroLogIdsParse() {
        let query = PFQuery(className:"Hero")
        query.getObjectInBackgroundWithId(heroDisplayed!.parseObjectId) {
            (Hero: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let hero = Hero {
                hero["logIds"] = self.heroDisplayed?.logIds
                hero.saveInBackground()
                print("hero updated on parse")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scenarioListSegue" {
            let destVC: ScenarioListViewController = segue.destinationViewController as! ScenarioListViewController
            destVC.lastSelectedSection = sectionIndex
            destVC.lastSelectedRow = rowIndex
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(ScenarioListViewController)) {
            let scenarioName: ScenarioListViewController = unwindSegue.sourceViewController as! ScenarioListViewController
            scenarioNameTextView.text = scenarioName.nameToReturn
        }
    }
    
    func findIndexValuesForPreviouslySelectedScenarioName() {
        for name in Scenarios().scenarioNames {
            if name.contains(scenarioNameTextView.text!) {
                rowIndex = name.indexOf(scenarioNameTextView.text)!
                for (index, value) in Scenarios().scenarioNames.enumerate() {
                    if name == value {
                        sectionIndex = index
                    }
                }
            }
        }
    }
    
    @IBAction func dateTextFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        if let dateString = heroLogDisplayed?.date {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            datePickerView.date = dateFormatter.dateFromString(dateString)!
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func loadTheDateFieldWithCurrentDate() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(NSDate())
    }
    
    func loadTheViewWithSelectedSession() {
        scenarioNameTextView.text = heroLogDisplayed!.name
        dateTextField.text = heroLogDisplayed!.date
        notesTextView.text = heroLogDisplayed!.notes
        sessionLogNameBeforeEdit = scenarioNameTextView.text!
    }
    
    func setViewToStaticMode() {
        addLogButton.setTitle("Edit Log", forState: UIControlState.Normal)
        scenarioNameTextView.editable = false
        dateTextField.enabled = false
        notesTextView.editable = false
    }
    
    func setViewToEditMode() {
        addLogButton.setTitle("Save", forState: UIControlState.Normal)
        scenarioNameTextView.editable = true
        dateTextField.enabled = true
        notesTextView.editable = true
    }
    
    func roundTheLabelsAndButtons() {
        addLogButton.layer.cornerRadius = 5
        scenarioNameLabel.layer.cornerRadius = 5
        scenarioNameLabel.clipsToBounds = true
        scenarioNameTextView.layer.cornerRadius = 8
        dateLabel.layer.cornerRadius = 5
        dateLabel.clipsToBounds = true
        notesLabel.layer.cornerRadius = 5
        notesLabel.clipsToBounds = true
        notesTextView.layer.cornerRadius = 8
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView == notesTextView {
            scrollView.setContentOffset(CGPointMake(0, 180), animated: true)
        } else if textView == scenarioNameTextView {
            self.performSegueWithIdentifier("scenarioListSegue", sender: self)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == notesTextView {
            scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }
    
    @IBAction func textFieldDoneEditing(sender: AnyObject) {
        sender.resignFirstResponder()
    }
}
