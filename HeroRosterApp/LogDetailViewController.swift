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
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextView!
    @IBOutlet weak var addLogButton: UIButton!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
      
    var activeRoster = Roster?()
    var heroDisplayed = Hero?()
    var heroLogDisplayed = SessionLog?()
    var sessionName = String()
    var date = String()
    var notes = String()
    var newSessionName = String()
    var sessionLogNameBeforeEdit = String()
    var activateEditMode = false
    var newLogObjectId = String()

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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addLogButtonPressed(sender: UIButton) {
        let buttonLabel = addLogButton.titleLabel!.text!
        switch buttonLabel {
            case "Edit Log":
            setViewToEditMode()
            
            case "Save":
                if sessionNameTextField.text != sessionLogNameBeforeEdit {
                    checkEditedLogNameAgainstUsedLogNames()
                } else {
                    saveEditedLog()
                }
            
            default:
                newSessionName = sessionNameTextField.text!
                if heroDisplayed!.usedLogNames.contains(newSessionName) == true  {
                    displayDuplicateSessionLogNameAlert()
                } else {
                    date = dateTextField.text!
                    notes = notesTextField.text!
                    let newSessionLog = SessionLog(name: newSessionName, date: date, notes: notes, parseObjectId: "")
                    createSessionLogOnParse(newSessionLog)
                    self.performSegueWithIdentifier("addSessionLogSegue", sender: self)
                }
        }
    }
    
    func checkEditedLogNameAgainstUsedLogNames() {
        if heroDisplayed!.usedLogNames.contains(sessionNameTextField.text!) == true {
            displayDuplicateSessionLogNameAlert()
        } else {
            updateTheUsedLogNamesArray()
            saveEditedLog()
        }
    }
    
    func displayDuplicateSessionLogNameAlert() {
        let alert = UIAlertController(
            title: "Can't save session!", message: "That session name has already been used.  Please choose another one.", preferredStyle: .Alert)
        let action = UIAlertAction(
            title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateTheUsedLogNamesArray() {
        for (index, value) in heroDisplayed!.usedLogNames.enumerate(){
            if sessionLogNameBeforeEdit == value {
                heroDisplayed!.usedLogNames.removeAtIndex(index)
            }
        }
        heroDisplayed!.usedLogNames.append(sessionNameTextField.text!)
        sessionLogNameBeforeEdit = sessionNameTextField.text!
    }
    
    func saveEditedLog() {
        setViewToStaticMode()
        let updatedSessionName = sessionNameTextField.text
        let updatedDate = dateTextField.text
        let updatedNotes = notesTextField.text
        heroDisplayed?.updateSessionLog(heroLogDisplayed!, newName: updatedSessionName!, newDate: updatedDate!, newNotes: updatedNotes)
        updateSessionLogOnParse()
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
                log["sessionName"] = self.sessionNameTextField.text
                log["date"] = self.dateTextField.text
                log["notes"] = self.notesTextField.text
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
        sessionNameTextField.text = heroLogDisplayed!.name
        dateTextField.text = heroLogDisplayed!.date
        notesTextField.text = heroLogDisplayed!.notes
        sessionLogNameBeforeEdit = sessionNameTextField.text!
    }
    
    func setViewToStaticMode() {
        addLogButton.setTitle("Edit Log", forState: UIControlState.Normal)
        sessionNameTextField.enabled = false
        dateTextField.enabled = false
        notesTextField.editable = false
    }
    
    func setViewToEditMode() {
        addLogButton.setTitle("Save", forState: UIControlState.Normal)
        sessionNameTextField.enabled = true
        dateTextField.enabled = true
        notesTextField.editable = true
    }
    
    func roundTheLabelsAndButtons() {
        addLogButton.layer.cornerRadius = 5
        sessionNameLabel.layer.cornerRadius = 5
        sessionNameLabel.clipsToBounds = true
        dateLabel.layer.cornerRadius = 5
        dateLabel.clipsToBounds = true
        notesLabel.layer.cornerRadius = 5
        notesLabel.clipsToBounds = true
        notesTextField.layer.cornerRadius = 5
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        scrollView.setContentOffset(CGPointMake(0, 150), animated: true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    @IBAction func textFieldDoneEditing(sender: AnyObject) {
        sender.resignFirstResponder()
    }
}
