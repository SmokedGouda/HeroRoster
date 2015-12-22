//
//  GmLogDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 12/8/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class GmLogDetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scenarioNameLabel: UILabel!
    @IBOutlet weak var scenarioNameTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var creditForHeroLabel: UILabel!
    @IBOutlet weak var creditForHeroTextField: UITextField!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var addLogButton: UIButton!
    
    var activeRoster = Roster?()
    var gmLogDisplayed = GmSessionLog()
    var date = NSDate()
    var notes = String()
    var creditForHeroName = String()
    var newScenarioName = String()
    var scenarioNameBeforeEdit = String()
    var activateEditMode = false
    var newGmLogObjectId = String()
    var sectionIndex: Int?
    var rowIndex: Int?
    var heroNameIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismiss)
        roundTheLabelsButtonsAndTextViews()
        loadTheDateFieldWithCurrentDate()
        if activateEditMode == true {
            loadTheViewWithSelectedSession()
            setViewToStaticMode()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        findIndexValuesForPreviouslySelectedScenarioName()
        if activateEditMode == true {
            findIndexValueForPreviouslySelectedHeroNameToCredit()
        }
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
            if scenarioNameTextView.text != scenarioNameBeforeEdit {
                checkEditedLogNameAgainstUsedLogNames()
            } else {
                saveEditedLog()
            }
            
        default:
            newScenarioName = scenarioNameTextView.text!
            if newScenarioName == "" {
                displayEmptyScenarioNameAlert()
            } else if activeRoster!.usedGmScenarioNames.contains(newScenarioName) == true {
                displayDuplicateGmSessionLogNameAlert(newScenarioName)
            } else {
                date = gmLogDisplayed.dateFromString(dateTextField.text!)
                notes = notesTextView.text!
                creditForHeroName = creditForHeroTextField.text!
                let newGmSessionLog = GmSessionLog(name: newScenarioName, date: date, notes: notes, parseObjectId: "", creditForHero: creditForHeroName)
                createGmSessionLogOnParse(newGmSessionLog)
                self.performSegueWithIdentifier("addGmSessionLogSegue", sender: self)
            }
        }
    }
    
    func checkEditedLogNameAgainstUsedLogNames() {
        if activeRoster!.usedGmScenarioNames.contains(scenarioNameTextView.text!) == true {
            displayDuplicateGmSessionLogNameAlert(scenarioNameTextView.text!)
        } else {
            saveEditedLog()
        }
    }
    
    func displayDuplicateGmSessionLogNameAlert(scenarioPlayedByHero: String) {
        let alert = UIAlertController(
            title: "Can't save session", message: "You have already GM'd that scenario.  Please choose another one.", preferredStyle: .Alert)
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
    
    func saveEditedLog() {
        setViewToStaticMode()
        let updatedScenarioName = scenarioNameTextView.text!
        let updatedDate = gmLogDisplayed.dateFromString(dateTextField.text!)
        let updatedNotes = notesTextView.text
        let updatedCreditForHeroName = creditForHeroTextField.text!
        activeRoster!.updateGmSessionLog(gmLogDisplayed, newName: updatedScenarioName, newDate: updatedDate, newNotes: updatedNotes, newCreditForHero: updatedCreditForHeroName)
        updateGmSessionLogOnParse()
    }
    
    func createGmSessionLogOnParse(logToCreate: GmSessionLog) {
        let parseGmLog = PFObject(className: "GmLog")
        parseGmLog["owner"] = activeRoster!.userName
        parseGmLog["sessionName"] = logToCreate.name
        parseGmLog["date"] = logToCreate.date
        parseGmLog["notes"] = logToCreate.notes
        parseGmLog["creditForHero"] = logToCreate.creditForHero
        
        parseGmLog.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if (success) {
                dispatch_async(dispatch_get_main_queue()){
                    self.newGmLogObjectId = parseGmLog.objectId!
                    logToCreate.parseObjectId = self.newGmLogObjectId
                    self.activeRoster?.addGmSessionLog(logToCreate)
                }
            } else {
                print(error)
            }
        }
    }
    
    func updateGmSessionLogOnParse() {
        let query = PFQuery(className:"GmLog")
        query.getObjectInBackgroundWithId(gmLogDisplayed.parseObjectId) {
            (GmLog: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let log = GmLog {
                log["sessionName"] = self.scenarioNameTextView.text
                log["date"] = self.gmLogDisplayed.dateFromString(self.dateTextField.text!)
                log["notes"] = self.notesTextView.text
                log["creditForHero"] = self.creditForHeroTextField.text
                log.saveInBackground()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scenarioListSegueTwo" {
            let destVC: ScenarioListViewController = segue.destinationViewController as! ScenarioListViewController
            destVC.lastSelectedSection = sectionIndex
            destVC.lastSelectedRow = rowIndex
        } else if segue.identifier == "heroStatOptionsSegueTwo" {
            let destVC: HeroStatOptionsViewController = segue.destinationViewController as! HeroStatOptionsViewController
            destVC.activeRoster = activeRoster
            destVC.navBarTitle = "Heros"
            destVC.activateHeroNameTable = true
            destVC.lastSelectedRow = heroNameIndex
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(ScenarioListViewController)) {
            let scenarioName: ScenarioListViewController = unwindSegue.sourceViewController as! ScenarioListViewController
            scenarioNameTextView.text = scenarioName.nameToReturn
        } else if(unwindSegue.sourceViewController .isKindOfClass(HeroStatOptionsViewController)) {
            let chosenHero: HeroStatOptionsViewController = unwindSegue.sourceViewController as! HeroStatOptionsViewController
            creditForHeroTextField.text = chosenHero.nameToReturn
            heroNameIndex = chosenHero.chosenStat
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
    
    func findIndexValueForPreviouslySelectedHeroNameToCredit() {
        if activeRoster!.usedHeroNames.contains(gmLogDisplayed.creditForHero) == true {
            for (index, value) in activeRoster!.usedHeroNames.sort({ $0.lowercaseString < $1.lowercaseString}).enumerate() {
                if value == creditForHeroTextField.text {
                    heroNameIndex = index
                }
            }
        }
    }
    
    @IBAction func dateTextFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        datePickerView.date = gmLogDisplayed.dateFromString(dateTextField.text!)
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
        scenarioNameTextView.text = gmLogDisplayed.name
        dateTextField.text = gmLogDisplayed.stringFromDate(gmLogDisplayed.date)
        notesTextView.text = gmLogDisplayed.notes
        creditForHeroTextField.text = gmLogDisplayed.creditForHero
        scenarioNameBeforeEdit = scenarioNameTextView.text!
    }
    
    func setViewToStaticMode() {
        let staticModeBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
        addLogButton.setTitle("Edit Log", forState: UIControlState.Normal)
        scenarioNameTextView.editable = false
        scenarioNameTextView.backgroundColor = staticModeBackgroundColor
        dateTextField.enabled = false
        dateTextField.backgroundColor = staticModeBackgroundColor
        notesTextView.editable = false
        notesTextView.backgroundColor = staticModeBackgroundColor
        creditForHeroTextField.enabled = false
        creditForHeroTextField.backgroundColor = staticModeBackgroundColor
    }
    
    func setViewToEditMode() {
        let editModeBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        addLogButton.setTitle("Save", forState: UIControlState.Normal)
        scenarioNameTextView.editable = true
        scenarioNameTextView.backgroundColor = editModeBackgroundColor
        dateTextField.enabled = true
        dateTextField.backgroundColor = editModeBackgroundColor
        notesTextView.editable = true
        notesTextView.backgroundColor = editModeBackgroundColor
        creditForHeroTextField.enabled = true
        creditForHeroTextField.backgroundColor = editModeBackgroundColor
    }

    func roundTheLabelsButtonsAndTextViews() {
        let backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
        scenarioNameLabel.layer.borderColor = UIColor.blackColor().CGColor
        scenarioNameLabel.layer.borderWidth = 1.0
        scenarioNameLabel.layer.cornerRadius = 5
        scenarioNameLabel.clipsToBounds = true
        scenarioNameLabel.backgroundColor = backgroundColor
        scenarioNameTextView.layer.borderColor = UIColor.blackColor().CGColor
        scenarioNameTextView.layer.borderWidth = 1.0
        scenarioNameTextView.layer.masksToBounds = true
        scenarioNameTextView.layer.cornerRadius = 8
        scenarioNameTextView.backgroundColor = backgroundColor
        scenarioNameTextView.inputView = UIView(frame: CGRectMake(0,0,0,0))
        dateLabel.layer.borderColor = UIColor.blackColor().CGColor
        dateLabel.layer.borderWidth = 1.0
        dateLabel.layer.cornerRadius = 5
        dateLabel.clipsToBounds = true
        dateLabel.backgroundColor = backgroundColor
        dateTextField.layer.borderColor = UIColor.blackColor().CGColor
        dateTextField.layer.borderWidth = 1.0
        dateTextField.layer.masksToBounds = true
        dateTextField.layer.cornerRadius = 5
        dateTextField.backgroundColor = backgroundColor
        creditForHeroLabel.layer.borderColor = UIColor.blackColor().CGColor
        creditForHeroLabel.layer.borderWidth = 1.0
        creditForHeroLabel.layer.cornerRadius = 5
        creditForHeroLabel.clipsToBounds = true
        creditForHeroLabel.backgroundColor = backgroundColor
        creditForHeroTextField.layer.borderColor = UIColor.blackColor().CGColor
        creditForHeroTextField.layer.borderWidth = 1.0
        creditForHeroTextField.layer.masksToBounds = true
        creditForHeroTextField.layer.cornerRadius = 5
        creditForHeroTextField.backgroundColor = backgroundColor
        creditForHeroTextField.inputView = UIView(frame: CGRectMake(0,0,0,0))
        notesLabel.layer.borderColor = UIColor.blackColor().CGColor
        notesLabel.layer.borderWidth = 1.0
        notesLabel.layer.cornerRadius = 5
        notesLabel.clipsToBounds = true
        notesLabel.backgroundColor = backgroundColor
        notesTextView.layer.borderColor = UIColor.blackColor().CGColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.masksToBounds = true
        notesTextView.layer.cornerRadius = 8
        notesTextView.backgroundColor = backgroundColor
        addLogButton.layer.borderColor = UIColor.blackColor().CGColor
        addLogButton.layer.borderWidth = 1.0
        addLogButton.layer.cornerRadius = 5
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == creditForHeroTextField {
            self.performSegueWithIdentifier("heroStatOptionsSegueTwo", sender: self)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.dateTextField {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView == notesTextView {
            scrollView.setContentOffset(CGPointMake(0, 255), animated: true)
        } else if textView == scenarioNameTextView {
            self.performSegueWithIdentifier("scenarioListSegueTwo", sender: self)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == notesTextView {
            scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }
}
